#!/bin/bash

echo "🚀 Starting ArgoCD and Argo Rollouts Setup..."

# 1. Install ArgoCD
echo "📦 Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Install Argo Rollouts
echo "📦 Installing Argo Rollouts..."
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# 3. Install Argo Rollouts CLI plugin (for easy rollout management)
echo "🔌 Installing Argo Rollouts CLI..."
curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

# 4. Wait for core components to initialize
echo "⏳ Waiting for ArgoCD and Rollouts to become ready (this takes 1-2 minutes)..."
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
kubectl wait --for=condition=ready pod --all -n argo-rollouts --timeout=300s

# 5. Clone the target repository
echo "📂 Cloning the Blue-Green lab repository..."
git clone https://github.com/aws-devops-project/argo-rollout-blue-green.git
cd argo-rollout-blue-green

# 6. Setup Port-Forwarding (Run in background)
echo "🌐 Exposing ArgoCD on port 8080..."
nohup kubectl port-forward svc/argocd-server -n argocd 8080:443 --address 0.0.0.0 > /dev/null 2>&1 &

# 7. Retrieve Login Credentials
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo ""
echo "=========================================================="
echo "✅ LAB SETUP COMPLETE!"
echo "=========================================================="
echo "🔗 HOW TO ACCESS THE UI:"
echo "1. In Killercoda, look at the top/right side of the screen."
echo "2. Click on the 'Traffic / Ports' or 'Access Web' tab."
echo "3. Open Port 8080."
echo ""
echo "👤 Username: admin"
echo "🔑 Password: $ARGOCD_PASSWORD"
echo "=========================================================="
echo "Your repo is cloned in: $(pwd)"

# 1. Create a fresh directory
mkdir -p ~/fresh-blue-green-lab
cd ~/fresh-blue-green-lab

# 2. Create the Namespace file
cat <<EOF > 01-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: demo
EOF

# 3. Create the Active and Preview Services file
cat <<EOF > 02-services.yaml
apiVersion: v1
kind: Service
metadata:
  name: rollout-bluegreen-active
  namespace: demo
spec:
  selector:
    app: rollout-bluegreen
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080

---
apiVersion: v1
kind: Service
metadata:
  name: rollout-bluegreen-preview
  namespace: demo
spec:
  selector:
    app: rollout-bluegreen
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
EOF

# 4. Create the Argo Rollout file (Deploying the "Blue" version)
cat <<EOF > 03-rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-bluegreen
  namespace: demo
spec:
  replicas: 2
  revisionHistoryLimit: 2
  selector:
    matchLabels:
      app: rollout-bluegreen
  template:
    metadata:
      labels:
        app: rollout-bluegreen
    spec:
      containers:
      - name: rollouts-demo
        image: argoproj/rollouts-demo:blue
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
  strategy:
    blueGreen: 
      activeService: rollout-bluegreen-active
      previewService: rollout-bluegreen-preview
      autoPromotionEnabled: false # This pauses the rollout for manual approval
EOF

echo "✅ All YAML files created successfully in ~/fresh-blue-green-lab"
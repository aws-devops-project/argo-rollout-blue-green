# Argo Rollouts Blue/Green Lab on AWS EC2 + Kind

This lab provisions an Ubuntu 24.04 EC2 Spot instance in `eu-west-2`, installs Docker, kubectl, Kind, Helm, Argo CD, Argo Rollouts, NGINX Ingress, and Metrics Server, then boots a three-node Kind cluster for a blue/green rollout demo.

## Architecture

```text
Internet
  |
Elastic IP
  |
Security Group
  |
Ubuntu 24.04 EC2 Spot t3.large
  |
Docker + Kind + Helm + kubectl
  |
Kind cluster: 1 control plane, 2 workers
  |
NGINX Ingress + Argo CD + Argo Rollouts
  |
Blue/green demo app
```

## Prerequisites

- Terraform `>= 1.6`
- AWS credentials configured locally
- A Git repository containing this project

## Deploy

Update `terraform/terraform.tfvars` or pass variables at apply time:

```hcl
gitops_repo_url = "https://github.com/YOUR_ORG/YOUR_REPO.git"
allowed_cidr_blocks = ["YOUR_PUBLIC_IP/32"]
```

Then run:

```bash
cd terraform
terraform init
terraform apply
```

Terraform creates `terraform/kind-lab.pem`, uploads its public key to AWS, launches the Spot instance, and associates an Elastic IP by default.

## Access

Add the `hosts_file_entries` Terraform output to your local hosts file:

```text
PUBLIC_IP app.lab.local
PUBLIC_IP argocd.lab.local
PUBLIC_IP rollouts.lab.local
```

Open:

- App: `http://app.lab.local`
- Argo CD: `http://argocd.lab.local`
- Argo Rollouts Dashboard: `http://rollouts.lab.local`

Without hosts file entries:

- App: `http://PUBLIC_IP`
- Argo CD: `http://PUBLIC_IP:8080`
- Preview service: `http://PUBLIC_IP:8081`
- Argo Rollouts Dashboard: `http://PUBLIC_IP:8082`

SSH:

```bash
ssh -i terraform/kind-lab.pem ubuntu@PUBLIC_IP
```

Argo CD login:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

Username is `admin`.

## Blue/Green Flow

The initial Argo CD app watches:

```text
apps/demo/overlays/blue
```

To trigger the green rollout, change the Argo CD Application path to:

```text
apps/demo/overlays/green
```

You can make that change in `terraform/terraform.tfvars` before provisioning:

```hcl
gitops_path = "apps/demo/overlays/green"
```

Or commit a change to `apps/argocd/bluegreen-demo-app.yaml` in your GitOps repository.

Watch the rollout:

```bash
kubectl argo rollouts get rollout demo-app --watch
```

Preview the green version before promotion:

```bash
kubectl argo rollouts get rollout demo-app
kubectl port-forward svc/demo-app-preview 8081:80
```

Promote:

```bash
kubectl argo rollouts promote demo-app
```

Rollback:

```bash
kubectl argo rollouts undo demo-app
```

## Rerun Install Steps

The EC2 bootstrap writes reusable scripts to `/opt/kind-bluegreen-lab/scripts`.

```bash
sudo /opt/kind-bluegreen-lab/scripts/create-kind.sh
sudo /opt/kind-bluegreen-lab/scripts/install-ingress.sh
sudo /opt/kind-bluegreen-lab/scripts/install-argocd.sh
sudo /opt/kind-bluegreen-lab/scripts/install-rollouts.sh
```

Bootstrap logs are written to:

```text
/var/log/kind-bluegreen-lab/install.log
```

## Destroy

```bash
cd terraform
terraform destroy
```



git add .
git commit -m "Initial commit"
git push -u origin main

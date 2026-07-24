#!/usr/bin/env bash

set -Eeuo pipefail

###############################################
# Variables
###############################################

NAMESPACE="argocd"

RELEASE="argocd"

HOSTNAME="argocd.lab.local"

###############################################
# Banner
###############################################

echo "=========================================="

echo "Installing ArgoCD"

echo "=========================================="

###############################################
# Verify Cluster
###############################################

kubectl cluster-info >/dev/null

###############################################
# Helm Repository
###############################################

helm repo add argo https://argoproj.github.io/argo-helm

helm repo update

###############################################
# Install ArgoCD
###############################################

helm upgrade --install "${RELEASE}" argo/argo-cd \
\
--namespace "${NAMESPACE}" \
\
--create-namespace \
\
--set configs.params."server\.insecure"=true \
\
--set server.service.type=ClusterIP \
\
--wait

###############################################
# Wait
###############################################

kubectl rollout status \
deployment/argocd-server \
-n ${NAMESPACE} \
--timeout=300s

###############################################
# Create Ingress
###############################################

cat <<EOF | kubectl apply -f -

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

  name: argocd

  namespace: ${NAMESPACE}

spec:

  ingressClassName: nginx

  rules:

  - host: ${HOSTNAME}

    http:

      paths:

      - path: /

        pathType: Prefix

        backend:

          service:

            name: argocd-server

            port:

              number: 80

EOF

###############################################
# Password
###############################################

PASSWORD=$(kubectl \
-n ${NAMESPACE} \
get secret argocd-initial-admin-secret \
-o jsonpath="{.data.password}" | base64 -d)

###############################################
# Verify
###############################################

kubectl get pods -n ${NAMESPACE}

echo

kubectl get ingress -n ${NAMESPACE}

echo

echo "=========================================="

echo "ArgoCD Installed"

echo

echo "URL"

echo "http://${HOSTNAME}"

echo

echo "Username"

echo "admin"

echo

echo "Password"

echo "${PASSWORD}"

echo

echo "=========================================="
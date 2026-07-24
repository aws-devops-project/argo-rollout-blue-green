#!/usr/bin/env bash

set -Eeuo pipefail

echo "=============================================="
echo "Installing NGINX Ingress Controller"
echo "=============================================="

#############################################
# Verify Cluster
#############################################

kubectl cluster-info >/dev/null

#############################################
# Add Helm Repository
#############################################

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update

#############################################
# Install
#############################################

helm upgrade --install ingress-nginx \
ingress-nginx/ingress-nginx \
--namespace ingress-nginx \
--create-namespace \
--set controller.replicaCount=1 \
--set controller.service.type=NodePort \
--set controller.hostNetwork=true \
--set controller.dnsPolicy=ClusterFirstWithHostNet \
--wait

#############################################
# Wait
#############################################

kubectl rollout status \
deployment/ingress-nginx-controller \
-n ingress-nginx \
--timeout=300s

#############################################
# Verify
#############################################

kubectl get pods -n ingress-nginx

echo

kubectl get svc -n ingress-nginx

echo

kubectl get deployment -n ingress-nginx

echo

echo "NGINX Ingress Installed Successfully"
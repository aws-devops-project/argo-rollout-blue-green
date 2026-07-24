#!/usr/bin/env bash

set -Eeuo pipefail

###############################################
# Variables
###############################################

NAMESPACE="kube-system"

RELEASE="metrics-server"

###############################################
# Banner
###############################################

echo "=========================================="
echo "Installing Metrics Server..."
echo "=========================================="

###############################################
# Verify Cluster
###############################################

kubectl cluster-info >/dev/null

###############################################
# Add Helm Repository
###############################################

helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/

helm repo update

###############################################
# Install Metrics Server
###############################################

helm upgrade --install ${RELEASE} \
metrics-server/metrics-server \
--namespace ${NAMESPACE} \
--set args[0]="--kubelet-insecure-tls" \
--set args[1]="--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP" \
--wait

###############################################
# Wait
###############################################

kubectl rollout status \
deployment/metrics-server \
-n ${NAMESPACE} \
--timeout=300s

###############################################
# Verify
###############################################

echo
kubectl get pods -n ${NAMESPACE}

echo
kubectl top nodes || true

echo
kubectl top pods -A || true

echo
echo "=========================================="
echo "Metrics Server Installed Successfully"
echo "=========================================="
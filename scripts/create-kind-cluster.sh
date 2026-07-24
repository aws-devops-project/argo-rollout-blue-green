#!/usr/bin/env bash

set -Eeuo pipefail

###############################################
# Configuration
###############################################

CLUSTER_NAME="kind-bluegreen"

KIND_CONFIG="../kind/kind-config.yaml"

WAIT_TIMEOUT="5m"

###############################################
# Banner
###############################################

echo "=========================================="
echo "Creating Kind Kubernetes Cluster"
echo "=========================================="

###############################################
# Verify Requirements
###############################################

command -v docker >/dev/null || {
    echo "Docker not installed."
    exit 1
}

command -v kind >/dev/null || {
    echo "Kind not installed."
    exit 1
}

command -v kubectl >/dev/null || {
    echo "kubectl not installed."
    exit 1
}

###############################################
# Docker Status
###############################################

if ! systemctl is-active --quiet docker; then
    echo "Starting Docker..."

    sudo systemctl start docker
fi

###############################################
# Delete Existing Cluster
###############################################

if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then

    echo "Existing cluster found."

    echo "Deleting old cluster..."

    kind delete cluster --name "${CLUSTER_NAME}"

fi

###############################################
# Create Cluster
###############################################

echo

echo "Creating cluster..."

kind create cluster \
    --name "${CLUSTER_NAME}" \
    --config "${KIND_CONFIG}" \
    --wait "${WAIT_TIMEOUT}"

###############################################
# Export kubeconfig
###############################################

mkdir -p ~/.kube

kind get kubeconfig --name "${CLUSTER_NAME}" > ~/.kube/config

chmod 600 ~/.kube/config

###############################################
# Verify Cluster
###############################################

echo

kubectl cluster-info

echo

kubectl get nodes -o wide

echo

kubectl get pods -A

###############################################
# Wait until nodes become Ready
###############################################

echo

echo "Waiting for nodes..."

kubectl wait \
--for=condition=Ready node \
--all \
--timeout=180s

echo

echo "=========================================="

echo "Kind Cluster Created Successfully"

echo "=========================================="

echo

kubectl get nodes

echo
#!/usr/bin/env bash

set -Eeuo pipefail

echo "=========================================="
echo "Installing kubectl..."
echo "=========================================="

ARCH="amd64"

# Get latest stable version
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

echo "Latest Version: ${KUBECTL_VERSION}"

# Download kubectl
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"

# Download checksum
curl -LO "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256"

# Verify checksum
echo "$(cat kubectl.sha256) kubectl" | sha256sum --check

# Install
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Cleanup
rm -f kubectl
rm -f kubectl.sha256

########################################
# Bash Completion
########################################

kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl >/dev/null

echo 'alias k=kubectl' >> /home/ubuntu/.bashrc

echo 'complete -F __start_kubectl k' >> /home/ubuntu/.bashrc

########################################
# Verify
########################################

echo
echo "Installed Version"

kubectl version --client

echo
echo "kubectl installation completed."
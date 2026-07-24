#!/usr/bin/env bash

set -Eeuo pipefail

echo "========================================="
echo "Installing Helm..."
echo "========================================="

ARCH="amd64"

########################################
# Get Latest Stable Version
########################################

HELM_VERSION=$(curl -fsSL https://api.github.com/repos/helm/helm/releases/latest \
| jq -r '.tag_name')

echo "Latest Helm Version: ${HELM_VERSION}"

########################################
# Download Helm
########################################

cd /tmp

curl -LO \
"https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCH}.tar.gz"

########################################
# Extract
########################################

tar -xzf helm-${HELM_VERSION}-linux-${ARCH}.tar.gz

########################################
# Install
########################################

sudo mv linux-${ARCH}/helm /usr/local/bin/helm

sudo chmod +x /usr/local/bin/helm

########################################
# Cleanup
########################################

rm -rf linux-${ARCH}

rm -f helm-${HELM_VERSION}-linux-${ARCH}.tar.gz

########################################
# Bash Completion
########################################

helm completion bash | sudo tee /etc/bash_completion.d/helm >/dev/null

echo 'source <(helm completion bash)' >> /home/ubuntu/.bashrc

########################################
# Verify Installation
########################################

echo
helm version

echo
echo "Helm installation completed successfully."

#!/usr/bin/env bash

set -Eeuo pipefail

echo "========================================="
echo "Installing Kind..."
echo "========================================="

########################################
# Verify Docker
########################################

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed."
    exit 1
fi

if ! systemctl is-active --quiet docker; then
    echo "Starting Docker..."
    sudo systemctl start docker
fi

sudo systemctl enable docker

########################################
# Add ubuntu user to docker group
########################################

sudo usermod -aG docker ubuntu

########################################
# Download Latest Kind
########################################

KIND_VERSION=$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest \
| jq -r '.tag_name')

echo "Latest Kind Version: ${KIND_VERSION}"

curl -Lo kind \
"https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64"

chmod +x kind

sudo mv kind /usr/local/bin/

########################################
# Bash Completion
########################################

kind completion bash | sudo tee /etc/bash_completion.d/kind >/dev/null

echo 'complete -F __start_kind kind' >> /home/ubuntu/.bashrc

########################################
# Verify Installation
########################################

echo
kind version

echo
docker --version

echo
echo "Kind installation completed successfully."
echo
echo "NOTE:"
echo "Log out and SSH back in so the docker group"
echo "membership is applied to the ubuntu user."
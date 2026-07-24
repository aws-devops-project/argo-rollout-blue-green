#!/usr/bin/env bash

set -Eeuo pipefail

echo "========================================"
echo " Argo Rollout Lab Bootstrap"
echo "========================================"

########################################
# Update Ubuntu
########################################

sudo apt update -y

sudo apt install -y \
curl \
wget \
git \
jq \
unzip \
ca-certificates \
gnupg \
apt-transport-https \
software-properties-common \
bash-completion

########################################
# Docker
########################################

if ! command -v docker >/dev/null 2>&1; then

    echo "Installing Docker..."

    sudo install -m 0755 -d /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt update

    sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

fi

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker "$USER"

########################################
# kubectl
########################################

if ! command -v kubectl >/dev/null 2>&1; then

    echo "Installing kubectl..."

    VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    curl -LO https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl

    chmod +x kubectl

    sudo mv kubectl /usr/local/bin/

fi

########################################
# Kind
########################################

if ! command -v kind >/dev/null 2>&1; then

    echo "Installing Kind..."

    VERSION=$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r '.tag_name')

    cd /tmp

    curl -Lo kind-linux-amd64 \
    https://kind.sigs.k8s.io/dl/${VERSION}/kind-linux-amd64

    chmod +x kind-linux-amd64

    sudo mv kind-linux-amd64 /usr/local/bin/kind

fi

########################################
# Helm
########################################

if ! command -v helm >/dev/null 2>&1; then

    echo "Installing Helm..."

    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

fi

kind create cluster --config */kind/kind-config.yaml
cd /home/ubuntu
git clone https://github.com/aws-devops-project/argo-rollout-blue-green.git

########################################
# Verify
########################################

echo
echo "========================================"

docker --version

kubectl version --client

kind version

helm version

echo
echo "Bootstrap Complete"

echo
echo "Logout and login again"

echo
echo "Then run"

echo
cd /home/ubuntu/argo-rollout-blue-green

echo "kind create cluster --config kind/kind-config.yaml"

echo
echo "========================================"
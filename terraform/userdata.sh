#!/bin/bash

set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "=================================================="
echo " Starting Kind Blue-Green Lab Installation"
echo "=================================================="

###############################################
# Update OS
###############################################

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

apt-get upgrade -y

###############################################
# Install Required Packages
###############################################

apt-get install -y \
curl \
wget \
git \
jq \
unzip \
tar \
apt-transport-https \
ca-certificates \
software-properties-common \
gnupg \
lsb-release \
bash-completion

###############################################
# Install Docker (Latest Official Repository)
###############################################

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor \
-o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update -y

apt-get install -y \
docker-ce \
docker-ce-cli \
containerd.io \
docker-buildx-plugin \
docker-compose-plugin

systemctl enable docker

systemctl start docker

###############################################
# Allow Ubuntu User to Run Docker
###############################################

usermod -aG docker ubuntu

###############################################
# Working Directory
###############################################

mkdir -p /opt/kind-lab

chown ubuntu:ubuntu /opt/kind-lab

###############################################
# Install AWS CLI v2
###############################################

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

rm -rf /tmp/aws*

###############################################
# System Cleanup
###############################################

apt-get autoremove -y

apt-get clean

###############################################
# Finished
###############################################

echo "Bootstrap completed successfully."

touch /opt/kind-lab/bootstrap-complete
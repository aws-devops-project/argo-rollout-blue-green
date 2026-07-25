#!/usr/bin/env bash

set -euo pipefail

echo "Installing kubectl v1.33.1"

VERSION="v1.33.1"

cd /tmp

curl -LO \
https://dl.k8s.io/release/${VERSION}/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/

kubectl version --client
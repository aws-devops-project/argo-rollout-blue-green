#!/usr/bin/env bash

set -euo pipefail

echo "======================================"
echo "Installing Kind v0.30.0"
echo "======================================"

VERSION="v0.30.0"

cd /tmp

curl -Lo kind \
https://kind.sigs.k8s.io/dl/${VERSION}/kind-linux-amd64

chmod +x kind

sudo mv kind /usr/local/bin/

echo
kind version
#!/usr/bin/env bash

set -Eeuo pipefail

###############################################
# Variables
###############################################

NAMESPACE="argo-rollouts"

HOSTNAME="rollouts.lab.local"

###############################################
# Banner
###############################################

echo "=========================================="
echo "Installing Argo Rollouts Dashboard"
echo "=========================================="

###############################################
# Verify Namespace
###############################################

kubectl get namespace ${NAMESPACE} >/dev/null

###############################################
# Deploy Dashboard
###############################################

cat <<EOF | kubectl apply -f -

apiVersion: apps/v1
kind: Deployment
metadata:
  name: argo-rollouts-dashboard
  namespace: ${NAMESPACE}

spec:
  replicas: 1

  selector:
    matchLabels:
      app: argo-rollouts-dashboard

  template:

    metadata:

      labels:
        app: argo-rollouts-dashboard

    spec:

      containers:

      - name: dashboard

        image: quay.io/argoproj/kubectl-argo-rollouts:latest

        command:

        - kubectl-argo-rollouts

        args:

        - dashboard

        - --port

        - "3100"

        ports:

        - containerPort: 3100

---

apiVersion: v1
kind: Service

metadata:

  name: argo-rollouts-dashboard

  namespace: ${NAMESPACE}

spec:

  selector:

    app: argo-rollouts-dashboard

  ports:

  - name: http

    port: 3100

    targetPort: 3100

---

apiVersion: networking.k8s.io/v1

kind: Ingress

metadata:

  name: argo-rollouts-dashboard

  namespace: ${NAMESPACE}

spec:

  ingressClassName: nginx

  rules:

  - host: ${HOSTNAME}

    http:

      paths:

      - path: /

        pathType: Prefix

        backend:

          service:

            name: argo-rollouts-dashboard

            port:

              number: 3100

EOF

###############################################
# Wait
###############################################

kubectl rollout status \
deployment/argo-rollouts-dashboard \
-n ${NAMESPACE} \
--timeout=300s

###############################################
# Verify
###############################################

kubectl get pods -n ${NAMESPACE}

echo

kubectl get ingress -n ${NAMESPACE}

echo

echo "=========================================="
echo "Dashboard Installed"
echo
echo "Open:"
echo
echo "http://${HOSTNAME}"
echo "=========================================="

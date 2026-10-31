#!/usr/bin/env bash
set -euo pipefail

echo "=== Deploying Argo Rollouts Controller v1.7.1 ==="
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/download/v1.7.1/install.yaml

echo "Waiting for argo-rollouts deployment to reach Ready status..."
kubectl -n argo-rollouts rollout status deploy/argo-rollouts --timeout=300s

echo "=== Argo Rollouts Controller Installed Successfully ==="
kubectl get crd | grep argoproj.io

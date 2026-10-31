#!/usr/bin/env bash
set -euo pipefail

echo "=== Deploying Argo Rollouts Controller v1.7.1 ==="
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n argo-rollouts \
  -f https://github.com/argoproj/argo-rollouts/releases/download/v1.7.1/install.yaml

echo "Waiting for argo-rollouts deployment to reach Ready status..."
kubectl -n argo-rollouts rollout status deploy/argo-rollouts --timeout=300s

echo "Waiting for Rollouts CRDs to be Established..."
kubectl wait --for=condition=Established --timeout=60s \
  crd/rollouts.argoproj.io \
  crd/analysisruns.argoproj.io \
  crd/analysistemplates.argoproj.io \
  crd/clusteranalysistemplates.argoproj.io \
  crd/experiments.argoproj.io

echo "=== Argo Rollouts Controller Installed Successfully ==="
kubectl get crd \
  rollouts.argoproj.io \
  analysisruns.argoproj.io \
  analysistemplates.argoproj.io \
  clusteranalysistemplates.argoproj.io \
  experiments.argoproj.io

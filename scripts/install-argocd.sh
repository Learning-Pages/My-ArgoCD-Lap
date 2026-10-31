#!/usr/bin/env bash
set -euo pipefail

ARGOCD_VERSION="v2.11.3"
MANIFEST_URL="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "=== Deploying Argo CD ${ARGOCD_VERSION} ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Server-side apply: install.yaml exceeds the client-side annotation size limit.
# --force-conflicts is intended for fresh/idempotent installs — it overwrites
# out-of-band manual edits on rerun.
kubectl apply -n argocd --server-side --force-conflicts -f "${MANIFEST_URL}"

echo "Waiting for Argo CD components to reach Healthy rollout status..."
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl -n argocd rollout status deploy/argocd-repo-server --timeout=300s
kubectl -n argocd rollout status deploy/argocd-applicationset-controller --timeout=300s
kubectl -n argocd rollout status statefulset/argocd-application-controller --timeout=300s

echo "=== Argo CD Installed Successfully ==="
if kubectl -n argocd get secret argocd-initial-admin-secret &>/dev/null; then
  printf 'Initial admin password: %s\n' \
    "$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)"
else
  echo "Initial admin secret not found (password already rotated)."
fi

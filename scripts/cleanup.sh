#!/usr/bin/env bash
set -uo pipefail

echo "=== Tearing Down Local Argo CD & Kind Environment ==="

# Only touch processes tied to the argocd kind cluster.
# `kind delete` will terminate in-cluster workloads anyway; pkill is a best-effort
# for foreground port-forwards the user started manually against THIS cluster.
echo "Stopping port-forwards and dashboards tied to the argocd kind cluster..."
pkill -f "kubectl.*port-forward.*kind-argocd" || true
# Default dashboard port; only kill the listener, not arbitrary processes.
fuser -k 3100/tcp 2>/dev/null || true

echo "Deleting Kind cluster 'argocd'..."
kind delete cluster --name argocd || true

# Clean up any stale kubeconfig entries left by a previously interrupted teardown.
kubectl config delete-context kind-argocd 2>/dev/null || true
kubectl config delete-cluster kind-argocd 2>/dev/null || true

echo "Verifying cluster removal:"
if kind get clusters 2>/dev/null | grep -qx argocd; then
  echo "ERROR: cluster 'argocd' still present" >&2
  exit 1
fi
echo "  'argocd' cluster is gone."

echo "Environment teardown complete."

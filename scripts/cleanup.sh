#!/usr/bin/env bash
set -uo pipefail

echo "=== Tearing Down Local Argo CD & Kind Environment ==="

echo "Stopping background port-forwards and dashboards..."
pkill -f "kubectl.*port-forward" || true
pkill -f "kubectl-argo-rollouts.*dashboard" || true

echo "Deleting Kind cluster 'argocd'..."
kind delete cluster --name argocd || true

echo "Verifying cluster removal:"
kind get clusters

echo "Environment teardown complete."

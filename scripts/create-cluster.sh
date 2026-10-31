#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== Provisioning 3-Node Kind Cluster ==="
kind create cluster --config "${REPO_ROOT}/cluster/kind-config.yaml"

kubectl cluster-info --context kind-argocd
kubectl config use-context kind-argocd

echo "Waiting for nodes to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=120s
kubectl get nodes -o wide

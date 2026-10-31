#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CLUSTER_NAME="argocd"
CONTEXT="kind-${CLUSTER_NAME}"
CONFIG="${REPO_ROOT}/cluster/kind-config.yaml"

echo "=== Provisioning 3-Node Kind Cluster (${CLUSTER_NAME}) ==="

[[ -f "${CONFIG}" ]] || { echo "ERROR: ${CONFIG} not found" >&2; exit 1; }

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Cluster '${CLUSTER_NAME}' already exists — reusing."
else
  kind create cluster --config "${CONFIG}"
fi

if ! kubectl config get-contexts "${CONTEXT}" &>/dev/null; then
  echo "ERROR: context '${CONTEXT}' not found — is 'name:' in kind-config.yaml '${CLUSTER_NAME}'?" >&2
  exit 1
fi

kubectl config use-context "${CONTEXT}"

echo "Waiting for nodes to become Ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl get nodes -o wide

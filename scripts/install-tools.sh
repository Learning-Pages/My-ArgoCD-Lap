#!/usr/bin/env bash
set -euo pipefail

KUBECTL_VERSION="v1.30.0"
KIND_VERSION="v0.23.0"
HELM_VERSION="v3.14.4"
ARGOCD_VERSION="v2.11.3"
KUSTOMIZE_VERSION="v5.4.2"
ROLLOUTS_VERSION="v1.7.1"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) echo "Unsupported arch: $ARCH" >&2; exit 1 ;;
esac

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

echo "=== kubectl ${KUBECTL_VERSION} ==="
curl -fLo "$tmpdir/kubectl" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl"
curl -fLo "$tmpdir/kubectl.sha256" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl.sha256"
echo "$(cat "$tmpdir/kubectl.sha256")  $tmpdir/kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 "$tmpdir/kubectl" /usr/local/bin/kubectl

echo "=== kind ${KIND_VERSION} ==="
curl -fLo "$tmpdir/kind" "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}"
sudo install -m 0755 "$tmpdir/kind" /usr/local/bin/kind

echo "=== helm ${HELM_VERSION} ==="
curl -fsSL "https://raw.githubusercontent.com/helm/helm/${HELM_VERSION}/scripts/get-helm-3" -o "$tmpdir/get-helm-3"
bash "$tmpdir/get-helm-3" --version "${HELM_VERSION}"

echo "=== argocd ${ARGOCD_VERSION} ==="
curl -fsSLo "$tmpdir/argocd" "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCH}"
sudo install -m 0555 "$tmpdir/argocd" /usr/local/bin/argocd

echo "=== kustomize ${KUSTOMIZE_VERSION} ==="
curl -fsSLo "$tmpdir/kustomize.tar.gz" \
  "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz"
tar xzf "$tmpdir/kustomize.tar.gz" -C "$tmpdir"
sudo install -m 0755 "$tmpdir/kustomize" /usr/local/bin/kustomize

echo "=== kubectl-argo-rollouts ${ROLLOUTS_VERSION} ==="
curl -fLo "$tmpdir/kubectl-argo-rollouts" \
  "https://github.com/argoproj/argo-rollouts/releases/download/${ROLLOUTS_VERSION}/kubectl-argo-rollouts-linux-${ARCH}"
sudo install -m 0755 "$tmpdir/kubectl-argo-rollouts" /usr/local/bin/kubectl-argo-rollouts

echo "=== Done ==="
kubectl version --client
kind --version
helm version --short
argocd version --client --short
kustomize version
kubectl argo rollouts version

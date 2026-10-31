#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Kubernetes & GitOps Toolchain ==="

# 1. kubectl v1.30
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# 2. kind v0.23.0
echo "Installing kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# 3. Helm v3.14+
echo "Installing Helm..."
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 4. Argo CD CLI v2.11.3
echo "Installing Argo CD CLI..."
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/download/v2.11.3/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd
rm -f argocd

# 5. Kustomize v5.3+
echo "Installing kustomize..."
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/

# 6. Argo Rollouts kubectl Plugin v1.7.1
echo "Installing kubectl-argo-rollouts..."
curl -LO https://github.com/argoproj/argo-rollouts/releases/download/v1.7.1/kubectl-argo-rollouts-linux-amd64
chmod +x ./kubectl-argo-rollouts-linux-amd64
sudo mv ./kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts

echo "=== Toolchain Installation Completed Successfully ==="
kubectl version --client || true
kind --version || true
helm version || true
argocd version --client || true
kustomize version || true
kubectl argo rollouts version || true

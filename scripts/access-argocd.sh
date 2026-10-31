#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-http}"
PORT="${2:-8080}"

echo "=== Configuring Argo CD Access (Mode: ${MODE}, Port: ${PORT}) ==="

ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Initial admin password: ${ADMIN_PASSWORD}"

if [ "${MODE}" = "http" ] || [ "${MODE}" = "insecure" ]; then
  echo "Enabling insecure HTTP mode to eradicate TLS redirect loops..."
  kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge \
    -p '{"data":{"server.insecure":"true"}}'
  kubectl -n argocd rollout restart deploy/argocd-server
  kubectl -n argocd rollout status deploy/argocd-server --timeout=120s

  echo "Port-forwarding HTTP (port 80 -> ${PORT})..."
  echo "Access UI: http://localhost:${PORT}"
  echo "Login CLI: argocd login localhost:${PORT} --username admin --password \"${ADMIN_PASSWORD}\" --plaintext"
  kubectl -n argocd port-forward svc/argocd-server "${PORT}:80"
else
  echo "Port-forwarding HTTPS (port 443 -> ${PORT})..."
  echo "Access UI: https://localhost:${PORT}"
  echo "Login CLI: argocd login localhost:${PORT} --username admin --password \"${ADMIN_PASSWORD}\" --insecure"
  kubectl -n argocd port-forward svc/argocd-server "${PORT}:443"
fi

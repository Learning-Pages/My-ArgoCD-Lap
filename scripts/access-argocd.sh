#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-http}"
PORT="${2:-8080}"

echo "=== Configuring Argo CD Access (Mode: ${MODE}, Port: ${PORT}) ==="

if kubectl -n argocd get secret argocd-initial-admin-secret &>/dev/null; then
  ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret \
    -o jsonpath="{.data.password}" | base64 -d)
  echo "Initial admin password: ${ADMIN_PASSWORD}"
else
  ADMIN_PASSWORD="(initial secret gone — password already changed)"
  echo "Initial admin secret not found; using existing credentials."
fi

if [ "${MODE}" = "http" ] || [ "${MODE}" = "insecure" ]; then
  # server.insecure=true tells argocd-server to serve plain HTTP and stop
  # redirecting to HTTPS — avoids redirect loops behind port-forward.
  echo "Enabling insecure HTTP mode..."
  kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge \
    -p '{"data":{"server.insecure":"true"}}'
  kubectl -n argocd rollout restart deploy/argocd-server
  kubectl -n argocd rollout status deploy/argocd-server --timeout=120s

  echo "Access UI: http://localhost:${PORT}"
  echo "Login CLI: argocd login localhost:${PORT} --username admin --password \"${ADMIN_PASSWORD}\" --plaintext"
  kubectl -n argocd port-forward svc/argocd-server "${PORT}:80"
else
  # Ensure insecure is OFF so :443 actually speaks TLS.
  kubectl -n argocd patch configmap argocd-cmd-params-cm --type merge \
    -p '{"data":{"server.insecure":"false"}}'
  kubectl -n argocd rollout restart deploy/argocd-server
  kubectl -n argocd rollout status deploy/argocd-server --timeout=120s

  echo "Access UI: https://localhost:${PORT} (self-signed cert warning expected)"
  echo "Login CLI: argocd login localhost:${PORT} --username admin --password \"${ADMIN_PASSWORD}\" --insecure"
  kubectl -n argocd port-forward svc/argocd-server "${PORT}:443"
fi

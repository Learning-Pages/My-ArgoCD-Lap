# 🚀 Argo CD & GitOps Master Production Platform

[![ArgoCD](https://img.shields.io/badge/ArgoCD-v2.11.3-orange?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.30+-blue?logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-v3.14+-0F1689?logo=helm&logoColor=white)](https://helm.sh/)
[![Kustomize](https://img.shields.io/badge/Kustomize-v5.3+-green?logo=kubernetes&logoColor=white)](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
[![Argo Rollouts](https://img.shields.io/badge/Argo%20Rollouts-v1.7.1-00BFFF?logo=argo&logoColor=white)](https://argoproj.github.io/argo-rollouts/)
[![Sealed Secrets](https://img.shields.io/badge/Bitnami-Sealed%20Secrets-yellow?logo=bitnami&logoColor=white)](https://github.com/bitnami-labs/sealed-secrets)

> **Complete Enterprise GitOps Production Reference & Manual Command System**  
> Every command, manifest, sync wave, hook, and troubleshooting diagnostic, ordered for strict sequential execution.

---

## 📑 Quick Navigation

- [1. Architecture & Repository Structure](#1-architecture--repository-structure)
- [2. Quick Start (Single-Command Provisioning)](#2-quick-start-single-command-provisioning)
- [3. Complete Useful Commands Cheat Sheet](#3-complete-useful-commands-cheat-sheet)
    - [Application Management](#application-management)
    - [Argo Rollouts Commands](#argo-rollouts-commands)
    - [Sync Policies & Drift Commands](#sync-policies--drift-commands)
    - [Sealed Secrets Encryption Commands](#sealed-secrets-encryption-commands)
    - [Cluster & Diagnostics](#cluster--diagnostics)
- [4. Production Deployment Strategies (Step-by-Step)](#4-production-deployment-strategies-step-by-step)
    - [Strategy 1: Rolling Update (Zero Downtime)](#strategy-1-rolling-update-zero-downtime)
    - [Strategy 2: Recreate (Controlled Outage Window)](#strategy-2-recreate-controlled-outage-window)
    - [Strategy 3: Blue-Green Deployment (Argo Rollouts)](#strategy-3-blue-green-deployment-argo-rollouts)
    - [Strategy 4: Canary Deployment (Progressive Weight)](#strategy-4-canary-deployment-progressive-weight)
- [5. Sync Policies & The GitOps Golden Rule](#5-sync-policies--the-gitops-golden-rule)
- [6. Multi-Tier Sync Waves & PreSync Hooks](#6-multi-tier-sync-waves--presync-hooks)
- [7. Zero-Plaintext Secret Management (Sealed Secrets)](#7-zero-plaintext-secret-management-sealed-secrets)
- [8. Multi-Environment Promotion Pipeline (Dev -> Staging -> Prod)](#8-multi-environment-promotion-pipeline-dev---staging---prod)
- [9. Production Troubleshooting & Diagnostics Matrix](#9-production-troubleshooting--diagnostics-matrix)
- [10. Clean Teardown](#10-clean-teardown)

---

## 1. Architecture & Repository Structure

All manifests, scripts, configurations, and environment values are organized in `/argocd-gitops-production`:

```text
argocd-gitops-production/
├── Makefile                                # Fast single-command targets
├── cluster/
│   └── kind-config.yaml                    # 3-Node Kind cluster (1 master, 2 workers)
├── scripts/
│   ├── install-tools.sh                    # Installs kubectl, kind, helm, argocd, kustomize
│   ├── create-cluster.sh                   # Spawns Kind cluster with custom hostPort maps
│   ├── install-argocd.sh                   # Deploys Argo CD v2.11.3 + ServerSideApply
│   ├── install-rollouts.sh                 # Deploys Argo Rollouts v1.7.1 controller
│   ├── access-argocd.sh                    # Configures port-forward & HTTP/HTTPS mode
│   └── cleanup.sh                          # Tear down cluster and port-forwards
├── apps/
│   ├── rolling-update/                     # Strategy 1: maxUnavailable=0, maxSurge=1
│   │   ├── application.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── recreate/                           # Strategy 2: Total teardown before rebuild
│   │   ├── application.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── blue-green/                         # Strategy 3: Active vs Preview service
│   │   ├── application.yaml
│   │   ├── rollout.yaml
│   │   └── services.yaml
│   └── canary/                             # Strategy 4: 25% -> 50% -> 100% traffic shift
│       ├── application.yaml
│       ├── rollout.yaml
│       └── services.yaml
├── sync-labs/
│   ├── manual/application.yaml             # Sync Policy 1: OutOfSync demo
│   ├── automated/application.yaml          # Sync Policy 2: Automated sync
│   ├── self-heal/application.yaml          # Sync Policy 3: Auto-reverts live drift
│   ├── prune/application.yaml              # Sync Policy 4: Automatic zombie cleanup
│   ├── allow-empty/application.yaml        # Sync Policy 5: Total directory wipe authorization
│   ├── sync-waves/                         # Multi-Tier Wave Orchestration (-1 -> 0 -> 1 -> 2)
│   │   └── all-resources.yaml
│   └── hooks/                              # Sync Hooks
│       └── migration-job.yaml              # PreSync Job with HookSucceeded deletion
├── bootstrap/
│   ├── projects.yaml                       # Argo CD AppProjects RBAC
│   ├── root-app.yaml                       # App-of-Apps master application
│   └── matrix-applicationset.yaml          # 3-tier environment matrix generator
└── environments/
    ├── dev/values-cart.yaml                # Automated CI deployments (git SHA)
    ├── staging/values-cart.yaml            # Integration testing candidate
    └── prod/
        ├── values-cart.yaml                # SemVer release (v2.4.1)
        └── sealed-checkout-secret.yaml     # Asymmetric encrypted secret (Git safe)
```

---

## 2. Quick Start (Single-Command Provisioning)

### Step 1: Export Environment Variables

```bash
# Clone the repository
git clone https://github.com/Learning-Pages/My-ArgoCD-Lap.git
cd My-ArgoCD-Lap

# Export active branch (main or master)
export GIT_BRANCH=$(git branch --show-current)
export GIT_REPO="https://github.com/Learning-Pages/My-ArgoCD-Lap.git"
echo "Target: ${GIT_REPO} on branch ${GIT_BRANCH}"
```

### Step 2: Use the Makefile Shortcuts

```bash
make tools      # Installs kubectl, kind, helm, argocd CLI, kustomize, and rollouts plugin
make cluster    # Provisions 3-Node Kind cluster (1 control-plane, 2 workers)
make argocd     # Installs Argo CD v2.11.3 and waits for pod readiness
make rollouts   # Installs Argo Rollouts Controller v1.7.1
make access     # Retrieves initial admin password and sets up port-forward on port 8080
```

---

## 3. Complete Useful Commands Cheat Sheet

### Application Management

```bash
# List all registered applications and their health/sync status
argocd app list

# Inspect detailed status and live Kubernetes resource tree
argocd app get rolling-update

# Force immediate cache invalidation and Git re-check
argocd app get root --hard-refresh

# Trigger manual synchronization
argocd app sync rolling-update

# Sync only specific applications by label (e.g. production apps)
argocd app sync -l env=prod

# View differences between Git repository and live cluster
argocd app diff rolling-update

# Stream aggregated container logs
argocd app logs frontend-prod --follow

# View deployment revision history
argocd app history rolling-update

# Pin an application to a specific Git branch, semantic tag, or commit SHA
argocd app set rolling-update --revision ${GIT_BRANCH}
argocd app set rolling-update --revision v1.0.0
argocd app set rolling-update --revision <commit-sha>

# Wait for application to reach Synced and Healthy state
argocd app wait rolling-update --sync --health --timeout 180
```

### Argo Rollouts Commands

```bash
# List all active Rollout resources
kubectl argo rollouts list rollouts

# Live watch of progressive rollout status
kubectl argo rollouts get rollout shopsphere-canary --watch

# Step promotion (advances to next defined traffic weight, e.g. 25% -> 50%)
kubectl argo rollouts promote shopsphere-canary

# Full promotion (skips all remaining steps and jumps immediately to 100%)
kubectl argo rollouts promote shopsphere-canary --full

# Abort rollout (restores 100% traffic immediately back to stable ReplicaSet)
kubectl argo rollouts abort shopsphere-canary

# Retry an aborted or failed rollout
kubectl argo rollouts retry rollout shopsphere-canary

# Launch Rollouts Web Dashboard on localhost:3100
kubectl argo rollouts dashboard &
```

### Sync Policies & Drift Commands

```bash
# Enable automated synchronization with auto-prune and self-heal
argocd app set rolling-update --sync-policy automated --auto-prune --self-heal

# Disable automated synchronization (required before emergency CLI rollback)
argocd app set rolling-update --sync-policy none

# Enable Server-Side Apply (SSA) for CRDs larger than 256KB
argocd app set rolling-update --sync-option ServerSideApply=true

# Allow total cluster teardown when Git source directory is emptied
argocd app set allow-empty-demo --sync-option AllowEmpty=true
```

### Sealed Secrets Encryption Commands

```bash
# Fetch cluster RSA public certificate
kubeseal --fetch-cert \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=sealed-secrets > pub-sealed-secrets.pem

# Encrypt secret locally into Git-safe YAML (never write password to plaintext file)
read -rs -p "Enter Secret Password: " DB_PW; echo
kubectl create secret generic checkout-db-secret \
  --namespace shopsphere-prod \
  --from-literal=password="${DB_PW}" \
  --dry-run=client -o yaml | \
  kubeseal --format yaml --cert pub-sealed-secrets.pem > environments/prod/sealed-checkout-secret.yaml
unset DB_PW

# Verify in-cluster unsealed Secret generated by controller
kubectl -n shopsphere-prod get secret checkout-db-secret -o yaml
```

### Cluster & Diagnostics

```bash
# Check Kind nodes status
kubectl get nodes -o wide

# Check all Argo CD pods
kubectl -n argocd get pods -o wide

# Stream Argo CD Server logs
kubectl -n argocd logs deploy/argocd-server --tail=50 -f

# Stream Argo CD Repo Server logs (Git operations & Kustomize/Helm rendering)
kubectl -n argocd logs deploy/argocd-repo-server --tail=50 -f

# Stream Application Controller logs (Reconciliation & Self-Heal drift engine)
kubectl -n argocd logs statefulset/argocd-application-controller --tail=50 -f

# Retrieve decoded initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

---

## 4. Production Deployment Strategies (Step-by-Step)

### Strategy 1: Rolling Update (Zero Downtime)
* **Goal**: Update pod versions one-by-one with zero dropped requests.
* **Key Config**: `maxUnavailable: 0` and `maxSurge: 1`.

```bash
# Apply Application
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rolling-update
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${GIT_REPO}
    targetRevision: ${GIT_BRANCH}
    path: apps/rolling-update
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

# Trigger update via Git
sed -i 's|image: nginx:.*|image: nginx:1.28|' apps/rolling-update/deployment.yaml
git commit -am "feat(rolling): bump nginx to 1.28" && git push origin ${GIT_BRANCH}
argocd app get rolling-update --refresh
kubectl rollout status deployment/shopsphere-rolling
```

### Strategy 2: Recreate (Controlled Outage Window)
* **Goal**: Completely delete existing pods before starting new ones (used for breaking database migrations).
* **Behavior**: Old pods terminate &rarr; outage gap (HTTP 503) &rarr; new pods spin up.

```bash
# Trigger Recreate update via Git
sed -i 's|image: nginx:.*|image: nginx:1.28|' apps/recreate/deployment.yaml
git commit -am "feat(recreate): bump nginx to 1.28" && git push origin ${GIT_BRANCH}
kubectl get pods -l app=shopsphere-recreate -w
```

### Strategy 3: Blue-Green Deployment (Argo Rollouts)
* **Goal**: Independent Active (`port 80`) and Preview (`port 8081`) services. Run smoke tests before instant traffic cutover.

```bash
# 1. Trigger Green deployment in Git
sed -i 's|image: nginx:.*|image: nginx:1.28|' apps/blue-green/rollout.yaml
git commit -am "feat(blue-green): green = nginx 1.28" && git push origin ${GIT_BRANCH}
kubectl argo rollouts get rollout shopsphere-bg --watch

# 2. Smoke test Preview service
kubectl port-forward svc/shopsphere-bg-preview 8081:80 &
PF_PID=$!
sleep 2
curl -I http://localhost:8081
kill ${PF_PID}

# 3. Promote to Active
kubectl argo rollouts promote shopsphere-bg

# Emergency Rollback:
kubectl argo rollouts abort shopsphere-bg
git revert HEAD --no-edit && git push origin ${GIT_BRANCH}
```

### Strategy 4: Canary Deployment (Progressive Weight)
* **Goal**: Route small traffic slices (25% &rarr; 50% &rarr; 100%) to test canary pods before full rollout.

```bash
# 1. Trigger Canary in Git
sed -i 's|image: nginx:.*|image: nginx:1.28|' apps/canary/rollout.yaml
git commit -am "feat(canary): nginx 1.28" && git push origin ${GIT_BRANCH}

# 2. Watch traffic step
kubectl argo rollouts get rollout shopsphere-canary --watch

# 3. Advance to next step (50%)
kubectl argo rollouts promote shopsphere-canary

# 4. Skip remaining steps and complete (100%)
kubectl argo rollouts promote shopsphere-canary --full

# Abort and restore stable
kubectl argo rollouts abort shopsphere-canary
git revert HEAD --no-edit && git push origin ${GIT_BRANCH}
```

---

## 5. Sync Policies & The GitOps Golden Rule

> ### ⚠️ The GitOps Golden Rule
> With `automated.selfHeal: true`, Argo CD reverts **any imperative cluster change** (`kubectl scale`, `kubectl set image`, `kubectl edit`) within seconds to match Git.
> **To change an application, always edit the manifest in Git and push.**

### Testing Self-Healing Drift:
```bash
# 1. Introduce rogue live drift
kubectl -n self-heal-demo scale deploy shopsphere-rolling --replicas=1

# 2. Watch Argo CD detect drift and restore back to 4 replicas
kubectl -n self-heal-demo get deploy shopsphere-rolling -w
```

### Testing Automatic Pruning:
```bash
# Add file to Git -> deployed to cluster
cat > apps/rolling-update/temp-config.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: temp-config
data:
  mode: "testing"
EOF
git add apps/rolling-update/temp-config.yaml
git commit -m "feat: add temp config" && git push origin ${GIT_BRANCH}

# Remove file from Git -> automatically deleted from cluster (pruned)
git rm apps/rolling-update/temp-config.yaml
git commit -m "feat: remove temp config" && git push origin ${GIT_BRANCH}
kubectl get cm temp-config # Returns NotFound
```

---

## 6. Multi-Tier Sync Waves & PreSync Hooks

Using `argocd.argoproj.io/sync-wave` annotations, Argo CD executes dependencies in strict sequential order. Wave $N$ is blocked until Wave $N-1$ is completely **Healthy**.

```text
Wave -1: Namespace & RBAC (shopsphere-waves)
   │
   ▼
PreSync Hook: Database Migration Job (Flyway/Prisma -> HookSucceeded auto-cleanup)
   │
   ▼
Wave 0: PostgreSQL 16 StatefulSet (waits for pg_isready probe)
   │
   ▼
Wave 1: Backend REST API (2 replicas, waits for DB connection pool)
   │
   ▼
Wave 2: Frontend Web UI (2 replicas, binds to Backend API Service)
```

Manifest definition:
```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

---

## 7. Zero-Plaintext Secret Management (Sealed Secrets)

1. **Install Sealed Secrets Controller**:
   ```bash
   helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
   helm install sealed-secrets sealed-secrets/sealed-secrets \
     --namespace sealed-secrets --create-namespace \
     --set fullnameOverride=sealed-secrets-controller
   ```
2. **Fetch Certificate**:
   ```bash
   kubeseal --fetch-cert --controller-name=sealed-secrets-controller --controller-namespace=sealed-secrets > pub-sealed-secrets.pem
   ```
3. **Encrypt into Git-safe YAML**:
   ```bash
   kubectl create secret generic checkout-db-secret \
     --namespace shopsphere-prod \
     --from-literal=password="ProductionPassword123!" \
     --dry-run=client -o yaml | \
     kubeseal --format yaml --cert pub-sealed-secrets.pem > environments/prod/sealed-checkout-secret.yaml
   
   git add environments/prod/sealed-checkout-secret.yaml
   git commit -m "chore: add sealed secret" && git push origin ${GIT_BRANCH}
   ```

---

## 8. Multi-Environment Promotion Pipeline (Dev -> Staging -> Prod)

- **Dev**: Automated CI deployment with short commit SHA:
  ```bash
  sed -i 's/tag: .*/tag: sha-3f9a1c2/' environments/dev/values-cart.yaml
  git commit -am "ci: deploy cart sha-3f9a1c2 to dev" && git push origin ${GIT_BRANCH}
  ```
- **Staging**: Integration candidate promotion:
  ```bash
  sed -i 's/tag: .*/tag: sha-3f9a1c2/' environments/staging/values-cart.yaml
  git commit -am "chore(staging): promote cart sha-3f9a1c2" && git push origin ${GIT_BRANCH}
  ```
- **Prod**: Production release with SemVer tag and `prune: false` safeguard:
  ```bash
  sed -i 's/tag: .*/tag: "2.4.1"/' environments/prod/values-cart.yaml
  git commit -am "release(cart): version 2.4.1 to prod" && git push origin ${GIT_BRANCH}
  ```

---

## 9. Production Troubleshooting & Diagnostics Matrix

| Symptom | Root Cause | One-Line Fix |
|---|---|---|
| `ComparisonError: revision not found` | Target revision does not match the actual Git branch (`main` vs `master`) | `argocd app set <app> --revision ${GIT_BRANCH}` |
| `file is outside allowed path` | Kustomize uses `../` beyond the application root boundary | Point `root-app` to `path: .` with `directory.include` |
| Stuck in `OutOfSync` on Helm-in-Kustomize | Helm inflation not enabled in `argocd-cm` | `kubectl -n argocd patch cm argocd-cm --type merge -p '{"data":{"kustomize.buildOptions":"--enable-helm"}}' && kubectl -n argocd rollout restart deploy/argocd-repo-server` |
| `argocd` CLI: `connection refused` | Port-forward died | `kubectl -n argocd port-forward svc/argocd-server 8080:443` |
| `bind: address already in use` on 8080 | Another process occupies port 8080 | Map alternate local port: `kubectl -n argocd port-forward svc/argocd-server 8085:443` |
| CLI login loops / TLS errors in insecure mode | Server is plain HTTP | `argocd login localhost:8080 --username admin --password "${ARGOCD_PW}" --plaintext` |
| `CRD too large` (> 256KB annotation) | Client-side apply annotation limit | Add `ServerSideApply=true` to `syncOptions` |
| `kubectl set image` / `scale` keeps reverting | `selfHeal: true` restores Git source of truth | Update the manifest in Git and push |
| `argocd app rollback` fails | Imperative rollback blocked while auto-sync is enabled | `argocd app set <app> --sync-policy none` first |

---

## 10. Clean Teardown

```bash
# Terminate background port-forward processes and Rollout dashboards
pkill -f "kubectl.*port-forward" || true
pkill -f "kubectl-argo-rollouts.*dashboard" || true

# Delete Kind cluster
kind delete cluster --name argocd

# Verify removal
kind get clusters
```

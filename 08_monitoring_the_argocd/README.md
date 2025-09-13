## ArgoCD Metrics Endpoints

According to the ArgoCD docs, ArgoCD exposes metrics at these **specific endpoints**:

1. **Application Controller Metrics**: `argocd-metrics:8082/metrics`
2. **API Server Metrics**: `argocd-server-metrics:8083/metrics` 
3. **Repo Server Metrics**: `argocd-repo-server:8084/metrics`

## Step 1: Install ArgoCD with Default Configuration

```bash
# Official ArgoCD installation
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Note**: The default ArgoCD installation already exposes metrics - no special configuration needed initially.

## Step 2: Install Prometheus + Grafana

```bash
# Add Prometheus Community Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack
kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring
```

## Step 3: Create Official ServiceMonitors (From ArgoCD Docs)

The **official ArgoCD documentation provides exact ServiceMonitor examples**:[1]

```yaml
# argocd-service-monitors.yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-metrics
  namespace: argocd
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-metrics
  endpoints:
  - port: metrics

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-server-metrics
  namespace: argocd
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-server-metrics
  endpoints:
  - port: metrics

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: argocd-repo-server-metrics
  namespace: argocd
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: argocd-repo-server-metrics
  endpoints:
  - port: metrics
```

Apply:
```bash
kubectl apply -f argocd-servicemonitors.yaml
```

## Step 4: Deploy Your Applications

Create your applications in ArgoCD:

```yaml
# applications.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: chai-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/chai-app
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      selfHeal: true
      prune: true

---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: online-shop
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/your-repo/online-shop
    targetRevision: HEAD
    path: .
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
```

Apply:
```bash
kubectl apply -f applications.yaml
```

## Step 5: Access Grafana and Import Dashboard

```bash
# Port-forward Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80

# Get admin password
kubectl get secret kube-prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d
```

Open `http://localhost:3000`, login, and import the **official ArgoCD Grafana dashboard**: **ID 14584**.

## Key Metrics Available (Official List)

Once setup is complete, you'll have access to these **official ArgoCD metrics**:[1]

- `argocd_app_info` - Application sync and health status
- `argocd_app_sync_total` - Application sync history
- `argocd_app_reconcile` - Reconciliation performance
- `argocd_cluster_connection_status` - Cluster connectivity
- `argocd_git_fetch_fail_total` - Git repository failures

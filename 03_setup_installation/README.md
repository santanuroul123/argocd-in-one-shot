# ArgoCD setup and Installation

Let's see how we can Setup & Install ArgoCD and access via the browser.

---

# Prerequisites

Before starting, ensure you have the following installed on your system:

1. **Docker** → Required for Kind to run containers as cluster nodes.

   ```bash
   sudo apt install docker.io -y
   sudo usermod -aG docker $USER && newgrp docker
   docker --version

   docker ps
   ```

2. **Kind (Kubernetes in Docker)** → To create the cluster.

   ```bash
   kind version
   ```

   [Install Guide](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

3. **kubectl** → To interact with the cluster.

   ```bash
   kubectl version --client
   ```

   [Install Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

4. **Helm (for Helm-based installation)**

   ```bash
   helm version
   ```

   [Install Guide](https://helm.sh/docs/intro/install/)

---

> [!NOTE]
> 
> You can either follow the below steps or directly run the script [setup_argocd.sh](./setup_argocd.sh)
> 
> The script will create **kind cluster** and **install ArgoCD** based on your choice (using HELM or manifest)

---

# Step 1: Create Kind Cluster

Save your cluster config as `kind-config.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
  - role: worker
    image: kindest/node:v1.33.1
```

Create the cluster:

```bash
kind create cluster --name argocd-cluster --config kind-config.yaml
```

Verify:

```bash
kubectl cluster-info
kubectl get nodes
```

---

#  Step 2: Install ArgoCD

We’ll cover **two professional installation methods**.

---

## **Method 1: Install ArgoCD using Helm** (recommended for customization/production)

### 1. Add Argo Helm repo

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

### 2. Create namespace

```bash
kubectl create namespace argocd
```

### 3. Install ArgoCD

```bash
helm install argocd argo/argo-cd -n argocd
```

### 4. Verify installation

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

### 5. Access the ArgoCD UI

Port-forward the service:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address=0.0.0.0 &
```

Now open → **[https://<instance_public_ip>:8080](https://<instance_public_ip>:8080)**

### 6. Get initial admin password

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

Login with:

* Username: `admin`
* Password: (above output)

---

## **Method 2: Install ArgoCD using Official Manifests (kubectl apply)**

(fastest for demos & learning)

### 1. Create namespace

```bash
kubectl create namespace argocd
```

### 2. Apply ArgoCD installation manifest

```bash
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Verify installation

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

### 4. Expose ArgoCD server

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address=0.0.0.0 &
```

Access → **[https://<instance_public_ip>:8080](https://<instance_public_ip>:8080)**

### 5. Get initial password

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

Login with:

* Username: `admin`
* Password: (above output)

---

#  Helm vs Manifest Installation

| Feature         | Helm Install (Method 1)     | Manifests (Method 2)         |
| --------------- | --------------------------- | ---------------------------- |
| **Flexibility** | High (override values.yaml) | Low (default configs only)   |
| **Ease of Use** | Requires Helm               | Works with just kubectl      |
| **Best for**    | Production & customization  | Quick demo / lab environment |

---

# Professional Best Practices

* For **local demo/testing** → use **kubectl apply**.
* For **production or enterprise** → use **Helm** (better upgrades & customization).
* Always **separate namespaces** (don’t install into `default`).
* Store **Application CRDs** in Git repos (GitOps best practice).



# Declarative Approach with ArgoCD (Online Shop Example)

In this approach, we will deploy an application using the **Declarative GitOps method**.  
We’ll use a custom **Online Shop app** (`amitabhdevops/online_shop:latest`) to demonstrate the true GitOps workflow.

---

## Theory

- In the **Declarative approach**, we define an `Application` resource (CRD) in YAML and store it in Git.  
- ArgoCD continuously monitors the Git repo and ensures the cluster state matches the desired state.  
- This is the **real GitOps way**: everything (app + config) is version-controlled in Git, reproducible, and auditable.  

> ✅ Best practice: Always use the **Declarative approach** in production.  
> ❌ UI and CLI are good for demos/labs, but not GitOps-compliant for enterprises.  

---

## Prerequisites

Before you begin, ensure you have:  
1. A **Kind cluster** running  
2. **ArgoCD installed & running on browser** (via Helm or manifests)  
3. **ArgoCD CLI installed and Logged In**  
4. `kubectl` installed to interact with your cluster   

> Follow this guide to set up ArgoCD: [ArgoCD Setup & Installation](../../../03_setup_installation/README.md)  

---

## Steps to Deploy Online Shop using Declarative Approach

### 1. Open a new VSCode editor & Open that `argocd-demos` repo that you had clonned

Just for manifest files, or making changes or pushing it to git - used while testing all approaches.

In below directory you can see the related manifest files:

  ```bash
  cd argocd-demos/declarative_approach/online_shop
  ```

---

### 📂 Directory Structure

```
declarative_approach/online_shop
├── online_shop_deployment.yml
└── online_shop_svc.yml
└── online_shop_app.yml    # ArgoCD Application CRD
```

---

### 2. Add Your Cluster to ArgoCD

Check your contexts:

```bash
kubectl config get-contexts
```

Identify your cluster context (e.g., `kind-argocd-cluster`).

Add it to ArgoCD:

```bash
argocd cluster add kind-argocd-cluster --name argocd-cluster --insecure
```

Verify:

```bash
argocd cluster list
```

---

### 3. Review the Application CRD

The **Application CRD** is nothing but the **YAML manifest** of an ArgoCD application.
When we create an application from the **UI** or **CLI**, ArgoCD generates this CRD in the cluster automatically.

The difference is:

* In **UI/CLI approaches**, the CRD exists **only inside the cluster**.
* In the **Declarative approach**, we write the CRD ourselves and store it in **Git**.

This has several advantages:

* ✅ **Version-controlled** → App + config changes are tracked in Git history.
* ✅ **Reproducible** → Anyone can recreate the same app by applying the CRD.
* ✅ **Auditable** → Clear record of *who changed what and when*.
* ✅ **GitOps-compliant** → The source of truth is Git, not the cluster.

In short:

> The Application CRD makes your application definitions **declarative**, ensuring they are part of your GitOps workflow - unlike UI or CLI, which are **imperative**.



Create or apply **online_shop_app.yml**

```yaml

apiVersion: argoproj.io/v1alpha1   # API group for ArgoCD resources
kind: Application                  # Resource type is "Application"
metadata:
  name: online-shop-app            # Name of this ArgoCD application
  namespace: argocd                # Must be created in the 'argocd' namespace
spec:
  project: default                 # ArgoCD Project (logical grouping of apps)
  source:
    repoURL: https://github.com/<your-username>/argocd-demos.git   # Git repo containing manifests
    targetRevision: main           # Git branch or tag (e.g., main, dev, release-1.0)
    path: declarative_approach/online_shop   # Path inside repo where manifests live
  destination:
    server: <argocd_cluster_server_url>   # Target cluster API
    namespace: default             # Namespace in which to deploy the app
  syncPolicy:                      # Defines how ArgoCD syncs the app
    automated:                     # Enable auto-sync
      prune: true                  # Delete resources removed from Git
      selfHeal: true               # Fix drift if resources are changed manually
```

Replace `<your-username>` with your GitHub username.

Replace `<argocd_cluster_server_url>` with the server URL from `argocd cluster list`.

---

### 4. Apply the Application CRD

```bash
kubectl apply -f online_shop_app.yml -n argocd
```

---

### 5. Verify in ArgoCD UI

* Go to **ArgoCD UI → Applications**.
* You should see `online-shop-app`.
* Status should be **Synced** and **Healthy**.

  ![online-shop-app](../output_images/image-1.png)

  ![online-shop-app-inside](../output_images/image-4.png)

---

### 6. Verify in Kubernetes

```bash
kubectl get pods -n default
kubectl get svc -n default
```

You should see:

* Online Shop pods running.
* `online-shop-service` exposing port **3000**.

  ![online-shop-pod-svc](../output_images/image-2.png)

---

### 7. Access the Online Shop App

1. Port-forward the service:

```bash
kubectl port-forward svc/online-shop-service 3000:3000 --address=0.0.0.0 &
```

2. Open inbound rule for port `3000` on your EC2 instance.

3. Access the app at:

```
http://<EC2-Public-IP>:3000
```

You should see your **Online Shop application UI**.

  ![online-shop-ui](../output_images/image-3.png)

---

## Testing

### 1. Make a Change in Git

1. Edit `online_shop_deployment.yml` → for example, increase replicas in the deployment manifest under `declarative_approach/online_shop`.
2. Commit & push:

```bash
git add .
git commit -m "Scale Online Shop replicas"
git push origin main
```

#### Observe in ArgoCD

* ArgoCD will detect the change in Git.
* Since `syncPolicy.automated` is enabled, it will **auto-sync**.
* Verify:

```bash
kubectl get pods -n default
```

Now additional Online Shop pods should be running.

  ![extra-pods-terminal](../output_images/image-5.png)

  ![extra-pods-ui](../output_images/image-6.png)

### 2. Test Self-Heal (Drift Correction Demo)

Even if someone makes changes **directly in the cluster**, ArgoCD will restore the Git-defined state.

#### a) Delete a pod manually

```bash
kubectl delete pod -l app=online-shop -n default
```

* Pod disappears → ReplicaSet recreates it.

    ![pod-recreating](../output_images/image-7.png)

* ArgoCD briefly shows **Progressing → Healthy** while reconciling.

    ![argocd-pod-recreate](../output_images/image-8.png)

    ![argocd-pod-recreate-ui](../output_images/image-10.png)


#### b) Scale deployment manually

```bash
kubectl scale deployment online-shop --replicas=1 -n default
```

* Cluster now runs 1 replica, but Git + Application CRD define 2 (or 4, if you changed it above).
* ArgoCD detects drift → automatically scales it back.

Verify:

```bash
kubectl get pods -n default
```

ArgoCD restores the replica count to match Git.

  ![argocd-selfheal](../output_images/image-9.png)

---

## Destroy 

For complete destroy, you can directly deleter the cluster by using below command:

```bash
kind delete cluster --name argocd-cluster
```

---

## Wrap-Up

* You successfully deployed an app via **Declarative GitOps** with ArgoCD.
* Key takeaway:

  * **Declarative approach = real GitOps** (version-controlled, auditable, reproducible).
  * UI and CLI are great for learning, but declarative is what you use in production.

Happy Learning!
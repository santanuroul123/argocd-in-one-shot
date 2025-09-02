# UI Approach with ArgoCD (NGINX Example)

In this approach, we will deploy an application using **ArgoCD UI** (imperative way).  
We’ll use a simple **NGINX Deployment + Service** to understand how ArgoCD manages GitOps from the UI.

---

## 📂 Directory Structure
```

ui_approach/nginx
├── nginx_deployment.yml
└── nginx_svc.yml

````

---

## Theory

- In the **UI approach**, we create applications directly from the ArgoCD dashboard.  
- This means ArgoCD generates the `Application` resource (CRD) inside the cluster for us.  
- The app definition lives **only in the cluster**, not in Git.  
- It’s quick and great for demos, but **not true GitOps** (since configs are not version-controlled).  

> ✅ Best practice: Use the **Declarative approach (CRDs in Git)** for production.  
> ❌ The UI method is best suited for learning and testing.  

---

## Prerequisites

Before you begin, ensure you have:  
1. A **Kind cluster** running  
2. **ArgoCD installed & running** (via Helm or manifests)
3. ArgoCD CLI Installed and logged In  
4. `kubectl` installed to interact with your cluster

---

## Steps to Deploy NGINX using ArgoCD UI

### 1. Fork and Clone the Repo

```bash
git clone https://github.com/Amitabh-DevOps/argocd-demos.git
cd argocd-demos/ui_approach/nginx
````

---

### 2. Access ArgoCD UI

Port-forward ArgoCD server:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443 --address=0.0.0.0 &
```

Open the UI: **[http://<instance_public_ip>:8080](http://<instance_public_ip>:8080)**
Login with:

* Username: `admin`
* Password: (fetched from secret: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`)

---

### 3. Connect your Git Repository

1. In ArgoCD UI, go to **Settings → Repositories**.
2. Click **Connect Repo**.
3. Fill in your Git repo details 
    * **Repository URL**: `<add_url_of_forked_repo_of_argocd_demos>`
    * **Username/Password**: (if private repo)
4. Click **Connect**.

You should see your repo listed under **Connected Repositories**.

![git-connection](../images/image.png)    
    

### 4. Adding Cluster to ArgoCD server

1. Run this command to your terminal:

```bash
argocd cluster add kind-argocd-cluster --name argocd-cluster --insecure
```

2. Verify using:

```bash
argocd cluster list
```

You should see something like this in ArgoCD Server:
    
![argocd-cluster](../images/image-1.png)
    

---

### 5. Create Application in ArgoCD UI

1. In ArgoCD UI, click **New App**.
2. Fill the fields:

   * **App Name**: `nginx-app`
   * **Project**: `default`
   * **Repository URL**: `<select_the_connected_repo>` 
   * **Revision**: `main`
   * **Path**: `ui_approach/nginx`
   * **Cluster**: `<select_added_cluster_url>`
   * **Namespace**: `default`

    ![application-form1](../images/image-2.png)

    ![application-form2](../images/image-3.png)

3. Leave Sync Policy as **Manual** for now.
4. Click **Create**.

---

### 6. Sync the Application

* The app will show as **OutOfSync**.
* Click **Sync → Synchronize**.
* ArgoCD will apply `nginx_deployment.yml` and `nginx_svc.yml` into the `default` namespace.

    ![outofsync](../images/image-4.png)

* After syncing, the status should change to **Synced** and **Healthy**.

    ![synced-nginx](../images/image-5.png)

---

### 7. Verify the Deployment

From CLI:

```bash
kubectl get pods -n default
kubectl get svc -n default
```

You should see:

* NGINX pods running (`nginx-deployment-xxxx`).
* `nginx-service` of type ClusterIP exposing port 80.

---

### 8. Access Nginx via browser

1. Port-forward the NGINX service:

```bash
kubectl port-forward svc/nginx-service 8081:80 --address=0.0.0.0 &
```

2. Open the inbound rule for port 8081 on your EC2 instance

3. Access the Nginx app at:

```bash
http://<EC2-Public-IP>:8081
```

You should see the default NGINX welcome page.

![nginx-welcome-page](../images/image-6.png)

---

## Wrap-Up

* You successfully deployed an app via **ArgoCD UI**.
* Key takeaway:

  * UI is **imperative** → fast for demos.
  * Real GitOps requires **declarative Application CRDs in Git** (covered in later approaches).


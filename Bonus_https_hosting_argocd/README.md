# ArgoCD HTTPS Hosting on EKS

Simple step-by-step guide to set up ArgoCD with HTTPS domain support on AWS EKS using direct `eksctl` commands.

## Directory

```
Bonus_https_hosting_argocd/
├── argocd-ingress.yaml     # Ingress with cert-manager annotations
├── letsencrypt-issuer.yaml # Let's Encrypt ClusterIssuer config
└── README.md               # This documentation
```

## Prerequisites

Before starting, ensure you have:

1. **AWS CLI** installed and configured(with policy of `eks` related, use `admin` for this guide.)

   ```bash
   aws configure
   ```

2. **eksctl** installed

   ```bash
   # Linux/WSL
   curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
   sudo mv /tmp/eksctl /usr/local/bin
   ```

3. **kubectl** installed

   ```bash
   kubectl version --client
   ```

4. **Helm** installed

   ```bash
   helm version
   ```

   [Install Guide](https://helm.sh/docs/intro/install/)

5. **Domain name** registered.

---

## Step-by-Step Setup

### Step 1: Create EKS Cluster

```bash
# Create EKS Cluster
eksctl create cluster --name argocd-cluster --region eu-west-1 --without-nodegroup
```

### Step 2: Verify Cluster Creation

```bash
eksctl get clusters --region eu-west-1
```

### Step 3: Associate IAM OIDC Provider

```bash
eksctl utils associate-iam-oidc-provider --region=eu-west-1 --cluster=argocd-cluster --approve
```

### Step 4: Create Node Group

```bash
eksctl create nodegroup \
--cluster=argocd-cluster \
--region=eu-west-1 \
--name=argocd-ng \
--node-type=t3.medium \
--nodes=2 \
--nodes-min=1 \
--nodes-max=3 \
--node-volume-size=20 \
--managed
```

### Step 5: Verify Cluster Access

```bash
# Update kubeconfig
aws eks update-kubeconfig --region eu-west-1 --name argocd-cluster

# Verify nodes
kubectl get nodes
```

### Step 6: Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
```

### Step 7: Install NGINX Ingress Controller

```bash
# Add Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install ingress controller
helm install my-ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.enableSSLPassthrough=true
```

### Step 8: Install cert-manager for SSL Certificates

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s
```

### Step 9: Configure Let's Encrypt and HTTPS

```bash
# Apply Let's Encrypt issuer (update email in letsencrypt-issuer.yaml first)
kubectl apply -f letsencrypt-issuer.yaml

# Apply ArgoCD ingress with SSL
kubectl apply -f argocd-ingress.yaml
```

### Step 10: Update DNS and Access ArgoCD

```bash
# Get the load balancer hostname(External IP)
kubectl get svc -n ingress-nginx

# Point your domain argocd.letsdeployit.com to this load balancer in DNS as a CNAME record
```

#### Production Access (after HTTPS setup):
- Access ArgoCD at `https://argocd.yourdomain.com`
- Username: `admin`
- Password: Use the initial admin secret, then change it

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🗑️ Cleanup

To destroy the cluster and all resources:

```bash
# Delete the entire cluster (this removes everything)
eksctl delete cluster --name argocd-cluster --region eu-west-1
```

This command will:
- 🗑️ Delete all applications and pods
- 🗑️ Remove node groups and EC2 instances  
- 🗑️ Delete VPC, subnets, and networking components
- �️ Remove load balancers and security groups
- ⚡ Complete cleanup in 10-15 minutes

## ⚡ Why eksctl over Terraform?

**Benefits of using eksctl for this setup:**

✅ **Faster Setup** - Creates cluster in ~15 minutes vs 20-25 with Terraform  
✅ **Purpose-Built** - Designed specifically for EKS management  
✅ **Simpler** - No state management, no complex configurations  
✅ **Automatic** - Handles VPC, subnets, security groups automatically  
✅ **Educational** - Shows actual EKS commands users will use  
✅ **Quick Iterations** - Easy to recreate for learning  

**Perfect for tutorials and learning!**

## 💰 Cost Breakdown (eu-west-1)

| Resource | Monthly Cost |
|----------|--------------|
| EKS Control Plane | ~$73 |
| 2x t3.medium nodes | ~$60 |
| NAT Gateway | ~$45 |
| Application Load Balancer | ~$20 |
| **Total** | **~$195-200/month** |

## � Verify SSL Certificate Creation

After applying the ingress, cert-manager will automatically request a Let's Encrypt certificate:

```bash
# Check certificate request status
kubectl get certificate -n argocd

# Check certificate details
kubectl describe certificate argocd-server-tls -n argocd

# Check cert-manager logs if issues
kubectl logs -n cert-manager deployment/cert-manager

# Verify the secret was created
kubectl get secret argocd-server-tls -n argocd
```

The certificate should show `Ready: True` status. If not, check:
- DNS is pointing to the load balancer
- Domain is accessible from the internet
- cert-manager pods are running

## �🛠 Troubleshooting

### Common Issues:

1. **AWS credentials not configured**
   ```bash
   aws configure
   ```

2. **Region mismatch**
   ```bash
   # Check current region
   aws configure get region
   # Should be: eu-west-1
   ```

3. **Cluster not accessible**
   ```bash
   # Re-configure kubectl
   aws eks update-kubeconfig --region eu-west-1 --name argocd-cluster
   ```

4. **ArgoCD pods not starting**
   ```bash
   # Check pod status
   kubectl get pods -n argocd
   
   # Check node resources
   kubectl top nodes
   ```

5. **SSL Certificate not issuing**
   ```bash
   # Check certificate status
   kubectl get certificate -n argocd
   
   # Check certificate request details
   kubectl describe certificaterequest -n argocd
   
   # Check Let's Encrypt challenge
   kubectl get challenge -n argocd
   
   # Check cert-manager logs
   kubectl logs -n cert-manager deployment/cert-manager
   ```

6. **Domain not resolving**
   ```bash
   # Test DNS resolution
   nslookup argocd.letsdeployit.com
   
   # Check if domain points to load balancer
   kubectl get svc -n ingress-nginx
   ```

### Useful Commands:

```bash
# Check cluster status
kubectl get nodes

# Check ArgoCD pods
kubectl get pods -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Check ingress
kubectl get ingress -n argocd

# View load balancer details
kubectl get svc -n ingress-nginx

# Check SSL certificate status
kubectl get certificate -n argocd

# View certificate details
kubectl describe certificate argocd-server-tls -n argocd

# Check cert-manager components
kubectl get pods -n cert-manager
```

## 🔒 Security Best Practices

- ✅ EKS cluster uses private subnets for worker nodes
- ✅ IRSA (IAM Roles for Service Accounts) enabled
- ✅ Network ACLs and Security Groups configured
- ⚠️ Change default ArgoCD admin password immediately
- ⚠️ Configure RBAC for ArgoCD users
- ⚠️ Enable audit logging for production use

## 🎯 Next Steps After Setup

1. **Configure ArgoCD RBAC** for team access
2. **Set up monitoring** with Prometheus/Grafana
3. **Configure backup** for ArgoCD configurations
4. **Set up GitOps workflows** with your application repositories
5. **Enable notifications** for deployment status
# ArgoCD HTTPS Hosting on EKS

This directory contains everything needed to set up ArgoCD with HTTPS domain support on AWS EKS.

## 📁 Directory Structure

```
Bonus_https_hosting_argocd/
├── setup-eks.sh           # Automated EKS cluster setup
├── destroy-eks.sh         # Safe cluster destruction
├── argocd-ingress.yaml    # Ingress with cert-manager annotations
├── letsencrypt-issuer.yaml # Let's Encrypt ClusterIssuer config
├── README.md              # This documentation
└── terraform/             # Terraform infrastructure code
    ├── main.tf            # Core EKS and VPC configuration
    ├── variables.tf       # Input variables (eu-west-1)
    └── outputs.tf         # Output values
```

## 📋 Prerequisites

Before starting, ensure you have:

1. **AWS CLI** installed and configured ( with **AWS IAM permissions** for EKS, VPC, EC2, and IAM operations)
   ```bash
   aws configure
   ```

2. **Terraform** installed (>= 1.0)
   ```bash
   terraform --version
   ```

3. **kubectl** installed (for cluster interaction)
   ```bash
   kubectl version --client
   ```

5. **Domain name** registered and managed in Route 53 (for HTTPS setup)

## 🚀 Quick Start

### 1. Setup EKS Cluster

```bash
# Navigate to this directory
cd Bonus_https_hosting_argocd

# Make scripts executable (Linux/Mac/WSL)
chmod +x setup-eks.sh destroy-eks.sh

# Run setup script
./setup-eks.sh
```

The script will:
- ✅ Validate prerequisites (AWS CLI, Terraform, credentials)
- ✅ Show cost estimates (~$175-180/month)
- ✅ Create EKS cluster in `eu-west-1`
- ✅ Set up VPC with public/private subnets
- ✅ Configure 2x t3.medium worker nodes

### 2. Connect to Cluster

After successful setup:
```bash
# Configure kubectl (command provided by setup script)
aws eks update-kubeconfig --region eu-west-1 --name argocd-cluster

# Verify connection
kubectl get nodes
```

### 3. Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready (may take 2-3 minutes)
kubectl wait --for=condition=ready pod --all -n argocd --timeout=300s
```

### 4. Setup HTTPS with Automatic SSL Certificates

#### Install Required Components

```bash
# Install NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install my-ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.enableSSLPassthrough=true

# Install cert-manager for automatic SSL certificates
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s
```

#### Configure Let's Encrypt and Ingress

```bash
# Create Let's Encrypt ClusterIssuer (update email in letsencrypt-issuer.yaml)
kubectl apply -f letsencrypt-issuer.yaml

# Apply ArgoCD ingress with automatic SSL
kubectl apply -f argocd-ingress.yaml
```

#### Update DNS
Point your domain `argocd.letsdeployit.com` to the ingress load balancer:
```bash
# Get the load balancer hostname
kubectl get svc -n ingress-nginx
```

### 5. Access ArgoCD

#### Temporary Access (for initial setup):
```bash
# Port forward to localhost
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access at https://localhost:8080
# Username: admin
# Password: (output from above command)
```

#### Production Access (after HTTPS setup):
- Access ArgoCD at `https://argocd.yourdomain.com`
- Username: `admin`
- Password: Use the initial admin secret, then change it

## 🗑️ Cleanup

To destroy the entire infrastructure:

```bash
# From the Bonus_https_hosting_argocd directory
./destroy-eks.sh
```

The script will:
- ⚠️ Show multiple confirmation prompts
- 🧹 Clean up ArgoCD applications first
- 💥 Destroy all AWS infrastructure
- 🗂️ Optionally remove local Terraform state

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
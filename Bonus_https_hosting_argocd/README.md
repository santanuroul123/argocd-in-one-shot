# ArgoCD HTTPS Setup Guide with Ingress

## Overview

This guide shows you how to setup **HTTPS access** for ArgoCD using **NGINX Ingress Controller**. We'll use the **SSL-Passthrough** method, which is the simplest and most commonly used approach.

Read more: [HTTPS](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#kubernetesingress-nginx)

## Prerequisites

- Running Kubernetes cluster
- ArgoCD installed and running
- Domain name 

---

## Step 1: Install NGINX Ingress Controller

```bash
# Add the ingress-nginx repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install ingress-nginx
helm install my-ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.enableSSLPassthrough=true
```

**Important:** The `--set controller.enableSSLPassthrough=true` flag is **required** for ArgoCD HTTPS to work.

### Verify Installation

```bash
# Check if ingress controller is running
kubectl get pods -n ingress-nginx

# Get the external IP (for LoadBalancer type)
kubectl get svc -n ingress-nginx
```

---

## Step 2: Configure Domain/DNS

### Using a Domain Name
- Point your domain (e.g., `argocd.yourdomain.com`) to the **EXTERNAL-IP** of the ingress controller
- Update your DNS records (A record)

---

## Step 3: Create ArgoCD Ingress with SSL-Passthrough

Create the ingress configuration:

Use: [argocd-ingress.yaml](argocd-ingress.yaml)

### Apply the Ingress

```bash
kubectl apply -f argocd-ingress.yaml
```

---

## Step 4: Verify HTTPS Setup

### Check Ingress Status

```bash
# Verify ingress is created
kubectl get ingress -n argocd

# Check ingress details
kubectl describe ingress argocd-server-ingress -n argocd
```

### Access ArgoCD

1. **Open your browser** and go to: `https://argocd.yourdomain.com`
2. **Accept certificate warning** (if using self-signed certificates)
3. **Login** with admin credentials

### Test CLI Access

```bash
# Login via CLI (should work with HTTPS)
argocd login argocd.yourdomain.com

# Test commands
argocd app list
```

---

## Optional: Add Custom TLS Certificate

If you have your own SSL certificate:

### Step 1: Create TLS Secret

```bash
# Create secret from certificate files
kubectl create secret tls argocd-server-tls \
  --cert=path/to/tls.cert \
  --key=path/to/tls.key \
  -n argocd
```

### Step 2: Update Ingress

The ingress above already references `argocd-server-tls` secret, so it will automatically use your custom certificate.

---

## Optional: Use Let's Encrypt (cert-manager)

For automatic SSL certificates:

### Step 1: Install cert-manager

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml
```

### Step 2: Create ClusterIssuer

```yaml
# letsencrypt-issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@example.com  # Replace with your email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

### Step 3: Update Ingress for Let's Encrypt

```yaml
# argocd-ingress-letsencrypt.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  rules:
  - host: argocd.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: https
  tls:
  - hosts:
    - argocd.yourdomain.com
    secretName: argocd-server-tls
```

---

## Troubleshooting

### Common Issues

**1. SSL-Passthrough not working:**
- Ensure `--enable-ssl-passthrough=true` is set in ingress controller
- Check ingress controller logs: `kubectl logs -n ingress-nginx deployment/my-ingress-nginx-controller`

**2. Certificate errors:**
- For self-signed certificates, expect browser warnings
- For Let's Encrypt, check cert-manager logs: `kubectl logs -n cert-manager deployment/cert-manager`

**3. Redirect loops:**
- Ensure `nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"` annotation is present
- ArgoCD should **NOT** be running in insecure mode for SSL-passthrough

### Verification Commands

```bash
# Check certificate details
kubectl get secret argocd-server-tls -n argocd -o yaml

# Test SSL connection
openssl s_client -connect argocd.yourdomain.com:443 -servername argocd.yourdomain.com

# Check ingress controller SSL passthrough
kubectl logs -n ingress-nginx deployment/my-ingress-nginx-controller | grep ssl-passthrough
```

---

## Summary

✅ **NGINX Ingress Controller** installed with SSL-Passthrough enabled  
✅ **Ingress resource** created with proper annotations  
✅ **DNS/Domain** pointing to ingress controller  
✅ **HTTPS access** working for both UI and CLI  
✅ **Optional TLS certificate** configured  

Your ArgoCD is now accessible securely over HTTPS! 🔒

---

## Key Points

- **SSL-Passthrough** is the simplest method for ArgoCD HTTPS
- **No need to disable TLS** in ArgoCD server with this approach
- **Works with both UI and CLI** seamlessly
- **Custom certificates** and **Let's Encrypt** are optional enhancements
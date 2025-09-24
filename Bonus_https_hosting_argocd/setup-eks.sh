#!/bin/bash

# EKS Cluster Setup Script
# This script will provision the EKS cluster and related infrastructure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "🚀 Starting EKS Cluster Setup..."

# Check if we're in the right directory
if [ ! -d "terraform" ]; then
    print_error "terraform directory not found. Please run this script from the Bonus_https_hosting_argocd directory."
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_warning "kubectl is not installed. You'll need it to interact with the cluster."
    print_status "Install kubectl: https://kubernetes.io/docs/tasks/tools/"
fi

# Check AWS credentials
print_status "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region 2>/dev/null || echo "eu-west-1")

print_success "AWS Account ID: $ACCOUNT_ID"
print_success "AWS Region: $REGION"

# Confirm before proceeding
echo
print_warning "This will create the following resources in AWS:"
echo "  - EKS Cluster (argocd-cluster)"
echo "  - VPC with public/private subnets"
echo "  - NAT Gateway"
echo "  - EKS Node Group (2x t3.medium instances)"
echo "  - Estimated cost: ~$175-180/month"
echo
read -p "Do you want to proceed? (y/N): " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Operation cancelled."
    exit 0
fi

# Change to terraform directory
cd terraform

# Initialize Terraform
print_status "Initializing Terraform..."
if terraform init; then
    print_success "Terraform initialized successfully"
else
    print_error "Failed to initialize Terraform"
    exit 1
fi

# Validate Terraform configuration
print_status "Validating Terraform configuration..."
if terraform validate; then
    print_success "Terraform configuration is valid"
else
    print_error "Terraform configuration validation failed"
    exit 1
fi

# Plan Terraform deployment
print_status "Creating Terraform plan..."
if terraform plan -out=tfplan; then
    print_success "Terraform plan created successfully"
else
    print_error "Failed to create Terraform plan"
    exit 1
fi

# Apply Terraform configuration
print_status "Applying Terraform configuration..."
print_warning "This will take 10-15 minutes to complete..."

if terraform apply tfplan; then
    print_success "✅ EKS cluster created successfully!"
else
    print_error "Failed to apply Terraform configuration"
    exit 1
fi

# Clean up plan file
rm -f tfplan

# Get cluster information
CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "argocd-cluster")
KUBECTL_CONFIG=$(terraform output -raw configure_kubectl 2>/dev/null || echo "aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME")

# Return to parent directory
cd ..

print_success "🎉 EKS Cluster Setup Complete!"
echo
print_status "Next steps:"
echo "1. Configure kubectl to connect to your cluster:"
echo "   $KUBECTL_CONFIG"
echo
echo "2. Verify cluster access:"
echo "   kubectl get nodes"
echo
echo "3. Install ArgoCD, NGINX Ingress, and cert-manager:"
echo "   # Install ArgoCD"
echo "   kubectl create namespace argocd"
echo "   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
echo
echo "   # Install NGINX Ingress Controller"
echo "   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx"
echo "   helm repo update"
echo "   helm install my-ingress-nginx ingress-nginx/ingress-nginx \\"
echo "     --namespace ingress-nginx --create-namespace \\"
echo "     --set controller.enableSSLPassthrough=true"
echo
echo "   # Install cert-manager for automatic SSL certificates"
echo "   kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml"
echo
echo "   # Wait for cert-manager to be ready"
echo "   kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=cert-manager -n cert-manager --timeout=300s"
echo
echo "   # Create Let's Encrypt issuer"
echo "   kubectl apply -f letsencrypt-issuer.yaml"
echo
echo "   # Apply ArgoCD ingress with automatic SSL"
echo "   kubectl apply -f argocd-ingress.yaml"
echo
echo "4. Access ArgoCD (temporary - while DNS/SSL is setting up):"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo
echo "5. After ingress is ready, access via HTTPS:"
echo "   https://argocd.letsdeployit.com"
echo
print_status "⚠️  Remember to update your DNS to point argocd.letsdeployit.com to the ingress load balancer!"
print_status "Check README.md for detailed configuration and troubleshooting."
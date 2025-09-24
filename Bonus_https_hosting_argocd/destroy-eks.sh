#!/bin/bash

# EKS Cluster Destroy Script
# This script will safely destroy the EKS cluster and all related infrastructure

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

print_status "🔥 Starting EKS Cluster Destruction..."

# Check if we're in the right directory
if [ ! -d "terraform" ]; then
    print_error "terraform directory not found. Please run this script from the Bonus_https_hosting_argocd directory."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Change to terraform directory to check state
cd terraform

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
    print_warning "No Terraform state found. The infrastructure may not exist or was created elsewhere."
    read -p "Do you want to continue anyway? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled."
        exit 0
    fi
fi

# Get current cluster information if available
CLUSTER_NAME=""
if terraform output cluster_name &> /dev/null; then
    CLUSTER_NAME=$(terraform output -raw cluster_name 2>/dev/null || echo "")
fi

# Return to parent directory for user interaction
cd ..

# Warning about destruction
echo
print_warning "⚠️  DANGER: This will PERMANENTLY DESTROY the following resources:"
echo "  - EKS Cluster: ${CLUSTER_NAME:-argocd-cluster}"
echo "  - All running pods and applications (including ArgoCD)"
echo "  - VPC and networking components"
echo "  - Node groups and EC2 instances"
echo "  - NAT Gateway (will stop charges)"
echo
print_error "🚨 THIS ACTION CANNOT BE UNDONE! 🚨"
echo
print_warning "Make sure you have:"
echo "  ✓ Backed up any important data"
echo "  ✓ Exported any configurations you need"
echo "  ✓ Saved any persistent volumes data"
echo "  ✓ Downloaded ArgoCD application manifests"
echo

# First confirmation
read -p "Are you absolutely sure you want to destroy the EKS cluster? (type 'yes' to confirm): " -r
if [[ $REPLY != "yes" ]]; then
    print_status "Operation cancelled. Cluster is safe."
    exit 0
fi

# Second confirmation
echo
print_error "Last chance to cancel!"
read -p "Type 'DESTROY' to confirm destruction: " -r
if [[ $REPLY != "DESTROY" ]]; then
    print_status "Operation cancelled. Cluster is safe."
    exit 0
fi

# Optional: Clean up ArgoCD applications first (if kubectl is available)
if command -v kubectl &> /dev/null && kubectl cluster-info &> /dev/null; then
    print_status "Detected active kubectl connection. Cleaning up ArgoCD applications..."
    
    # Delete ArgoCD applications to prevent hanging resources
    kubectl get applications -n argocd --no-headers 2>/dev/null | awk '{print $1}' | xargs -I {} kubectl delete application {} -n argocd --ignore-not-found=true || true
    
    # Delete ArgoCD namespace
    kubectl delete namespace argocd --ignore-not-found=true || true
    
    print_status "ArgoCD cleanup attempted (non-blocking)"
    sleep 5
fi

# Change back to terraform directory for operations
cd terraform

# Initialize Terraform (in case it's not initialized)
print_status "Ensuring Terraform is initialized..."
terraform init -input=false

# Create destroy plan
print_status "Creating destruction plan..."
if terraform plan -destroy -out=destroy.tfplan; then
    print_success "Destruction plan created successfully"
else
    print_error "Failed to create destruction plan"
    exit 1
fi

# Show what will be destroyed
print_status "Resources to be destroyed:"
terraform show -no-color destroy.tfplan | grep -E "will be destroyed|will be deleted" || true

echo
print_warning "Starting destruction in 10 seconds... Press Ctrl+C to cancel now!"
for i in {10..1}; do
    echo -ne "\rDestroying in $i seconds..."
    sleep 1
done
echo

# Execute destruction
print_status "Destroying infrastructure..."
print_warning "This will take 10-15 minutes to complete..."

if terraform apply destroy.tfplan; then
    print_success "✅ EKS cluster destroyed successfully!"
else
    print_error "Failed to destroy some resources. Check the output above."
    print_warning "You may need to manually clean up remaining resources in AWS Console"
    exit 1
fi

# Clean up plan files
rm -f destroy.tfplan tfplan

# Clean up terraform state (optional)
read -p "Do you want to remove local Terraform state files? (y/N): " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f terraform.tfstate terraform.tfstate.backup
    rm -rf .terraform/
    print_success "Local Terraform state cleaned up"
fi

# Return to parent directory
cd ..

print_success "🎉 Destruction Complete!"
echo
print_status "All AWS resources have been destroyed and charges stopped."
print_status "You can now safely remove this directory or run ./setup-eks.sh to create a new cluster."
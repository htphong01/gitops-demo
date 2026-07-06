#!/usr/bin/env bash
# bootstrap-eks.sh
# Automates EKS Cluster creation via Terraform and installs GitOps components (ArgoCD, Sealed Secrets).

set -euo pipefail

# Base path of the repository
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  echo "Usage: $0 -e <dev|staging|prod> [-p <aws_profile>] [-r <aws_region>]"
  echo "  -e: Target environment (required)"
  echo "  -p: AWS Profile to use (optional)"
  echo "  -r: AWS Region to override (optional)"
  exit 1
}

ENV=""
PROFILE=""
REGION=""

# Parse options
while getopts "e:p:r:" opt; do
  case ${opt} in
    e ) ENV=$OPTARG ;;
    p ) PROFILE=$OPTARG ;;
    r ) REGION=$OPTARG ;;
    * ) usage ;;
  esac
done

if [[ -z "$ENV" ]]; then
  echo "Error: Target environment (-e) is required."
  usage
fi

if [[ "$ENV" != "dev" && "$ENV" != "staging" && "$ENV" != "prod" ]]; then
  echo "Error: Invalid environment. Must be one of: dev, staging, prod."
  usage
fi

# Configure AWS Profile if provided
if [[ -n "$PROFILE" ]]; then
  echo "=== Using AWS Profile: $PROFILE ==="
  export AWS_PROFILE="$PROFILE"
fi

# Configure AWS Region override if provided
if [[ -n "$REGION" ]]; then
  echo "=== Overriding AWS Region: $REGION ==="
  export AWS_DEFAULT_REGION="$REGION"
  export TF_VAR_aws_region="$REGION"
else
  # Retrieve region from terraform.tfvars or default to ap-southeast-1
  REGION=$(grep -E '^aws_region' "$REPO_ROOT/terraform/environments/$ENV/terraform.tfvars" | awk -F'"' '{print $2}')
  if [[ -z "$REGION" ]]; then
    REGION="ap-southeast-1"
  fi
  export AWS_DEFAULT_REGION="$REGION"
fi

# Check AWS authentication
echo "=== Verifying AWS Credentials ==="
if ! aws sts get-caller-identity > /dev/null 2>&1; then
  echo "Error: AWS credentials verification failed. Please check your AWS credentials/profile."
  exit 1
fi
echo "AWS authentication successful."

echo "=== 1. Building EKS Cluster ($ENV) using Terraform ==="
cd "$REPO_ROOT/terraform/environments/$ENV"
terraform init
terraform apply -auto-approve

echo "=== 2. Exporting Kubeconfig ==="
CLUSTER_NAME=$(terraform output -raw cluster_id)
KUBECONFIG_PATH="$REPO_ROOT/terraform/environments/$ENV/kubeconfig.yaml"
export KUBECONFIG="$KUBECONFIG_PATH"

aws eks update-kubeconfig \
  --name "$CLUSTER_NAME" \
  --region "$REGION" \
  --kubeconfig "$KUBECONFIG_PATH"

echo "=== 3. Installing Sealed Secrets Controller ==="
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.22.0/controller.yaml

echo "=== 4. Installing NGINX Ingress Controller for AWS EKS ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml

echo "=== Waiting for NGINX Ingress Controller to become ready ==="
kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=180s

echo "=== 5. Installing ArgoCD ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Waiting for ArgoCD components to become ready ==="
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s
kubectl rollout status deployment/argocd-repo-server -n argocd --timeout=180s
kubectl rollout status deployment/argocd-redis -n argocd --timeout=180s
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=180s

echo "=== 6. Applying GitOps ApplicationSet ==="
kubectl apply -f "$REPO_ROOT/argocd/applicationset.yaml"

echo "=========================================================================="
echo " 🎉 EKS GitOps Cluster Bootstrap Completed Successfully for $ENV!"
echo " Kubeconfig file is written to: $KUBECONFIG_PATH"
echo " To manage this cluster, run:"
echo "   export KUBECONFIG=$KUBECONFIG_PATH"
echo "=========================================================================="

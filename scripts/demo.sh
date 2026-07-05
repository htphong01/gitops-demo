#!/bin/bash
# demo.sh
# Automates local workstation GitOps infrastructure setup using Kind, ArgoCD, and Sealed Secrets.

set -e

# Base path of the repository
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== 1. Building local Kind Cluster using Terraform ==="
cd "$REPO_ROOT/terraform/environments/local"
terraform init
terraform apply -auto-approve

echo "=== 2. Exporting Kubeconfig ==="
export KUBECONFIG="$REPO_ROOT/terraform/environments/local/kubeconfig.yaml"
kubectl cluster-info

echo "=== 3. Restoring Sealed Secrets Private Key ==="
# Ensure kube-system namespace exists before applying secret key
kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f "$REPO_ROOT/scripts/local-sealed-secret-key.yaml"

echo "=== 4. Installing Sealed Secrets Controller ==="
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.22.0/controller.yaml

echo "=== 5. Installing NGINX Ingress Controller for Kind ==="
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "=== Waiting for NGINX Ingress Controller to become ready (this can take 1-2 minutes) ==="
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

echo "=== 6. Installing ArgoCD ==="
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== Waiting for ArgoCD API Server to become ready ==="
kubectl wait --namespace argocd \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=argocd-server \
  --timeout=180s

echo "=== 7. Applying GitOps ApplicationSet ==="
# Note: Ensure you fork this repository and update repoURL in applicationset.yaml to point to your fork if working on GitHub.
# For local evaluation, you can also set the repoURL to a local git repository.
cd "$REPO_ROOT"
kubectl apply -f argocd/applicationset.yaml

echo "=========================================================================="
echo " 🎉 Local GitOps Demo Cluster Setup Successfully!"
echo " Access the mock service locally at: http://localhost"
echo " "
echo " Check sync progress using: kubectl get pods -n api-gateway-local"
echo "=========================================================================="

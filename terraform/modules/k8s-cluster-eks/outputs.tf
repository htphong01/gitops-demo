# outputs.tf (Module: k8s-cluster)
# Exposes cluster endpoints and configurations to be referenced by providers (Helm/Kubernetes) or CI pipelines.

output "cluster_id" {
  description = "The ID of the EKS Cluster"
  value       = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  description = "The API Endpoint to connect to the Kubernetes API server"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate authority data for cluster authentication"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

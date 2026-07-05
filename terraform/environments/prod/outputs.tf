# outputs.tf
# Exposes cluster outputs at the Production environment level.

output "cluster_id" {
  description = "The ID of the EKS Cluster"
  value       = module.k8s_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "The API Endpoint to connect to the EKS Cluster"
  value       = module.k8s_cluster.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "CA certificate authority data"
  value       = module.k8s_cluster.cluster_certificate_authority_data
}

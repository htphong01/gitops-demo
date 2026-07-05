# outputs.tf
# Exposes cluster outputs at the local environment level.

output "cluster_name" {
  description = "The name of the local Kind cluster"
  value       = module.k8s_cluster.cluster_name
}

output "kubeconfig" {
  description = "The kubeconfig of the local Kind cluster"
  value       = module.k8s_cluster.kubeconfig
  sensitive   = true
}

output "endpoint" {
  description = "The local Kubernetes API server endpoint"
  value       = module.k8s_cluster.endpoint
}

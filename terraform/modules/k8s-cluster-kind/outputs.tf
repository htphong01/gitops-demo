# outputs.tf (Module: k8s-cluster-kind)
# Exports cluster configurations for local tooling access.

output "cluster_name" {
  description = "The name of the local Kind cluster"
  value       = kind_cluster.this.name
}

output "kubeconfig" {
  description = "The raw kubeconfig content of the Kind cluster"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "endpoint" {
  description = "The Kubernetes API server endpoint"
  value       = kind_cluster.this.endpoint
}

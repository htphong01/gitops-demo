# variables.tf (Module: k8s-cluster-kind)
# Defines configuration variables for setting up a local Kind cluster.

variable "cluster_name" {
  description = "The name of the local Kind cluster"
  type        = string
  default     = "kind-local"
}

variable "node_image" {
  description = "The node image version for the Kind cluster (matches Kubernetes version)"
  type        = string
  default     = "kindest/node:v1.27.3"
}

variable "worker_nodes" {
  description = "Number of worker nodes for the Kind cluster"
  type        = number
  default     = 0
}

variable "kubeconfig_path" {
  description = "The local path where the kubeconfig file should be written"
  type        = string
}

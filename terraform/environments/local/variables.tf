# variables.tf
# Input variable definitions for the local environment.

variable "cluster_name" {
  description = "The name of the local Kind cluster"
  type        = string
}

variable "node_image" {
  description = "The Kubernetes node image for the Kind cluster"
  type        = string
}

variable "worker_nodes" {
  description = "Number of worker nodes for the Kind cluster"
  type        = number
}

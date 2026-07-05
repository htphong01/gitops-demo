# variables.tf (Module: k8s-cluster)
# Input variables definition for the k8s-cluster module to ensure high reusability.

variable "cluster_name" {
  description = "The name of the Kubernetes Cluster"
  type        = string
}

variable "environment" {
  description = "Target deployment environment (dev, staging, prod)"
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnet IDs where the EKS Cluster and Node Groups will be provisioned"
  type        = list(string)
  default     = ["subnet-12345678", "subnet-87654321"] # Mock defaults for demo/test purposes
}

variable "node_instance_type" {
  description = "The instance type for the worker nodes (e.g., t3.medium, t3.large)"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of active worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

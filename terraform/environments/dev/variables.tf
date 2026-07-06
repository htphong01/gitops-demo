# variables.tf
# Variable declarations for the Dev environment.

variable "aws_region" {
  description = "Target AWS Region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Target environment name"
  type        = string
}

variable "cluster_name" {
  description = "The EKS cluster name"
  type        = string
}

variable "subnet_ids" {
  description = "List of VPC subnets"
  type        = list(string)
}

variable "node_instance_type" {
  description = "Worker node instance type"
  type        = string
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "project" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "gitops-demo"
}

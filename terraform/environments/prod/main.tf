# main.tf
# Invokes the EKS cluster module for the Production environment.

module "k8s_cluster" {
  source = "../../modules/k8s-cluster-eks"

  cluster_name       = var.cluster_name
  project            = var.project
  environment        = var.environment
  subnet_ids         = var.subnet_ids
  node_instance_type = var.node_instance_type
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size
}

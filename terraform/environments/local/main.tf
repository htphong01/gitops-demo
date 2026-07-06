# main.tf
# Invokes the k8s-cluster-kind module to provision a local Kind cluster.

module "k8s_cluster" {
  source = "../../modules/k8s-cluster-kind"

  cluster_name    = var.cluster_name
  node_image      = var.node_image
  worker_nodes    = var.worker_nodes
  kubeconfig_path = "${path.cwd}/${var.kubeconfig_path}"
}

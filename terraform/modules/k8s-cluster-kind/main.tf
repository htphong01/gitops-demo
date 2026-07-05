# main.tf (Module: k8s-cluster-kind)
# Provisions a local Kind Kubernetes cluster and exports its kubeconfig locally.

terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }
}

# Kind cluster resource creation
resource "kind_cluster" "this" {
  name           = var.cluster_name
  node_image     = var.node_image
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    # Always provision at least one control-plane node
    node {
      role = "control-plane"
    }

    # Dynamically scale worker nodes based on worker_nodes variable
    dynamic "node" {
      for_each = range(var.worker_nodes)
      content {
        role = "worker"
      }
    }
  }
}

# Automatically output the kubeconfig to a local file in the environment directory for seamless DX
resource "local_file" "kubeconfig" {
  content  = kind_cluster.this.kubeconfig
  filename = "${path.module}/../../kubeconfig.yaml"
}

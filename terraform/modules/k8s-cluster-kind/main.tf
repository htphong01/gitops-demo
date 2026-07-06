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

    # Always provision at least one control-plane node with ingress-ready configurations
    node {
      role = "control-plane"

      kubeadm_config_patches = [
        "kind: InitConfiguration\nnodeRegistration:\n  kubeletExtraArgs:\n    node-labels: \"ingress-ready=true\"\n"
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
        listen_address = "127.0.0.1"
      }

      extra_port_mappings {
        container_port = 443
        host_port      = 443
        listen_address = "127.0.0.1"
      }
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
  filename = var.kubeconfig_path
}

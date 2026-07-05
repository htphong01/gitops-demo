# providers.tf
# Configures Terraform local state and the required kind and local file providers.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kind = {
      source  = "tehcnosoft/kind"
      version = "~> 0.6"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
  }

  # Local backend stores state files directly on the local disk.
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "kind" {}

# providers.tf
# Configures the S3 remote backend and AWS provider for the Dev environment.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configures S3 backend with unique state key for the Dev environment
  backend "s3" {
    bucket         = "mycompany-gitops-tfstate"
    key            = "k8s-cluster/dev/terraform.tfstate" # Isolated state key per env
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "mycompany-gitops-tflocks" # Enables state locking for concurrency safety
  }
}

provider "aws" {
  region = var.aws_region
}

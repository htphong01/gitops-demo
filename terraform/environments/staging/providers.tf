# providers.tf
# Configures the S3 remote backend and AWS provider for the Staging environment.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configures S3 backend with unique state key for the Staging environment
  backend "s3" {
    bucket         = "mycompany-gitops-tfstate"
    key            = "k8s-cluster/staging/terraform.tfstate" # Isolated state key per env
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "mycompany-gitops-tflocks" # Enables state locking for concurrency safety
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      project     = var.project
      environment = var.environment
    }
  }
}

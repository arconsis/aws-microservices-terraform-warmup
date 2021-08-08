terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.53"
    }
    kubernetes = {
      source  = "kubernetes"
      version = "~> 2.4.1"
    }
  }

  required_version = ">= 1.0"
}

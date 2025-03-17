# Configure AWS Provider
provider "aws" {
  region  = "ap-southeast-1"
  profile = "infra"
}

# Configure required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
} 

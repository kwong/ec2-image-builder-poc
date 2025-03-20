# Configure AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

# Configure required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
  cloud {
    organization = "Ollion_Trail"
    workspaces {
      name = "ec2-image-builder-poc"
    }
  }
}

provider "random" {}

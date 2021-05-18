terraform {
  required_providers {
    aws = {
      version = ">= 3.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  prefix = "iac-micro-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = "iac-micro"
    Repository  = "https://github.com/JDavidGuzman/iac-micro"
    Owner       = "David Guzmán"
    ManagedBy   = "Terraform"
  }
}

data "aws_region" "current" {}
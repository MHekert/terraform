terraform {
  required_version = "~> 0.13.1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.region
  version = "~> 3.4"
}

data "aws_caller_identity" "current" {}

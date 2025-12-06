provider "aws" {
  region = "us-east-1"
}

data "aws_region" "current" {}

terraform {
  backend "s3" {
    bucket = "flash-msg-tf-state-vitor"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

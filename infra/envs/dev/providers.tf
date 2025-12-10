terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
 
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # On posera des tags par défaut dès maintenant
  default_tags {
    tags = {
      Project = local.project
      Env     = local.env
    }
  }
}

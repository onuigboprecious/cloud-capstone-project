terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Credentials can be supplied via environment variables:
  #   AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
}

provider "github" {
  owner = "onuigboprecious"
  # Reads token from GITHUB_TOKEN environment variable
}

resource "github_actions_secret" "deploy_host" {
  repository  = "cloud-capstone-project"
  secret_name = "DEPLOY_HOST"
  value       = aws_eip.formflow.public_ip
}

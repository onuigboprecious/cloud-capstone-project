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
  # Credentials are taken from the environment (AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY)
}

provider "github" {
  owner = "onuigboprecious"
  # Token is read from GITHUB_TOKEN env var
}

# Expose the public IP of the instance as a GitHub Actions secret
resource "github_actions_secret" "deploy_host" {
  repository   = "cloud-capstone-project"
  secret_name  = "DEPLOY_HOST"
  value        = aws_eip.formflow.public_ip
}

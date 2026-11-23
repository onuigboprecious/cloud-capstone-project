terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "azurerm" {
  features {}
  # Or set the ARM_SUBSCRIPTION_ID environment variable instead
  subscription_id = var.subscription_id
}

provider "github" {
  owner = "onuigboprecious"
  # Reads token from GITHUB_TOKEN environment variable
}

resource "github_actions_secret" "deploy_host" {
  repository  = "cloud-capstone-project"
  secret_name = "DEPLOY_HOST"
  value       = azurerm_public_ip.formflow.ip_address
}

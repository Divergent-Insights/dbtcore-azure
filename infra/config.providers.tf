# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.12.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }
    null = {
      version = "~> 3.0.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  #  tenant_id       = "xxxxx"
  #  subscription_id = "xxxxx"
  #  client_id       = "xxxxx"
  #  client_secret   = "xxxxx"

  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

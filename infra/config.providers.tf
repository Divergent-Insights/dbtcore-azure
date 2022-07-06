# © 2022 Divergent Insights Pty Ltd - <info@divergentinsights.com.au>


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.12.0"
    }
    null = {
      version = "~> 3.0.0"
    }
  }
  required_version = "~> 1.2.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

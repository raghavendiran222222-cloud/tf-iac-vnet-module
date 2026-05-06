
terraform {
  required_version = ">= 1.15.1, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.71"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.9"
    }
  }
}

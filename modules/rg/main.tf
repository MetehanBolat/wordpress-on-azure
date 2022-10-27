### Resource Group Module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.28.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

## Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resourcePrefix}-rg"
  location = var.location
}
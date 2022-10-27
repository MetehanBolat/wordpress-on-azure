### User-Assigned Identity Module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.28.0"
    }
  }
}

provider "azurerm" {
  features {}
}

## User-Assigned Identity
resource "azurerm_user_assigned_identity" "id" {
  name                = "${var.resourcePrefix}-id"
  resource_group_name = var.resourceGroupName
  location            = var.location
}
### App Service Plan Module
provider "azurerm" {
  features {}
}

## ${var.osType} Service Plan
resource "azurerm_service_plan" "sp" {
  name                     = "${var.resourcePrefix}-sp"
  resource_group_name      = var.resourceGroupName
  location                 = var.location
  os_type                  = var.osType
  sku_name                 = var.skuName
  worker_count             = var.workerCount

  per_site_scaling_enabled = true
  zone_balancing_enabled   = false ## not available on all zones

  tags = {
    "osType" = var.osType
  }
}
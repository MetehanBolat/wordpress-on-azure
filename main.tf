provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_subscription" "current" {}

provider "azuread" {
  tenant_id = data.azurerm_subscription.current.tenant_id
}

## Service Principal Deployment
# THIS WILL BE USED FOR ACME DNS VERIFICATION
module "serviceprincipal" {
  source = "./modules/serviceprincipal"
}

## Resource Group Deployment
# THIS WILL BE USED FOR ALL AZURE SOURCES
resource "azurerm_resource_group" "rg" {
  name     = "${var.resourcePrefix}-rg"
  location = var.location
}

## User-Assigned Identity Deployment
resource "azurerm_user_assigned_identity" "id" {
  name                = "${var.resourcePrefix}-id"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

## KeyVault Service Deployment
module "keyvault" {
  source              = "./modules/keyvault"
  resourcePrefix      = var.resourcePrefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  principalId         = azurerm_user_assigned_identity.id.principal_id
}

## MySQL Database Deployment
module "db" {
  source              = "./modules/db"
  resourcePrefix      = var.resourcePrefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  siteConfig          = var.siteConfig
  adminName           = var.adminName
  adminPassword       = var.adminPassword
  keyVaultId          = module.keyvault.keyVaultId
}

## Service Plan Deployment
resource "azurerm_service_plan" "serviceplan" {
  name                = "${var.resourcePrefix}-sp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  os_type                  = var.osType
  sku_name                 = var.skuName
  worker_count             = var.workerCount
  per_site_scaling_enabled = true
  zone_balancing_enabled   = false ## not available on all zones
}

## App Service Deployment
module "app" {
  source              = "./modules/wordpress"
  resourcePrefix      = var.resourcePrefix
  location            = var.location
  resource_group_name = azurerm_service_plan.serviceplan.resource_group_name
  spId                = azurerm_service_plan.serviceplan.id
  identityId          = azurerm_user_assigned_identity.id.id
  siteConfig          = var.siteConfig
  serverFqdn          = module.db.serverFqdn
  serverName          = module.db.serverName
  adminName           = module.db.adminName
  adminPassword       = module.db.adminPassword
  keyVaultId          = module.keyvault.keyVaultId
}

## DNS Zone Deployment
module "dns" {
  source              = "./modules/dns"
  resource_group_name = azurerm_resource_group.rg.name
  siteConfig          = var.siteConfig
  dnsTxtCode          = module.app.dnsTxtCode
  outboundIP          = module.app.outboundIP
}

## SSL Deployment
module "ssl" {
  source = "./modules/ssl"
  email  = var.adminContact
}
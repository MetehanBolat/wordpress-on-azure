locals {
  storageName                = "${lower(replace(replace("${var.resourcePrefix}","-",""),"_",""))}strassets"
  mySqlSku                   = "B_Gen5_1"
  mySqlStorageSizeInMB       = 32768 ##
  mySqlVersion               = "8.0"
  mySqlBackupRetentionInDays = 7
  cdnSku                     = "Standard_Verizon"
  servicePlanOSType          = "Windows"
}

data "azurerm_subscription" "current" {}

## Service Principal Deployment
# THIS WILL BE USED FOR ACME DNS VERIFICATION
module "serviceprincipal" {
  source = "./serviceprincipal"
}

resource "azurerm_role_assignment" "acme" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = module.serviceprincipal.principalId
}

## Resource Group Deployment
# THIS WILL BE USED FOR ALL SHARED AZURE SOURCES
resource "azurerm_resource_group" "shared" {
  name     = "${var.resourcePrefix}-rg"
  location = var.location
}

## User-Assigned Identity Deployment
resource "azurerm_user_assigned_identity" "id" {
  name                = "${var.resourcePrefix}-id"
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location
}

## KeyVault Service Deployment
module "keyvault" {
  source              = "./keyvault"
  resourcePrefix      = var.resourcePrefix
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  principalId         = azurerm_user_assigned_identity.id.principal_id
  cdnPrincipalId      = module.serviceprincipal.cdnPrincipalId
}

## storage account for assets
resource "azurerm_storage_account" "storage" {
  name                              = length(local.storageName) >= 24 ? substr(local.storageName,0,24) : local.storageName
  location                          = azurerm_resource_group.shared.location
  resource_group_name               = azurerm_resource_group.shared.name
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  access_tier                       = "Hot"
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = true

  identity {
    type         = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.id.id ]
  }

  network_rules {
    default_action = "Allow"
  }
}

## CDN (FrontDoor) Profile
resource "azurerm_cdn_profile" "cdn" {
  name                = "${var.resourcePrefix}-cdn-profile"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  sku                 = local.cdnSku
}

## Service Plan Deployment
resource "azurerm_service_plan" "serviceplan" {
  name                = "${var.resourcePrefix}-sp"
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location

  os_type                  = local.servicePlanOSType
  sku_name                 = var.servicePlanSku
  worker_count             = var.servicePlanWorkerCount
  per_site_scaling_enabled = true
  zone_balancing_enabled   = false ## not available on all zones
}

### MySQL Database (+Server) Module
resource "azurerm_mysql_server" "mysql" {
  name                = "${var.resourcePrefix}-mysql"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name


  administrator_login          = var.adminName
  administrator_login_password = var.adminPassword

  sku_name   = local.mySqlSku
  storage_mb = local.mySqlStorageSizeInMB
  version    = local.mySqlVersion

  backup_retention_days             = local.mySqlBackupRetentionInDays
  geo_redundant_backup_enabled      = false
  auto_grow_enabled                 = true
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_firewall_rule" "allowAzure" {
  name                = "allowAzure"
  resource_group_name = azurerm_mysql_server.mysql.resource_group_name
  server_name         = azurerm_mysql_server.mysql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_key_vault_secret" "username" {
  name         = "mysql-username"
  value        = var.adminName
  key_vault_id = module.keyvault.keyVaultId
}

resource "azurerm_key_vault_secret" "password" {
  name         = "mysql-password"
  value        = var.adminPassword
  key_vault_id = module.keyvault.keyVaultId
}
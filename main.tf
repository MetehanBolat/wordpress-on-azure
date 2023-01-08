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

module "shared" {
  source                 = "./modules/00_shared"
  resourcePrefix         = var.resourcePrefix
  location               = var.location
  servicePlanSku         = var.servicePlanSku
  servicePlanWorkerCount = var.servicePlanWorkerCount
  adminName              = var.adminName
  adminPassword          = var.adminPassword
}

module "dns" {
  source     = "./modules/01_dns"
  location   = var.location
  siteConfig = var.siteConfig
}

module "wordpress" {
  source          = "./modules/02_wordpress"
  location        = var.location
  rgName          = module.dns.rg
  storageName     = module.shared.storageName
  storageKey      = module.shared.storageKey
  storageEndpoint = module.shared.storageEndpoint
  mysqlServerName = module.shared.mysqlServerName
  mysqlRGName     = module.shared.rg
  mysqlServerFqdn = module.shared.mysqlServerFqdn
  servicePlanId   = module.shared.servicePlanId
  identityId      = module.shared.identityId
  adminName       = module.shared.adminName
  adminPassword   = module.shared.adminPassword
  keyVaultId      = module.shared.keyVaultId
  siteConfig      = var.siteConfig
}

module "cdn" {
  source          = "./modules/03_cdn"
  location        = var.location
  rgName          = module.dns.rg
  storageEndpoint = module.shared.storageEndpoint
  cdnProfileName  = module.shared.cndProfileName
  siteConfig      = var.siteConfig
}





### MySQL Database Deployment
#module "db" {
#  source          = "./modules/01_db"
#  location        = var.location
#  mysqlServerName = module.shared.mysqlServerName
#  mysqlRGName     = module.shared.rg
#  siteConfig      = var.siteConfig
#  #keyVaultId = module.keyvault.keyVaultId
#}
#

#
### App Service Deployment
#module "wordpress" {
#  source              = "./modules/wordpress"
#  resourcePrefix      = var.resourcePrefix
#  location            = var.location
#  resource_group_name = azurerm_service_plan.serviceplan.resource_group_name
#  spId                = azurerm_service_plan.serviceplan.id
#  identityId          = azurerm_user_assigned_identity.id.id
#  siteConfig          = var.siteConfig
#  serverFqdn          = module.db.serverFqdn
#  serverName          = module.db.serverName
#  adminName           = module.db.adminName
#  adminPassword       = module.db.adminPassword
#  keyVaultId          = module.keyvault.keyVaultId
#}
#
### DNS Zone Deployment
#module "dns" {
#  source              = "./modules/dns"
#  resource_group_name = azurerm_resource_group.rg.name
#  siteConfig          = var.siteConfig
#  dnsTxtCode          = module.wordpress.dnsTxtCode
#  outboundIP          = module.wordpress.outboundIP
#  appServiceName      = module.wordpress.appServiceName
#  #cdnEndpointDNS      = module.cdn.cdnEndpointDNS
#}
#
### SSL Deployment
#module "ssl" {
#  source                  = "./modules/ssl"
#  resource_group_name     = azurerm_resource_group.rg.name
#  principalId             = module.serviceprincipal.principalId
#  clientId                = module.serviceprincipal.clientId
#  clientSecret            = module.serviceprincipal.clientSecret
#  siteConfig              = var.siteConfig
#  location                = var.location
#  keyVaultId              = module.keyvault.keyVaultId
#}

#module "ssl-rehber" {
#  source                  = "./modules/ssl"
#  resource_group_name     = azurerm_resource_group.rg.name
#  bindingId-www           = module.app.bindingId-www["www.talihavana.com"]
#  bindingId-root          = module.app.bindingId-root["talihavana.com"]
#  clientId                = module.serviceprincipal.clientId
#  clientSecret            = module.serviceprincipal.clientSecret
#  siteConfig              = var.siteConfig["hotel"]
#  location                = var.location
#  keyVaultId              = module.keyvault.keyVaultId
#}

#module "cdn-hotel" {
#  source                  = "./modules/cdn"
#  resourcePrefix          = var.resourcePrefix
#  location                = var.location
#  resource_group_name     = azurerm_resource_group.rg.name
#  siteConfig              = var.siteConfig["hotel"]
#  storageEndpoint         = module.app.storageEndpoint#["hotel"]
#  certificateId           = module.ssl-hotel.certificateId
#}
#
#module "cdn-rehber" {
#  source                  = "./modules/cdn"
#  resourcePrefix          = var.resourcePrefix
#  location                = var.location
#  resource_group_name     = azurerm_resource_group.rg.name
#  siteConfig              = var.siteConfig["rehber"]
#  storageEndpoint         = module.app.storageEndpoint#["rehber"]
#  certificateId           = module.ssl-rehber.certificateId
#}
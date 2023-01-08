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

## ServicePrincipal, KeyVault, CDN Profile, ServicePlan, MySQL Server, Storage Account
module "shared" {
  source                 = "./modules/00_shared"
  resourcePrefix         = var.resourcePrefix
  location               = var.location
  servicePlanSku         = var.servicePlanSku
  servicePlanWorkerCount = var.servicePlanWorkerCount
  adminName              = var.adminName
  adminPassword          = var.adminPassword
}

## per site DNS deployment
module "dns" {
  source     = "./modules/01_dns"
  location   = var.location
  siteConfig = var.siteConfig
}

## per site Azure Files, MySQL Database, Windows App Service
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

## per site CDN endpoints for storage
module "cdn" {
  source          = "./modules/03_cdn"
  location        = var.location
  cdnRGName       = module.shared.rg
  cdnProfileName  = module.shared.cndProfileName
  storageFqdn     = module.shared.storageFqdn
  siteConfig      = var.siteConfig
}

## Custom DNS hostname binding for AppServices and CDN Endpoints
module "custom-dns" {
  source         = "./modules/04_custom-dns"
  dnsTxtCode     = module.wordpress.dnsTxtCode
  appServiceName = module.wordpress.appServiceName
  outboundIP     = module.wordpress.outboundIP
  cdnEndpointDNS = module.cdn.cdnEndpointDNS
  dnsZone        = module.dns.dnsZone
  dnsRG          = module.dns.rg
  siteConfig     = var.siteConfig
}

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


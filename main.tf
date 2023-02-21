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

## ServicePrincipal, KeyVault, ServicePlan, MySQL Server, Storage Account
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
  keyVaultName    = module.shared.keyVaultName
  siteConfig      = var.siteConfig
}

## Custom DNS hostname binding for AppServices and CDN Endpoints
module "custom-dns" {
  source         = "./modules/03_custom-dns"
  dnsTxtCode     = module.wordpress.dnsTxtCode
  appServiceName = module.wordpress.appServiceName
  outboundIP     = module.wordpress.outboundIP
  dnsZone        = module.dns.dnsZone
  dnsRG          = module.dns.rg
  siteConfig     = var.siteConfig
}

module "certbot" {
  source     = "./modules/04_certbot"
  storageSAS = module.shared.storageSAS
  keyVaultId = module.shared.keyVaultId
  siteConfig = var.siteConfig
}

module "ssl-binding" {
  source             = "./modules/05_ssl-binding"
  location           = var.location
  rgName             = module.shared.rg
  keyVaultId         = module.shared.keyVaultId
  dnsZone            = module.dns.dnsZone
  bindingId-www      = module.custom-dns.bindingId-www
  bindingId-root     = module.custom-dns.bindingId-root
  certificateId-www  = module.custom-dns.certificateId-www
  certificateId-root = module.custom-dns.certificateId-root
  secretId-www       = module.certbot.secretId-www
  secretId-root      = module.certbot.secretId-root
  siteConfig         = var.siteConfig
}




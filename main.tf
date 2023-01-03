
## Resource Group Deployment
module "rg" {
  source         = "./modules/rg"
  resourcePrefix = var.resourcePrefix
  location       = var.location
}

## User-Assigned Identity Deployment
module "id" {
  source            = "./modules/id"
  resourcePrefix    = var.resourcePrefix
  location          = var.location
  resourceGroupName = module.rg.rg
}

## KeyVault Service Deployment
module "keyvault" {
  source            = "./modules/keyvault"
  resourcePrefix    = var.resourcePrefix
  location          = var.location
  resourceGroupName = module.rg.rg
  principalId       = module.id.principalId
}

## MySQL Database Deployment
module "db" {
  source            = "./modules/db"
  resourcePrefix    = var.resourcePrefix
  location          = var.location
  resourceGroupName = module.rg.rg
  siteConfig        = var.siteConfig
  adminName         = var.adminName
  adminPassword     = var.adminPassword
  keyVaultId        = module.keyvault.keyVaultId
}

## Service Plan Deployment
module "sp" {
  source            = "./modules/sp"
  resourcePrefix    = var.resourcePrefix
  location          = var.location
  resourceGroupName = module.rg.rg
}

## App Service Deployment
module "app" {
  source            = "./modules/wordpress"
  resourcePrefix    = var.resourcePrefix
  location          = var.location
  resourceGroupName = module.sp.rg
  spId              = module.sp.spId
  identityId        = module.id.identityId
  siteConfig        = var.siteConfig
  serverFqdn        = module.db.serverFqdn
  serverName        = module.db.serverName
  adminName         = module.db.adminName
  adminPassword     = module.db.adminPassword
  keyVaultId        = module.keyvault.keyVaultId
}

## DNS Zone Deployment
module "dns" {
  source            = "./modules/dns"
  resourceGroupName = module.rg.rg
  siteConfig        = var.siteConfig
  dnsTxtCode        = module.app.dnsTxtCode
  outboundIP        = module.app.outboundIP
}
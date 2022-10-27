
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

## Service Plan Deployment
module "sp" {
  source            = "./modules/sp"
  resourcePrefix    = var.resourcePrefix
  location          = var.location
  resourceGroupName = module.rg.rg
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
}

## App Service Deployment
module "app" {
  source             = "./modules/wordpress"
  resourcePrefix    = var.resourcePrefix
  location           = var.location
  resourceGroupName  = module.sp.rg
  spId               = module.sp.spId
  id                 = module.id.id
  siteConfig         = var.siteConfig
  serverFqdn         = module.db.serverFqdn
  serverName         = module.db.serverName
  adminName          = module.db.adminName
  adminPassword      = module.db.adminPassword
}
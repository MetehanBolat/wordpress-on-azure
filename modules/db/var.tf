variable "resourcePrefix" {
  type        = string
  description = "prefix for resource naming (<resourcePrefix>-<resourceType>)"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "resource_group_name" {
  type        = string
  description = "Name of the existing resourceGroup, to deploy resources"
}
variable "siteConfig" {
  description = "App Service Configuration (repo/appSettings/etc)"
  default = {
    site01 = {
      name            = "sitename"
      repo            = "https://github.com/someAccount/someRepo" ## if null, no deployments
      branch          = "master" ## makes sense only if repo is not null
      appStack        = "php"
      appStackVersion = "7.4"
      managedPipeline = "Classic"
      workerCount     = 1
    }
  }
}
variable "adminName" {
  type        = string
  description = "Username for MySQL Server Admin Login"
  sensitive   = true
}
variable "adminPassword" {
  type        = string
  description = "Password for MySQL Server Admin Login"
  sensitive   = true
}
variable "keyVaultId" {
  type        = string
  description = "KeyVault ResourceId to save secrets"
}
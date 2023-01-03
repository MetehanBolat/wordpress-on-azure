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
variable "spId" {
  type        = string
  description = "ResourceId of the Service Plan to deploy Windows Apps"
}
variable "identityId" {
  type        = string
  description = "ResourceId of the User-Assigned Identity"
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
      dnsName         = "some.dns"
    }
  }
}
variable "serverFqdn" {
  type        = string
  description = "FQDN for backend database service"
}
variable "serverName" {
  type        = string
  description = "Name of backend database service"
}
variable "adminName" {
  type        = string
  description = "Username for database login"
  sensitive   = true
}
variable "adminPassword" {
  type        = string
  description = "Password for database login"
  sensitive   = true
}
variable "keyVaultId" {
  type        = string
  description = "KeyVault ResourceId to save secrets"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "rgName" {
  description = "Name of the existing resourceGroup, to deploy resources"
}
variable "storageName" {
  type        = string
  description = "Storage account name to create assets"
}
variable "storageKey" {
  type        = string
  description = "Storage account access key"
}
variable "storageEndpoint" {
  type        = string
  description = "Storage primary blob endpoint"
}
variable "mysqlServerName" {
  type        = string
  description = "Name of the existing mysql server, to deploy databases"
}
variable "mysqlRGName" {
  type        = string
  description = "Name of the existing mysql server resource group"
}
variable "mysqlServerFqdn" {
  type        = string
  description = "FQDN for backend database service"
}
variable "servicePlanId" {
  type        = string
  description = "ResourceId of the Service Plan to deploy Windows Apps"
}
variable "identityId" {
  type        = string
  description = "ResourceId of the User-Assigned Identity"
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

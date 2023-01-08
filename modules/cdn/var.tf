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
variable "storageEndpoint" {
  #type        = string
  description = "Blob endpoint to set CDN origin"
}
#variable "dns_zone_name" {
#  description = "DNS Zone name for CDN endpoint"
#}
#variable "dns_resource_group_name" {
#  description = "Resource group name of DNS Zone name for CDN endpoint"
#}
variable "defaultTTL" {
  description = "Secret to authenticate Azure for ACME verification"
  type        = number
  default     = 300
}
variable "certificateId" {
  type        = string
  description = "KeyVault SecretId of the SSL certificate"
}
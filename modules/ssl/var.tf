variable "dns_resource_group_name" {
  description = "Resource group name of DNS zone name for ACME verification"
}
variable "bindingId-www" {
  description = "Custom domain binding of www.<domain>"
}
variable "bindingId-root" {
  description = "Custom domain binding of <domain>"
}
variable "clientId" {
  description = "ApplicationId to authenticate Azure for ACME verification"
  type        = string
}
variable "clientSecret" {
  description = "Secret to authenticate Azure for ACME verification"
  type        = string
  sensitive   = true
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
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "defaultTTL" {
  description = "Secret to authenticate Azure for ACME verification"
  type        = number
  default     = 300
}

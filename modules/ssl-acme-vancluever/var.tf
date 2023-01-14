#variable "dnsZone" {
#  description = "DNS Zone name to add records"
#}
#variable "dnsRG" {
#  description = "Resource group name of the DNS Zone"
#}
##variable "bindingId-www" {
##  type        = string
##  description = "Custom domain binding of www.<domain>"
##}
##variable "bindingId-root" {
##  type        = string
##  description = "Custom domain binding of <domain>"
##}
#variable "clientId" {
#  description = "ApplicationId to authenticate Azure for ACME verification"
#  type        = string
#}
#variable "clientSecret" {
#  description = "Secret to authenticate Azure for ACME verification"
#  type        = string
#  sensitive   = true
#}
#
#variable "keyVaultId" {
#  description = "ResourceId of keyvault resource to save the SSL certificate"
#  type        = string
#}
#
#variable "siteConfig" {
#  description = "App Service Configuration (repo/appSettings/etc)"
#  default = {
#    site01 = {
#      name            = "sitename"
#      repo            = "https://github.com/someAccount/someRepo" ## if null, no deployments
#      branch          = "master" ## makes sense only if repo is not null
#      appStack        = "php"
#      appStackVersion = "7.4"
#      managedPipeline = "Classic"
#      workerCount     = 1
#      email           = "info@somesite"
#    }
#  }
#}
#
#variable "defaultTTL" {
#  description = "Secret to authenticate Azure for ACME verification"
#  type        = number
#  default     = 300
#}


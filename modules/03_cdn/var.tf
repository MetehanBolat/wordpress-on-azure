variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "cdnRGName" {
  type        = string
  description = "Resource group of CDN profile to create endpoints"
}
variable "cdnProfileName" {
  type        = string
  description = "CDN profile name to create endpoints"
}
variable "storageFqdn" {
  description = "Blob fqdn to set CDN origin"
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
      email           = "info@some.dns"
    }
  }
}

#variable "defaultTTL" {
#  description = "Secret to authenticate Azure for ACME verification"
#  type        = number
#  default     = 300
#}
#variable "dns_zone_name" {
#  description = "DNS Zone name for CDN endpoint"
#}
#variable "dns_resource_group_name" {
#  description = "Resource group name of DNS Zone name for CDN endpoint"
#}

#variable "certificateId" {
#  type        = string
#  description = "KeyVault SecretId of the SSL certificate"
#}
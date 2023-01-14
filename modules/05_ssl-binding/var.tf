variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}

variable "rgName" {
  type = string
  description = "shared resource group name"
}
variable "keyVaultId" {
  type = string
  description = "ResourceId of the key vault resource"
}
variable "dnsZone" {
  description = "DNS Zone name to add records"
}


variable "bindingId-www" {
  description = "Custom hostname bindingId for www.<domain>"
}
variable "bindingId-root" {
  description = "Custom hostname bindingId for <domain>"
}

#variable "cdnEndpointId" {
#  description = "Custom hostname bindingId for <domain>"
#}
#variable "cdnDns" {
#  description = "DNS for CDN endpoint"
#}
#variable "secretless_cert" {
#  description = "Secretless id of the wildcard certificate for CDN endpoint"
#}

variable "secretId-www" {
  description = "KeyVault certificate for the wildcard DNS"
}
variable "secretId-root" {
  description = "KeyVault certificate for the root DNS"
}

variable "certificateId-www" {
  description = "Managed certificate for www DNS"
}
variable "certificateId-root" {
  description = "Managed certificate for root DNS"
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
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}

variable "dnsZone" {
  description = "DNS Zone name to add records"
}
variable "dnsRG" {
  description = "Resource group name of the DNS Zone"
}

variable "bindingId-www" {
  description = "Custom hostname bindingId for www.<domain>"
}
variable "bindingId-root" {
  description = "Custom hostname bindingId for <domain>"
}

variable "cdnEndpointId" {
  description = "Custom hostname bindingId for <domain>"
}
variable "cdnDns" {
  description = "DNS for CDN endpoint"
}

variable "certificateId-www" {
  description = "KeyVault Certificate for www.<domain>"
}
variable "certificateId-root" {
  description = "KeyVault Certificate for <domain>"
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
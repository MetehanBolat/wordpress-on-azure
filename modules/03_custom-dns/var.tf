variable "dnsTxtCode" {
  description = "TXT record values for DNS validation"
}
variable "appServiceName" {
  description = "App Service Name for custom DNS binding"
}
variable "outboundIP" {
  description = "List of IP addresses for the app services"
}
#variable "cdnEndpointDNS" {
#  description = "FQDN of CDN endpoint to set CNAME records"
#}
variable "dnsZone" {
  description = "DNS Zone name to add records"
}
variable "dnsRG" {
  description = "Resource group name of the DNS Zone"
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
variable "defaultTTL" {
  description = "Secret to authenticate Azure for ACME verification"
  type = number
  default = 300
}
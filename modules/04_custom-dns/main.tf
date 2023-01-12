### DNS TXT Record for asuid.<domain>
resource "azurerm_dns_txt_record" "root" {
  for_each            = var.siteConfig
  name                = "asuid"
  zone_name           = var.dnsZone[each.value.dnsName]
  resource_group_name = var.dnsRG[each.value.dnsName]
  ttl                 = var.defaultTTL

  record {
    value = var.dnsTxtCode[each.value.name]
  }
}
## DNS TXT Record for asuid.www.<domain>
resource "azurerm_dns_txt_record" "www" {
  for_each            = var.siteConfig
  name                = "asuid.www"
  zone_name           = var.dnsZone[each.value.dnsName]
  resource_group_name = var.dnsRG[each.value.dnsName]
  ttl                 = var.defaultTTL

  record {
    value = var.dnsTxtCode[each.value.name]
  }
}
### DNS A Record for <domain>
resource "azurerm_dns_a_record" "root" {
  for_each            = var.siteConfig
  name                = "@"
  zone_name           = var.dnsZone[each.value.dnsName]
  resource_group_name = var.dnsRG[each.value.dnsName]
  ttl                 = var.defaultTTL
  records             = [element(var.outboundIP[each.value.name], length(var.outboundIP[each.value.name])-1)]
}
### DNS CName Record for www.<domain>
resource "azurerm_dns_cname_record" "www" {
  for_each            = var.siteConfig
  name                = "www"
  zone_name           = var.dnsZone[each.value.dnsName]
  resource_group_name = var.dnsRG[each.value.dnsName]
  ttl                 = var.defaultTTL
  record              = "${each.value.name}.azurewebsites.net"
}

## Binding custom domain to app services
resource "azurerm_app_service_custom_hostname_binding" "root" {
  depends_on          = [ azurerm_dns_txt_record.root ]
  for_each            = var.siteConfig
  hostname            = each.value.dnsName
  app_service_name    = var.appServiceName[each.value.name]
  resource_group_name = var.dnsRG[each.value.dnsName]
}
resource "azurerm_app_service_custom_hostname_binding" "www" {
  depends_on          = [ azurerm_dns_txt_record.www ]
  for_each            = var.siteConfig
  hostname            = "www.${each.value.dnsName}"
  app_service_name    = var.appServiceName[each.value.name]
  resource_group_name = var.dnsRG[each.value.dnsName]
}

#### DNS CName Record for assets.<domain>
resource "azurerm_dns_cname_record" "cdn" {
  for_each            = var.siteConfig
  name                = "cdn"
  zone_name           = var.dnsZone[each.value.dnsName]
  resource_group_name = var.dnsRG[each.value.dnsName]
  ttl                 = var.defaultTTL
  record              = var.cdnEndpointDNS[each.value.name]
}
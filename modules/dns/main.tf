## DNS Module
locals {
  defaultTTL = 300 ## in seconds
}

### Public DNS Zone
resource "azurerm_dns_zone" "dns-public" {
  for_each            = var.siteConfig
  name                = each.value.dnsName
  resource_group_name = var.resource_group_name
}

### DNS TXT Record for *.<domain>
resource "azurerm_dns_txt_record" "star" {
  for_each            = var.siteConfig
  name                = "*"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL

  record {
    value = var.dnsTxtCode[each.value.name]
  }
}

### DNS TXT Record for asuid.<domain>
resource "azurerm_dns_txt_record" "root" {
  for_each            = var.siteConfig
  name                = "asuid"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL

  record {
    value = var.dnsTxtCode[each.value.name]
  }
}

### DNS TXT Record for asuid.www.<domain>
resource "azurerm_dns_txt_record" "www" {
  for_each            = var.siteConfig
  name                = "asuid.www"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL

  record {
    value = var.dnsTxtCode[each.value.name]
  }
}

### DNS A Record for <domain>
resource "azurerm_dns_a_record" "root" {
  for_each            = var.siteConfig
  name                = "@"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL
  records             = [element(var.outboundIP[each.value.name], length(var.outboundIP[each.value.name])-1)]
}

### DNS CName Record for www.<domain>
resource "azurerm_dns_cname_record" "www" {
  for_each            = var.siteConfig
  name                = "www"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL
  record              = each.value.dnsName
}


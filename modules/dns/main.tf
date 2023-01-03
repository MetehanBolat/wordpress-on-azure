## DNS Module
provider "azurerm" {
  features {}
}

locals {
  defaultTTL = 3600 ## in seconds
}

resource "azurerm_dns_zone" "dns-public" {
  for_each            = var.siteConfig
  name                = each.value.dnsName
  resource_group_name = var.resourceGroupName
}

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

resource "azurerm_dns_a_record" "root" {
  for_each            = var.siteConfig
  name                = "@"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL
  records             = [element(var.outboundIP[each.value.name], length(var.outboundIP[each.value.name])-1)]
}

resource "azurerm_dns_cname_record" "www" {
  for_each            = var.siteConfig
  name                = "www"
  zone_name           = azurerm_dns_zone.dns-public[each.key].name
  resource_group_name = azurerm_dns_zone.dns-public[each.key].resource_group_name
  ttl                 = local.defaultTTL
  record              = each.value.dnsName
}


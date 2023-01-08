## DNS Module
### Public DNS Zone
resource "azurerm_resource_group" "rg" {
  for_each = var.siteConfig
  name     = "${each.value.name}-rg"
  location = var.location
}

resource "azurerm_dns_zone" "dns-public" {
  for_each            = var.siteConfig
  name                = each.value.dnsName
  resource_group_name = azurerm_resource_group.rg[each.key].name
}
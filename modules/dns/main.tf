## DNS Module
provider "azurerm" {
  features {}
}

resource "azurerm_dns_zone" "dns-public" {
  for_each            = var.siteConfig
  name                = each.value.dnsName
  resource_group_name = var.resourceGroupName
}
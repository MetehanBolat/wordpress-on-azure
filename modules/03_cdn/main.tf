resource "azurerm_cdn_endpoint" "assets" {
  for_each            = var.siteConfig
  name                = each.value.name
  profile_name        = var.cdnProfileName
  location            = var.location
  resource_group_name = var.rgName[each.value.dnsName]

  optimization_type   = "GeneralWebDelivery"
  origin {
    name      = each.value.name
    host_name = var.storageEndpoint
  }
  origin_host_header = "assets.${each.value.dnsName}"
  origin_path        = "/${each.value.name}/"
}

#### DNS CName Record for assets.<domain>
#resource "azurerm_dns_cname_record" "assets" {
#  for_each            = var.siteConfig
#  name                = "assets"
#  zone_name           = var.dnsZone[each.value.dnsName]
#  resource_group_name = var.rgName[each.value.dnsName]
#  ttl                 = var.defaultTTL
#  record              = azurerm_cdn_endpoint.assets[each.key].fqdn
#}

#resource "azurerm_cdn_endpoint_custom_domain" "assets" {
#  #for_each        = var.siteConfig
#  name            = var.siteConfig.name
#  cdn_endpoint_id = azurerm_cdn_endpoint.assets.id
#  host_name       = "${azurerm_dns_cname_record.assets.name}.${var.siteConfig.dnsName}"
#  user_managed_https {
#    key_vault_secret_id = var.certificateId
#  }
#}
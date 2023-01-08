resource "azurerm_cdn_endpoint" "assets" {
  #for_each            = var.siteConfig
  name                = var.siteConfig.name
  profile_name        = azurerm_cdn_profile.cdn.name
  location            = azurerm_cdn_profile.cdn.location
  resource_group_name = azurerm_cdn_profile.cdn.resource_group_name

  optimization_type   = "GeneralWebDelivery"
  origin {
    name      = var.siteConfig.name
    host_name = element(split("/",replace(var.storageEndpoint[var.siteConfig.name],"https://","")),0)
  }
  origin_host_header = "assets.${var.siteConfig.dnsName}"
  origin_path        = "/${element(split("/",replace(var.storageEndpoint[var.siteConfig.name],"https://","")),1)}/"
}

### DNS CName Record for assets.<domain>
resource "azurerm_dns_cname_record" "assets" {
  #for_each            = var.siteConfig
  name                = "assets"
  zone_name           = var.siteConfig.dnsName
  resource_group_name = var.resource_group_name
  ttl                 = var.defaultTTL
  record              = azurerm_cdn_endpoint.assets.fqdn
}

resource "azurerm_cdn_endpoint_custom_domain" "assets" {
  #for_each        = var.siteConfig
  name            = var.siteConfig.name
  cdn_endpoint_id = azurerm_cdn_endpoint.assets.id
  host_name       = "${azurerm_dns_cname_record.assets.name}.${var.siteConfig.dnsName}"
  user_managed_https {
    key_vault_secret_id = var.certificateId
  }
}
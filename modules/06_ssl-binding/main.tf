#### Import SSL from KeyVault
#resource "azurerm_app_service_certificate" "www" {
#  for_each            = var.siteConfig
#  name                = "www-${each.value.name}"
#  resource_group_name = var.dnsRG[each.value.dnsName]
#  location            = var.location
#  key_vault_secret_id = var.certificateId-www["star-${each.value.name}"]
#}
#resource "azurerm_app_service_certificate" "root" {
#  for_each            = var.siteConfig
#  name                = "root-${each.value.name}"
#  resource_group_name = var.dnsRG[each.value.dnsName]
#  location            = var.location
#  key_vault_secret_id = var.certificateId-root["root-${each.value.name}"]
#}

### Set managed certificate endpoint
resource "azurerm_app_service_managed_certificate" "www" {
  for_each                   = var.siteConfig
  custom_hostname_binding_id = var.bindingId-www["www.${each.value.dnsName}"]
}
resource "azurerm_app_service_managed_certificate" "root" {
  for_each                   = var.siteConfig
  custom_hostname_binding_id = var.bindingId-root[each.value.dnsName]
}

## Bind SSL to custom endpoints
resource "azurerm_app_service_certificate_binding" "www" {
  for_each            = var.siteConfig
  certificate_id      = azurerm_app_service_managed_certificate.www[each.key].id
  hostname_binding_id = var.bindingId-www["www.${each.value.dnsName}"]
  ssl_state           = "SniEnabled"
}
resource "azurerm_app_service_certificate_binding" "root" {
  for_each            = var.siteConfig
  certificate_id      = azurerm_app_service_managed_certificate.root[each.key].id
  hostname_binding_id = var.bindingId-root[each.value.dnsName]
  ssl_state           = "SniEnabled"
}

resource "azurerm_cdn_endpoint_custom_domain" "cdn" {
  for_each        = var.siteConfig
  name            = "${each.value.name}-endpoint"
  cdn_endpoint_id = var.cdnEndpointId[each.value.name]
  host_name       = var.cdnDns[each.value.dnsName]
  user_managed_https {
    key_vault_secret_id = var.certificateId-www["star-${each.value.name}"]
    tls_version = "TLS12"
  }
  #cdn_managed_https {
  #  certificate_type = "Dedicated"
  #  protocol_type    = "ServerNameIndication"
  #  tls_version      = "TLS12"
  #}
}
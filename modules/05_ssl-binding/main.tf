data "azuread_service_principal" "MicrosoftWebApp" {
  application_id = "abfa0a7c-a6b6-4736-8310-5855508787cd"
}

resource "azurerm_role_assignment" "MicrosoftWebApp" {
  scope                = var.keyVaultId
  principal_id         = data.azuread_service_principal.MicrosoftWebApp.object_id
  role_definition_name = "Key Vault Administrator"
}

#### Import SSL from KeyVault
resource "azurerm_app_service_certificate" "www" {
  depends_on          = [ azurerm_role_assignment.MicrosoftWebApp ]
  for_each            = var.siteConfig
  name                = "www.${var.dnsZone[each.value.dnsName]}"
  resource_group_name = var.rgName
  location            = var.location
  key_vault_secret_id = var.secretId-www["star-${replace(each.value.dnsName,".","-")}"]
}
resource "azurerm_app_service_certificate" "root" {
  depends_on          = [ azurerm_role_assignment.MicrosoftWebApp, azurerm_app_service_certificate.www ]
  for_each            = var.siteConfig
  name                = var.dnsZone[each.value.dnsName]
  resource_group_name = var.rgName
  location            = var.location
  key_vault_secret_id = var.secretId-root["${replace(each.value.dnsName,".","-")}"]
}

## Bind SSL to custom endpoints
resource "azurerm_app_service_certificate_binding" "www" {
  depends_on          = [ azurerm_role_assignment.MicrosoftWebApp ]
  for_each            = var.siteConfig
  certificate_id      = var.certificateId-www[var.bindingId-www["www.${each.value.dnsName}"]]
  hostname_binding_id = var.bindingId-www["www.${each.value.dnsName}"]
  ssl_state           = "SniEnabled"
}
resource "azurerm_app_service_certificate_binding" "root" {
  depends_on          = [ azurerm_role_assignment.MicrosoftWebApp, azurerm_app_service_certificate_binding.www ]
  for_each            = var.siteConfig
  certificate_id      = var.certificateId-root[var.bindingId-root["${each.value.dnsName}"]]
  hostname_binding_id = var.bindingId-root[each.value.dnsName]
  ssl_state           = "SniEnabled"
}

#resource "azurerm_cdn_endpoint_custom_domain" "cdn" {
#  for_each        = var.siteConfig
#  name            = each.value.name
#  cdn_endpoint_id = var.cdnEndpointId[each.value.name]
#  host_name       = var.cdnDns[each.value.dnsName]
#  user_managed_https {
#    key_vault_secret_id = var.secretId-www["star-${replace(each.value.dnsName,".","-")}"]
#    tls_version         = "TLS12"
#  }
#}
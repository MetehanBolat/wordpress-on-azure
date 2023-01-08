output "cdnEndpointDNS" {
  #value = azurerm_cdn_endpoint.assets.fqdn
  value = { for endpoint in azurerm_cdn_endpoint.assets: endpoint.name => endpoint.fqdn }
}
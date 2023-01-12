output "cdnEndpointDNS" {
  #value = azurerm_cdn_endpoint.assets.fqdn
  value = { for endpoint in azurerm_cdn_endpoint.cdn: endpoint.name => endpoint.fqdn }
}

output "cdnEndpointId" {
  #value = azurerm_cdn_endpoint.assets.fqdn
  value = { for endpoint in azurerm_cdn_endpoint.cdn: endpoint.name => endpoint.id }
}
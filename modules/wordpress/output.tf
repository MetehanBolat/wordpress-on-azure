output "dnsTxtCode" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.custom_domain_verification_id }
}
output "outboundIP" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.outbound_ip_address_list }
}
output "dnsTxtCode" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.custom_domain_verification_id }
}
output "outboundIP" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.outbound_ip_address_list }
}
output "bindingId-root" {
  value = { for root in azurerm_app_service_custom_hostname_binding.root: root.hostname => root.id }
}
output "bindingId-www" {
  value = { for www in azurerm_app_service_custom_hostname_binding.www: www.hostname => www.id }
}
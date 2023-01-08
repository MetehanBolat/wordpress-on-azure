output "dnsTxtCode" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.custom_domain_verification_id }
}
output "outboundIP" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.outbound_ip_address_list }
}

output "storageEndpoint" {
  value = { for container in azurerm_storage_container.container: container.name => "${azurerm_storage_account.storage.primary_blob_endpoint}${container.name}" }
}

output "appServiceName" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.name }
}
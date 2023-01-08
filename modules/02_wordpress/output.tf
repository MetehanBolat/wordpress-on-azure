
## MySQL Database Name
output "dbId" {
  value = {for db in azurerm_mysql_database.mysql: db.name => db.id}
}

output "dnsTxtCode" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.custom_domain_verification_id }
}
output "outboundIP" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.outbound_ip_address_list }
}
output "storageEndpoint" {
  value = { for container in azurerm_storage_container.container: container.name => "${var.storageEndpoint}${container.name}" }
}
output "appServiceName" {
  value = { for app in azurerm_windows_web_app.app: app.name => app.name }
}
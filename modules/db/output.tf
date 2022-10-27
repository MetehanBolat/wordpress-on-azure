## MySQL Resource Group Name
output "rg" {
  value = azurerm_mysql_server.server.resource_group_name
}

## FQDN for MySQL Server
output "serverFqdn" {
  value = azurerm_mysql_server.server.fqdn
}

## MySQL Server Name
output "serverName" {
  value = azurerm_mysql_server.server.name
}

## MySQL Database Name
output "dbId" {
  value = {for db in azurerm_mysql_database.db: db.name => db.id}
}

## MySQL Admin Username
output "adminName" {
  value     = var.adminName
  sensitive = true
}

## MySQL Admin Password
output "adminPassword" {
  value     = var.adminPassword
  sensitive = true
}
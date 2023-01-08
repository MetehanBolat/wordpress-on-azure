
## MySQL Database Name
output "dbId" {
  value = {for db in azurerm_mysql_database.db: db.name => db.id}
}


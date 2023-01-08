resource "azurerm_mysql_database" "db" {
  for_each            = var.siteConfig
  name                = "${each.value.name}-db"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.server.name
  charset             = "utf8"
  collation           = "utf8_turkish_ci"
}

resource "azurerm_mysql_firewall_rule" "allowAzure" {
  name                = "allowAzure"
  resource_group_name = azurerm_mysql_server.server.resource_group_name
  server_name         = azurerm_mysql_server.server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_key_vault_secret" "username" {
  name         = "mysql-username"
  value        = var.adminName
  key_vault_id = var.keyVaultId
}

resource "azurerm_key_vault_secret" "password" {
  name         = "mysql-password"
  value        = var.adminPassword
  key_vault_id = var.keyVaultId
}
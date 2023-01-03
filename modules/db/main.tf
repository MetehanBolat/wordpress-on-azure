### MySQL Database (+Server) Module
resource "azurerm_mysql_server" "server" {
  name                         = "${var.resourcePrefix}-server"
  resource_group_name          = var.resource_group_name
  location                     = var.location


  administrator_login          = var.adminName
  administrator_login_password = var.adminPassword

  sku_name   = "B_Gen5_1"
  storage_mb = 32768
  version    = "8.0"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

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
### KeyVault Module
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                            = "${var.resourcePrefix}-keyvault"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = data.azurerm_subscription.current.tenant_id
  soft_delete_retention_days      = 7
  sku_name                        = "standard"
  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  purge_protection_enabled        = false
  enabled_for_disk_encryption     = false
}

resource "azurerm_role_assignment" "current" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "id" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.principalId
}
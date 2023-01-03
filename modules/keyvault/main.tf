provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_subscription" "current" {}

resource "azurerm_key_vault" "keyvault" {
  name                            = "${var.resourcePrefix}-keyvault"
  resource_group_name             = var.resourceGroupName
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

resource "azurerm_role_assignment" "id" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.principalId
}
## Key Vault ResourceId
output "keyVaultId" {
  value = azurerm_role_assignment.current.scope
}
output "keyVaultName" {
  value = azurerm_key_vault.keyvault.name
}
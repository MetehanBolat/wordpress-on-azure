## Key Vault ResourceId
output "keyVaultId" {
  value = azurerm_role_assignment.current.scope
}
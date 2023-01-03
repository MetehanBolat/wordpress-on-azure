## User-Assigned Identity Resource Name
output "idName" {
  value = azurerm_user_assigned_identity.id.name
}

## User-Assigned Identity ResourceId
output "identityId" {
  value = azurerm_user_assigned_identity.id.id
}

## User-Assigned Identity ClientId (applicationId) - for authentication to AAD
output "clientId" {
  value = azurerm_user_assigned_identity.id.client_id
}

## User-Assigned Identity PrincipalId (objectId) - for RBAC
output "principalId" {
  value = azurerm_user_assigned_identity.id.principal_id
}

## Subscription TenantId (of AAD)
output "tenantId" {
  value = azurerm_user_assigned_identity.id.tenant_id
}
## Storage account name
output "storageId" {
  value = azurerm_storage_account.storage.id
}
## Storage account name
output "storageName" {
  value = azurerm_storage_account.storage.name
}
## Storage account key
output "storageKey" {
  value = azurerm_storage_account.storage.primary_access_key
  sensitive = true
}
## Storage primary endpoint
output "storageEndpoint" {
  value = azurerm_storage_account.storage.primary_blob_endpoint
}
## Storage FQDN
output "storageFqdn" {
  value = "${azurerm_storage_account.storage.name}.blob.core.windows.net"
}

## Service Plan Resource Id
output "servicePlanId" {
  value = azurerm_service_plan.serviceplan.id
}
## Service Plan Name
output "servicePlanName" {
  value = azurerm_service_plan.serviceplan.name
}

## CDN Profile Resource Id
output "cndProfileId" {
  value = azurerm_cdn_profile.cdn.id
}
## CDN Profile Name
output "cndProfileName" {
  value = azurerm_cdn_profile.cdn.name
}

## MySQL Server ResourceId
output "mysqlServerId" {
  value = azurerm_mysql_server.mysql.id
}
## MySQL Server Name
output "mysqlServerName" {
  value = azurerm_mysql_server.mysql.name
}
## FQDN for MySQL Server
output "mysqlServerFqdn" {
  value = azurerm_mysql_server.mysql.fqdn
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

## Resource Group Name of Shared Resources
output "rg" {
  value = azurerm_mysql_server.mysql.resource_group_name
}

## User assigned identity Id
output "identityId" {
  value = azurerm_user_assigned_identity.id.id
}

## KeyVault Id
output "keyVaultId" {
  value = module.keyvault.keyVaultId
}

## Service Principal clientId (applicationId)
output "clientId" {
  value = module.serviceprincipal.clientId
}

## Service Principal secret
output "clientSecret" {
  value     = module.serviceprincipal.clientSecret
  sensitive = true
}

## Service Principal clientId (applicationId)
output "principalId" {
  value = module.serviceprincipal.principalId
}
## Service Principal clientId (applicationId)
output "clientId" {
  value = azuread_service_principal.acme.application_id
}

## Service Principal clientId (applicationId)
output "principalId" {
  value = azuread_service_principal.acme.object_id
}

output "secret" {
  value     = azuread_service_principal_password.acme.value
  sensitive = true
}
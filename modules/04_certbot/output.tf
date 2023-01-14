output "secretId-www" {
  value = {for cert in data.azurerm_key_vault_certificate.www: cert.name => cert.secret_id }
}
output "secretId-root" {
  value = {for cert in data.azurerm_key_vault_certificate.root: cert.name => cert.secret_id }
}
#output "secretless-cert" {
#  value = {for cert in data.azurerm_key_vault_certificate.www: cert.name => cert.versionless_secret_id }
#}
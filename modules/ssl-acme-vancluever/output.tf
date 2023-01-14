#output "secretId-www" {
#  value = { for cert in azurerm_key_vault_certificate.star: cert.name => cert.secret_id }
#}
#output "secretId-root" {
#  value = { for cert in azurerm_key_vault_certificate.cert-root: cert.name => cert.secret_id }
#}
#
#output "certificateId-www" {
#  value = { for cert in azurerm_key_vault_certificate.star: cert.name => cert.versionless_secret_id }
#}

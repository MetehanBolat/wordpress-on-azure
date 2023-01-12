output "certificateId-www" {
  value = { for cert in azurerm_key_vault_certificate.www: cert.name => cert.secret_id }
}
output "certificateId-root" {
  value = { for cert in azurerm_key_vault_certificate.root: cert.name => cert.secret_id }
}

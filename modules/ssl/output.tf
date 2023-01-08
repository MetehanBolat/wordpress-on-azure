output "certificateId" {
  value = { for cert in azurerm_key_vault_certificate.pfx: cert.name => cert.secret_id }
  #value = azurerm_key_vault_certificate.pfx.secret_id
}

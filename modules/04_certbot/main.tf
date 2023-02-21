resource "null_resource" "www" {
  for_each = var.siteConfig
  provisioner "local-exec" {
    command = "pwsh -File certbot\\New-AcmeCertificate.ps1 -AcmeDirectory ${var.endpoint} -AcmeContact ${each.value.email} -fqdn *.${each.value.dnsName} -storageContainerSASToken \"${var.storageSAS}\""
  }
}
resource "null_resource" "root" {
  for_each = var.siteConfig
  provisioner "local-exec" {
    command = "pwsh -File certbot\\New-AcmeCertificate.ps1 -AcmeDirectory ${var.endpoint} -AcmeContact ${each.value.email} -fqdn ${each.value.dnsName} -storageContainerSASToken \"${var.storageSAS}\""
  }
}

resource "null_resource" "www-import" {
  depends_on = [ null_resource.www ]
  for_each = var.siteConfig
  #triggers = {
  #  anything = timestamp()
  #}
  provisioner "local-exec" {
    command = "pwsh -File certbot\\Import-AcmeCertificateToKeyVault.ps1 -AcmeDirectory ${var.endpoint} -fqdn *.${each.value.dnsName} -keyVaultResourceId ${var.keyVaultId}"
  }
}
resource "null_resource" "root-import" {
  depends_on = [ null_resource.root ]
  for_each = var.siteConfig
  #triggers = {
  #  anything = timestamp()
  #}
  provisioner "local-exec" {
    command = "pwsh -File certbot\\Import-AcmeCertificateToKeyVault.ps1 -AcmeDirectory ${var.endpoint} -fqdn ${each.value.dnsName} -keyVaultResourceId ${var.keyVaultId}"
  }
}

data "azurerm_key_vault_certificate" "www" {
  for_each     = var.siteConfig
  depends_on   = [ null_resource.www-import ]
  name         = "star-${replace(each.value.dnsName,".","-")}"
  key_vault_id = var.keyVaultId
}

data "azurerm_key_vault_certificate" "root" {
  for_each     = var.siteConfig
  depends_on   = [ null_resource.root-import ]
  name         = replace(each.value.dnsName,".","-")
  key_vault_id = var.keyVaultId
}
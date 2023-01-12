## ACME DNS Verification provider
terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "=2.12.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
  #server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

data "azurerm_subscription" "current" {}

## Private Keys for SSL certs
resource "tls_private_key" "www" {
  for_each    = var.siteConfig
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}
resource "tls_private_key" "root" {
  for_each    = var.siteConfig
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

## Register private key to the certificate authority (ACME registration)
resource "acme_registration" "www" {
  for_each        = var.siteConfig
  account_key_pem = tls_private_key.www[each.key].private_key_pem
  email_address   = each.value.email
}
resource "acme_registration" "root" {
  for_each        = var.siteConfig
  account_key_pem = tls_private_key.root[each.key].private_key_pem
  email_address   = each.value.email
}

## Gets a certificate from the ACME server
resource "acme_certificate" "www" {
  for_each        = var.siteConfig
  account_key_pem = acme_registration.www[each.key].account_key_pem
  common_name     = "*.${var.dnsZone[each.value.dnsName]}"

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_RESOURCE_GROUP  = var.dnsRG[each.value.dnsName]
      AZURE_ZONE_NAME       = var.dnsZone[each.value.dnsName]
      AZURE_TTL             = var.defaultTTL
      AZURE_CLIENT_ID       = var.clientId
      AZURE_CLIENT_SECRET   = var.clientSecret
      AZURE_ENVIRONMENT     = "public"
      AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
      AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    }
  }
}
resource "acme_certificate" "root" {
  for_each        = var.siteConfig
  account_key_pem = acme_registration.root[each.key].account_key_pem
  common_name     = "${var.dnsZone[each.value.dnsName]}"

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_RESOURCE_GROUP  = var.dnsRG[each.value.dnsName]
      AZURE_ZONE_NAME       = var.dnsZone[each.value.dnsName]
      AZURE_TTL             = var.defaultTTL
      AZURE_CLIENT_ID       = var.clientId
      AZURE_CLIENT_SECRET   = var.clientSecret
      AZURE_ENVIRONMENT     = "public"
      AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
      AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    }
  }
}

## Saving certificates to KeyVault as PFX
resource "azurerm_key_vault_certificate" "www" {
  for_each            = var.siteConfig
  name                = "star-${each.value.name}"
  key_vault_id        = var.keyVaultId

  certificate {
    contents = acme_certificate.www[each.key].certificate_p12
    password = ""
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      key_size   = 2048
      key_type   = "RSA"
      exportable = true
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}
resource "azurerm_key_vault_certificate" "root" {
  for_each            = var.siteConfig
  name                = "root-${each.value.name}"
  key_vault_id        = var.keyVaultId

  certificate {
    contents = acme_certificate.root[each.key].certificate_p12
    password = ""
  }

  certificate_policy {
    issuer_parameters {
      name = "Unknown"
    }

    key_properties {
      key_size   = 2048
      key_type   = "RSA"
      exportable = true
      reuse_key  = true
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}

#resource "azurerm_app_service_certificate" "www" {
#  #for_each            = var.siteConfig
#  name                = var.siteConfig.dnsName
#  resource_group_name = var.resource_group_name
#  location            = var.location
#
#  pfx_blob = acme_certificate.www.certificate_p12
#  password = acme_certificate.www.certificate_p12_password
#}

#resource "azurerm_app_service_managed_certificate" "www" {
#  #for_each                   = var.siteConfig
#  custom_hostname_binding_id = var.bindingId-www
#}

#resource "azurerm_app_service_managed_certificate" "root" {
#  #for_each                   = var.siteConfig
#  custom_hostname_binding_id = var.bindingId-root
#}

# var.a != "" ? var.a : "default-a"




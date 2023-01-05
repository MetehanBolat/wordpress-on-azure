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

resource "tls_private_key" "www" {
  for_each  = var.siteConfig
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "acme_registration" "www" {
  for_each        = var.siteConfig
  account_key_pem = tls_private_key.www[each.key].private_key_pem
  email_address   = each.value.email
}

# As the certificate will be generated in PFX a password is required
resource "random_password" "cert" {
  for_each = var.siteConfig
  length   = 24
  special  = true
}

resource "tls_cert_request" "req" {
  for_each        = var.siteConfig
  private_key_pem = tls_private_key.www[each.key].private_key_pem
  dns_names       = ["${each.value.dnsName}","*.${each.value.dnsName}"]

  subject {
    common_name = "*.${each.value.dnsName}"
  }
}

## Gets a certificate from the ACME server
resource "acme_certificate" "www" {
  for_each                 = var.siteConfig
  account_key_pem          = acme_registration.www[each.key].account_key_pem
  certificate_request_pem  = tls_cert_request.req[each.key].cert_request_pem
  certificate_p12_password = random_password.cert[each.key].result

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_RESOURCE_GROUP  = var.dns_resource_group_name[each.value.dnsName]
      AZURE_ZONE_NAME       = each.value.dnsName
      AZURE_TTL             = var.defaultTTL
      AZURE_CLIENT_ID       = var.clientId
      AZURE_CLIENT_SECRET   = var.clientSecret
      AZURE_ENVIRONMENT     = "public"
      AZURE_SUBSCRIPTION_ID = data.azurerm_subscription.current.subscription_id
      AZURE_TENANT_ID       = data.azurerm_subscription.current.tenant_id
    }
  }
}

resource "azurerm_app_service_certificate" "www" {
  for_each            = var.siteConfig
  name                = each.value.dnsName
  resource_group_name = var.dns_resource_group_name[each.value.dnsName]
  location            = var.location

  pfx_blob = acme_certificate.www[each.key].certificate_p12
  password = acme_certificate.www[each.key].certificate_p12_password
}

resource "azurerm_app_service_managed_certificate" "www" {
  for_each                   = var.siteConfig
  custom_hostname_binding_id = var.bindingId-www["www.${each.value.dnsName}"]
}

resource "azurerm_app_service_managed_certificate" "root" {
  for_each                   = var.siteConfig
  custom_hostname_binding_id = var.bindingId-root["${each.value.dnsName}"]
}

# var.a != "" ? var.a : "default-a"

resource "azurerm_app_service_certificate_binding" "www" {
  for_each            = var.siteConfig
  certificate_id      = azurerm_app_service_managed_certificate.www[each.key].id
  hostname_binding_id = var.bindingId-www["www.${each.value.dnsName}"]
  ssl_state           = "SniEnabled"
}
resource "azurerm_app_service_certificate_binding" "root" {
  for_each            = var.siteConfig
  certificate_id      = azurerm_app_service_managed_certificate.www[each.key].id
  hostname_binding_id = var.bindingId-root["${each.value.dnsName}"]
  ssl_state           = "SniEnabled"
}
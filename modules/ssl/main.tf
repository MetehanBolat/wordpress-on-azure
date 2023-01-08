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

resource "tls_private_key" "key" {
  for_each  = var.siteConfig
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "acme_registration" "reg" {
  for_each        = var.siteConfig
  account_key_pem = tls_private_key.key[each.key].private_key_pem
  email_address   = each.value.email
}

# As the certificate will be generated in PFX a password is required
resource "random_password" "pfx" {
  for_each = var.siteConfig
  length   = 24
  special  = true
}

resource "tls_cert_request" "req" {
  for_each        = var.siteConfig
  private_key_pem = tls_private_key.key[each.key].private_key_pem
  dns_names       = ["${each.value.dnsName}","*.${each.value.dnsName}"]

  subject {
    common_name = "*.${each.value.dnsName}"
  }
}

## Gets a certificate from the ACME server
resource "acme_certificate" "cert" {
  depends_on               = [ azurerm_role_assignment.serviceprincipal ]
  for_each                 = var.siteConfig
  account_key_pem          = acme_registration.reg[each.key].account_key_pem
  certificate_request_pem  = tls_cert_request.req[each.key].cert_request_pem
  certificate_p12_password = random_password.pfx[each.key].result

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_RESOURCE_GROUP  = var.resource_group_name
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

resource "azurerm_key_vault_certificate" "pfx" {
  for_each            = var.siteConfig
  name                = each.value.name
  key_vault_id        = var.keyVaultId

  certificate {
    contents = acme_certificate.cert[each.key].certificate_p12
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

#resource "azurerm_app_service_certificate_binding" "www" {
#  #for_each            = var.siteConfig
#  certificate_id      = azurerm_app_service_managed_certificate.www.id
#  hostname_binding_id = var.bindingId-www#["www.${var.siteConfig.dnsName}"]
#  ssl_state           = "SniEnabled"
#}
#resource "azurerm_app_service_certificate_binding" "root" {
#  #for_each            = var.siteConfig
#  certificate_id      = azurerm_app_service_managed_certificate.www.id
#  hostname_binding_id = var.bindingId-root#["${var.siteConfig.dnsName}"]
#  ssl_state           = "SniEnabled"
#}


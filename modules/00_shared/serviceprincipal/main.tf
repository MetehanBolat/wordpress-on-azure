locals {
  ## Azure CDN App
  applicationId = "205478c0-bd83-4e1b-a9d6-db63a3e1e1c8"
}

data "azuread_client_config" "current" {}

# Retrieve domain information
data "azuread_domains" "domain" {
  only_initial = true
}

## Create an application
resource "azuread_application" "acme" {
  display_name     = "AcmeApplication"
  owners           = [data.azuread_client_config.current.object_id]
  identifier_uris  = ["api://AcmeVerification"]
  sign_in_audience = "AzureADMultipleOrgs"

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access example on behalf of the signed-in user."
      admin_consent_display_name = "Access example"
      enabled                    = true
      id                         = "96183846-204b-4b43-82e1-5d2222eb4b9b"
      type                       = "User"
      user_consent_description   = "Allow the application to access example on your behalf."
      user_consent_display_name  = "Access example"
      value                      = "user_impersonation"
    }
  }

  feature_tags {
    enterprise = true
    gallery    = false
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }

    resource_access {
      id   = "b4e74841-8e56-480b-be8b-910348b18b4c" # User.ReadWrite
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = "c5393580-f805-4401-95e8-94b7a6ef2fc2" # Office 365 Management

    resource_access {
      id   = "594c1fb6-4f81-4475-ae41-0c394909246c" # ActivityFeed.Read
      type = "Role"
    }
  }
}

# Create a service principal
resource "azuread_service_principal" "acme" {
  application_id               = azuread_application.acme.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise            = true
    gallery               = false
    custom_single_sign_on = false
    hide                  = false
  }
}

# Create a secret for the service principal
resource "azuread_service_principal_password" "acme" {
  service_principal_id = azuread_service_principal.acme.object_id
}

#resource "azuread_service_principal" "cdn" {
#  application_id = local.applicationId
#  use_existing   = true
#}
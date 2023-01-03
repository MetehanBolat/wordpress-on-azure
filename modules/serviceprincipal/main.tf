data "azuread_client_config" "current" {}

# Retrieve domain information
data "azuread_domains" "domain" {
  only_initial = true
}

# Create an application
resource "azuread_application" "acme" {
  display_name = "AcmeApplication"
  owners       = [data.azuread_client_config.current.object_id]
}

# Create a service principal
resource "azuread_service_principal" "acme" {
  application_id               = azuread_application.acme.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  feature_tags {
    enterprise = true
    gallery    = true
  }
}

# Create a secret for the service principal
resource "azuread_service_principal_password" "acme" {
  service_principal_id = azuread_service_principal.acme.object_id
}


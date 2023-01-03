## AzureRM (Azure) provider

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.37.0"
    }
  }
}

## AzureAD (Azure Active Directory) provider
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 2.31.0"
    }
  }
}

terraform {
  required_providers {
    # The provider is declared here just like any provider...
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.5"
    }
  }
}
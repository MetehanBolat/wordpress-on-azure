### Wordpress (Windows App Service) Module

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.28.0"
    }
  }
}

provider "azurerm" {
  features {}
}

## Windows App Service
resource "azurerm_windows_web_app" "app" {
  for_each            = var.siteConfig
  name                = each.value.name
  resource_group_name = var.resourceGroupName
  location            = var.location
  service_plan_id     = var.spId

  site_config {
    always_on                = true
    local_mysql_enabled      = true
    managed_pipeline_mode    = each.value.managedPipeline
    minimum_tls_version      = "1.2"
    scm_minimum_tls_version  = "1.2"
    use_32_bit_worker        = true
    remote_debugging_enabled = false
    vnet_route_all_enabled   = false
    websockets_enabled       = false
    worker_count             = each.value.workerCount
    application_stack {
      current_stack          = each.value.appStack
      php_version            = each.value.appStack == "php"    ? each.value.appStackVersion : null
      dotnet_version         = each.value.appStack == "dotnet" ? each.value.appStackVersion : null
      node_version           = each.value.appStack == "node"   ? each.value.appStackVersion : null
      python_version         = each.value.appStack == "python" ? each.value.appStackVersion : null
      java_version           = each.value.appStack == "java"   ? each.value.appStackVersion : null
      java_container         = each.value.appStack == "java"   ? each.value.javaContainer        : null
      java_container_version = each.value.appStack == "java"   ? each.value.javaContainerVersion : null
    }
  }
  app_settings = {
    "DB_SSL_CONNECTION" = "false"
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ var.id ]
  }
}

## Setting source control if enabled on siteConfig
resource "null_resource" "deploy" {
  depends_on = [ azurerm_windows_web_app.app ]
  for_each  = var.siteConfig
  provisioner "local-exec" {
    command = null != each.value.repo ? "${path.module}/Set-SourceControl.ps1 -webAppName ${azurerm_windows_web_app.app[each.key].name} -appResourceGroupName ${azurerm_windows_web_app.app[each.key].resource_group_name} -scmBranch ${each.value.branch} -repoUrl ${each.value.repo}" : "Write-Host no repo found" 
    interpreter = ["PowerShell", "-Command"]
  }
}
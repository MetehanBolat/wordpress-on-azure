### Wordpress (Windows App Service) Module
provider "azurerm" {
  features {}
}

locals {
  storageName = "${lower(replace(replace("${var.resourcePrefix}","-",""),"_",""))}strassets"
}

## storage account for assets
resource "azurerm_storage_account" "storage" {
  name                              = length(local.storageName) >= 24 ? substr(local.storageName,0,24) : local.storageName
  resource_group_name               = var.resourceGroupName
  location                          = var.location
  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  access_tier                       = "Hot"
  enable_https_traffic_only         = true
  min_tls_version                   = "TLS1_2"
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = true

  identity {
    type = "UserAssigned"
    identity_ids = [ var.id ]
  }

  network_rules {
    default_action = "Allow"
  }
}
## File share
resource "azurerm_storage_share" "container" {
  for_each             = var.siteConfig
  name                 = each.value.name
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 50
}
resource "azurerm_storage_container" "container" {
  for_each              = var.siteConfig
  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "blob"
}

## Connection string secret
resource "azurerm_key_vault_secret" "connectionString" {
  for_each     = var.siteConfig
  name         = "mysql-cs-${each.value.name}"
  value        = "Database=${each.value.name}-db;Data Source=${var.serverFqdn};User Id=${var.adminName}@${var.serverName};Password=${var.adminPassword}"
  key_vault_id = var.keyVaultId
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
    local_mysql_enabled      = false
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
    "MICROSOFT_AZURE_USE_FOR_DEFAULT_UPLOAD" = "true"
    "MICROSOFT_AZURE_ACCOUNT_NAME"           = "${azurerm_storage_account.storage.name}"
    "MICROSOFT_AZURE_ACCOUNT_KEY"            = "${azurerm_storage_account.storage.primary_access_key}"
    "MICROSOFT_AZURE_CONTAINER"              = "${azurerm_storage_container.container[each.key].name}"
  }

  connection_string {
    name  = "default"
    type  = "MySql"
    value = azurerm_key_vault_secret.connectionString[each.key].value
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ var.identityId ]
  }
}
data "azurerm_subscription" "current" {}

## Setting source control if enabled on siteConfig
resource "null_resource" "deploy" {
  depends_on = [ azurerm_windows_web_app.app ]
  for_each  = var.siteConfig
  provisioner "local-exec" {
    command = null != each.value.repo ? "${path.module}/Set-SourceControl.ps1 -webAppName ${azurerm_windows_web_app.app[each.key].name} -appResourceGroupName ${azurerm_windows_web_app.app[each.key].resource_group_name} -currentSubId ${data.azurerm_subscription.current.subscription_id} -scmBranch ${each.value.branch} -repoUrl ${each.value.repo}" : "Write-Host no repo found" 
    interpreter = ["PowerShell", "-Command"]
  }
  triggers = {
    content = file("${path.module}/Set-SourceControl.ps1")
  }
}

#Database=database-name;Data Source=database-host;User Id=database-username;Password=database-password

resource "azurerm_app_service_custom_hostname_binding" "root" {
  for_each            = var.siteConfig
  hostname            = each.value.dnsName
  app_service_name    = azurerm_windows_web_app.app[each.key].name
  resource_group_name = azurerm_windows_web_app.app[each.key].resource_group_name
}

resource "azurerm_app_service_custom_hostname_binding" "www" {
  for_each            = var.siteConfig
  hostname            = "www.${each.value.dnsName}"
  app_service_name    = azurerm_windows_web_app.app[each.key].name
  resource_group_name = azurerm_windows_web_app.app[each.key].resource_group_name
}
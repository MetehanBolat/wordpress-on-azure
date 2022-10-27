
## Service Plan Resource Group Name
output "rg" {
  value = azurerm_service_plan.sp.resource_group_name
}

## Service Plan Name
output "spName" {
  value = azurerm_service_plan.sp.name
}

## Service Plan ResourceId
output "spId" {
  value = azurerm_service_plan.sp.id
}
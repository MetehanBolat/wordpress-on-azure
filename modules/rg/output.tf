## Resource Group Name
output "rg" {
  value = azurerm_resource_group.rg.name
}

## Resource Group ResourceId (for role assignments)
output "rgId" {
  value = azurerm_resource_group.rg.id
}
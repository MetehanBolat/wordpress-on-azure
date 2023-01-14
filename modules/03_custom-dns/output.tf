output "bindingId-www" {
  value = {for binding in azurerm_app_service_custom_hostname_binding.www: binding.hostname => binding.id}
}
output "bindingId-root" {
  value = {for binding in azurerm_app_service_custom_hostname_binding.root: binding.hostname => binding.id}
}

output "certificateId-www" {
  value = {for www in azurerm_app_service_managed_certificate.www: www.custom_hostname_binding_id => www.id }
}
output "certificateId-root" {
  value = {for root in azurerm_app_service_managed_certificate.root: root.custom_hostname_binding_id => root.id }
}

#output "cdnDns" {
#  value = {for cdn in azurerm_dns_cname_record.cdn: cdn.zone_name => "${cdn.name}.${cdn.zone_name}"}
#}
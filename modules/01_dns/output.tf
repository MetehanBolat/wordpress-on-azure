## DNS Zone
output "dnsZoneId" {
  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.id}
}

output "dnsZone" {
  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.name}
}

output "rg" {
  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.resource_group_name}
}

#output "bindingId-root" {
#  value = { for root in azurerm_app_service_custom_hostname_binding.root: root.hostname => root.id }
#}
#
#output "bindingId-www" {
#  value = { for www in azurerm_app_service_custom_hostname_binding.www: www.hostname => www.id }
#}
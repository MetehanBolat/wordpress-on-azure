## DNS Zone
output "dnsZoneId" {
  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.id}
}

#output "dns_zone_name" {
#  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.name}
#}

output "dns_resource_group_name" {
  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.resource_group_name}
}
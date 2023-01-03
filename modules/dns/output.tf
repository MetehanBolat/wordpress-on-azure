## DNS Zone

output "dnsZoneId" {
  value = {for dns in azurerm_dns_zone.dns-public: dns.name => dns.id}
}
#resource "azurerm_cdn_endpoint" "cdn" {
#  for_each            = var.siteConfig
#  name                = each.value.name
#  profile_name        = var.cdnProfileName
#  location            = var.location
#  resource_group_name = var.cdnRGName
#
#  optimization_type   = "GeneralWebDelivery"
#  origin {
#    name      = each.value.name
#    host_name = var.storageFqdn
#  }
#  origin_host_header = "cdn.${each.value.dnsName}"
#  origin_path        = "/${each.value.name}/"
#}


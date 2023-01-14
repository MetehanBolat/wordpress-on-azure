variable "keyVaultId" {
  type = string
  description = "ResourceId of the key vault resource"
}
variable "storageSAS" {
  type = string
  description = "SAS Uri to store certificate assets"
}
variable "endpoint" {
  type = string
  description = "Acme Prod or staging endpoint"
  default = "LE_PROD" ##LE_STAGE
}
variable "siteConfig" {
  description = "DNS Settings"
}
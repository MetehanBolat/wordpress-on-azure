variable "resourcePrefix" {
  type        = string
  description = "prefix for resource naming (<resourcePrefix>-<resourceType>)"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "resourcePrefix" {
  type        = string
  description = "prefix for resource naming (<resourcePrefix>-<resourceType>)"
}
variable "resourceGroupName" {
  type        = string
  description = "Name of the existing resourceGroup, to deploy resources"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
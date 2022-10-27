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
variable "skuName" {
  type        = string
  description = "SKU for Service Plan"
  default     = "B1"
}
variable "osType" {
  type        = string
  description = "SKU for Service Plan"
  default     = "Windows"
}
variable "workerCount" {
  type        = number
  description = "Default number of instances for service plan"
  default     = 1
}
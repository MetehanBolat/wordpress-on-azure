variable "resourcePrefix" {
  type        = string
  description = "prefix for resource naming (<resourcePrefix>-<resourceType>)"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "servicePlanSku" {
  type        = string
  description = "SKU for Service Plan"
  default     = "B1"
}
variable "servicePlanWorkerCount" {
  type        = number
  description = "Default number of instances for service plan"
  default     = 1
}
variable "adminName" {
  type        = string
  description = "Username for MySQL Server Admin Login"
  sensitive   = true
}
variable "adminPassword" {
  type        = string
  description = "Password for MySQL Server Admin Login"
  sensitive   = true
}
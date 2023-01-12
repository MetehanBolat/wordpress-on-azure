variable "resourcePrefix" {
  type        = string
  description = "prefix for resource naming (<resourcePrefix>-<resourceType>)"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
variable "resource_group_name" {
  type        = string
  description = "Name of the existing resourceGroup, to deploy resources"
}
variable "principalId" {
  type        = string
  description = "ObjectId of the managed identity, to set RBAC"
}
variable "cdnPrincipalId" {
  type        = string
  description = "ObjectId of the Azure CDN Gallery Application, to set RBAC"
}
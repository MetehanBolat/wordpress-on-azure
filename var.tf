variable "resourcePrefix" {
  type        = string
  description = "prefix for resource naming (<resourcePrefix>-<resourceType>)"
}
variable "location" {
  type        = string
  description = "Azure Location to deploy resources"
}
## App Service Plan Configuration
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
## App Service Configuration
variable "siteConfig" {
  description = "App Service Configuration (repo/appSettings/etc)"
  default = {
    site01 = {
      name            = "sitename"
      repo            = "https://github.com/someAccount/someRepo" ## if null, no deployments
      branch          = "master" ## makes sense only if repo is not null
      appStack        = "php"
      appStackVersion = "7.4"
      managedPipeline = "Classic"
      workerCount     = 1
    }
  }
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
variable "adminContact" {
  type        = string
  description = "Email address for ACME verification"
}
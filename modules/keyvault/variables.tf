variable "resource_group_name" {
  description = "name of the resource group"
  type        = string
}

variable "name" {
  description = "name of the keyvault"
  type        = string
}

variable "location" {
  description = "azure region"
  type        = string
}

variable "tags" {
  description = "tags for the keyvault"
  type        = map(string)
}
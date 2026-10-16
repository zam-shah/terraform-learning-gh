variable "rg_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "uksouth"
}

variable "tags" {
  description = "Tags for the resource group"
  type        = map(string)
  default     = {}
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}


variable "name" {
  description = "Name of the storage account. Must be globally unique, lowercase alphanumeric, 3-24 characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be 3-24 lowercase letters and numbers only."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group to create the storage account in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "replication_type" {
  description = "Replication type: LRS, ZRS, GRS, or GZRS"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.replication_type)
    error_message = "Replication type must be one of: LRS, ZRS, GRS, GZRS."
  }
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
}

variable "blob_retention_days" {
  description = "Days to retain soft-deleted blobs and containers"
  type        = number
  default     = 7

  validation {
    condition     = var.blob_retention_days >= 7 && var.blob_retention_days <= 365
    error_message = "Retention must be between 7 and 365 days."
  }
}
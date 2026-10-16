variable "cluster_name" {
  description = "Name of the AKS cluster. Also used as the DNS prefix, so must be unique within the region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the cluster in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to pin the cluster to"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the system node pool"
  type        = number
  default     = 2

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "VM size for the system node pool"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags to apply to the cluster"
  type        = map(string)
}

variable "acr_id" {
  description = "Resource ID of the Azure Container Registry the cluster should pull from"
  type        = string
}

variable "private_cluster_enabled" {
  description = "Whether the cluster API server should be private. Public clusters are reachable from Microsoft-hosted build agents; private clusters require an agent inside the VNet."
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Days to retain logs in the Log Analytics workspace"
  type        = number
  default     = 30

  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "upgrade_channel" {
  description = "AKS automatic upgrade channel: none, patch, rapid, stable, or node-image"
  type        = string
  default     = "patch"


  validation {
    condition     = contains(["none", "patch", "rapid", "stable", "node-image"], var.upgrade_channel)
    error_message = "Upgrade channel must be one of: none, patch, rapid, stable, node-image."
  }
}

variable "aks_admin_group_object_id" {
  description = "Entra ID group object ID granted cluster-admin on this AKS cluster"
  type        = string
}

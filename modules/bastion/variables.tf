variable "resource_group_name" {
  description = "Resource group to create the Bastion, jumpbox, and their VNet in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
}

variable "aks_vnet_id" {
  description = "Resource ID of the AKS cluster's auto-created VNet, for peering"
  type        = string
}

variable "aks_vnet_name" {
  description = "Name of the AKS cluster's auto-created VNet"
  type        = string
}

variable "aks_vnet_resource_group" {
  description = "Resource group containing the AKS cluster's auto-created VNet (the MC_ group)"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the jumpbox VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for jumpbox VM access (paste the contents of your .pub file)"
  type        = string
}
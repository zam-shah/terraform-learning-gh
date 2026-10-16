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

variable "keyvault_name" {
  description = "name of keyvault"
  type        = string

}

variable "postgres_server_name" {
  description = "name of postgresql"
  type        = string

}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
}

variable "aks_admin_group_object_id" {
  description = "Entra ID group object ID granted cluster-admin on this AKS cluster"
  type        = string
}

variable "vnet_name" {
  description = "name of the vnet"
  type        = string
}

variable "vnet_address_space" {
  description = "The vnet range"
  type        = list(string)
}

variable "aks_subnet_prefix" {
  description = "AKS subnet range"
  type        = string
}

variable "postgres_subnet_prefix" {
  description = "postgres subnet range"
  type        = string
}

#variable "jumpbox_ssh_public_key" {
#description = "SSH public key for jumpbox VM access"
#type        = string
#}
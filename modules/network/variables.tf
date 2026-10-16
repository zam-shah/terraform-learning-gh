variable "name" {
  description = "name of the network"
  type        = string
}

variable "location" {
  description = "azure region"
  type        = string
}

variable "resource_group_name" {
  description = "name of the resource group"
  type        = string
}

variable "tags" {
  description = "holds tags"
  type        = map(string)
}

variable "address_space" {
  description = "Vnet range"
  type        = list(string)
}

variable "aks_subnet_prefix" {
  description = "AKS subnet range"
  type        = string
}

variable "postgres_subnet_prefix" {
  description = "Postgres subnet range"
  type        = string
}
variable "name" {
  description = "Name of the NSG"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group the NSG will be created in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "direction" {
  description = "Inbound or Outbound"
  type        = string
}

variable "action" {
  description = "Allow or Deny"
  type        = string
}

variable "source_address" {
  description = "Source address prefix (IP range, or an Azure tag like Internet)"
  type        = string
}

variable "destination_port" {
  description = "Destination port this rule applies to"
  type        = string
}

variable "protocol" {
  description = "TCP, UDP or *"
  type        = string
}
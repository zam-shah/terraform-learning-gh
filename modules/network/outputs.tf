output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "aks_subnet_id" {
  description = "ID of AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "postgres_subnet_id" {
  description = "ID of postgres"
  value       = azurerm_subnet.postgres.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}
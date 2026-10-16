output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  description = "Resource ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity, used for granting ACR pull access"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
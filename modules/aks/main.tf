resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}



resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  automatic_upgrade_channel = var.upgrade_channel
  azure_policy_enabled      = true
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  private_cluster_enabled = var.private_cluster_enabled
  private_dns_zone_id     = var.private_cluster_enabled ? "System" : null

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = var.vm_size


    upgrade_settings {
      max_surge = "10%"
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  identity {
    type = "SystemAssigned"
  }

  workload_autoscaler_profile {
    keda_enabled                    = true
    vertical_pod_autoscaler_enabled = false
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  }

  role_based_access_control_enabled = true
  local_account_disabled            = false

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = false
    admin_group_object_ids = [var.aks_admin_group_object_id]
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}



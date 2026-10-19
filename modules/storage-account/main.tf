resource "azurerm_storage_account" "this" {
  # checkov:skip=CKV_AZURE_33:Queue service is not used by consumers of this module
  # checkov:skip=CKV_AZURE_206:Replication is a per-environment decision; prod uses GRS via var.replication_type
  # checkov:skip=CKV2_AZURE_33:Private endpoint requires VNet infrastructure not in scope for this module
  # checkov:skip=CKV2_AZURE_1:Platform-managed keys are sufficient; CMK adds Key Vault dependency

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = var.replication_type

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = false
  shared_access_key_enabled       = false

  tags = var.tags


  blob_properties {
    delete_retention_policy {
      days = var.blob_retention_days
    }

    container_delete_retention_policy {
      days = var.blob_retention_days
    }
  }

  sas_policy {
    expiration_period = "01.00:00:00"
    expiration_action = "Log"
  }
}


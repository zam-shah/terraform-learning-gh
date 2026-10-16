terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }


  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatezam0809"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"

  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {}
}

module "resource_group" {
  # checkov:skip=CKV_TF_1:Internal module in a repo we control; tags are managed by the platform team and semantic versions are needed for consumer communication
  source = "git::https://zamhshah0763@dev.azure.com/zamhshah0763/terraform-learning/_git/terraform-learning//modules/resource-group?ref=v1.1.0"

  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  name                = var.keyvault_name
  location            = var.location
  resource_group_name = module.resource_group.rg_name
  tags                = var.tags
}

module "network" {
  source = "../../modules/network"

  name                   = var.vnet_name
  location               = var.location
  resource_group_name    = module.resource_group.rg_name
  address_space          = var.vnet_address_space
  aks_subnet_prefix      = var.aks_subnet_prefix
  postgres_subnet_prefix = var.postgres_subnet_prefix
  tags                   = var.tags

}

module "storage_account" {
  source = "../../modules/storage-account"

  name                = var.storage_account_name
  resource_group_name = module.resource_group.rg_name
  location            = var.location
  replication_type    = "LRS"
  tags                = var.tags
}

module "aks" {
  source = "../../modules/aks"

  cluster_name              = var.cluster_name
  resource_group_name       = module.resource_group.rg_name
  location                  = var.location
  kubernetes_version        = var.kubernetes_version
  node_count                = 3
  vm_size                   = "Standard_B2s"
  tags                      = var.tags
  acr_id                    = data.azurerm_container_registry.acr.id
  private_cluster_enabled   = false
  aks_admin_group_object_id = var.aks_admin_group_object_id
}

data "azurerm_container_registry" "acr" {
  name                = "acrtflearnzam"
  resource_group_name = "rg-tflearn-dev"
}

data "azurerm_subscription" "current" {}


resource "azurerm_subscription_policy_assignment" "require_owner_tag" {
  name                 = "require-owner-tag-rg"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  subscription_id      = data.azurerm_subscription.current.id
  enforce              = true # true = Default (enforcing/deny), false = DoNotEnforce (audit)

  parameters = jsonencode({
    tagName = {
      value = "owner"
    }
  })
}

resource "random_password" "postgres_admin" {
  length  = 24
  special = true
}

resource "azurerm_key_vault_secret" "postgres_admin_password" {
  name         = "postgres-admin-password"
  value        = random_password.postgres_admin.result
  key_vault_id = module.keyvault.id
}

resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.postgres_server_name
  resource_group_name           = module.resource_group.rg_name
  location                      = var.location
  version                       = "16"
  administrator_login           = "abideadmin"
  administrator_password        = random_password.postgres_admin.result
  storage_mb                    = 32768
  sku_name                      = "B_Standard_B1ms"
  zone                          = "1"
  delegated_subnet_id           = module.network.postgres_subnet_id
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.postgres]
}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "abide-dev.postgres.database.azure.com"
  resource_group_name = module.resource_group.rg_name
  tags                = var.tags
}
resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "link-vnet-tflearn-dev"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = module.resource_group.rg_name
  virtual_network_id    = module.network.vnet_id
  tags                  = var.tags
}

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  resource_group_name = module.resource_group.rg_name
}

data "azurerm_resources" "aks_vnet" {
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
  type                = "Microsoft.Network/virtualNetworks"
}

resource "azurerm_virtual_network_peering" "vnet_to_aks" {
  name                      = "peer-vnet-to-aks"
  resource_group_name       = module.resource_group.rg_name
  virtual_network_name      = module.network.vnet_name
  remote_virtual_network_id = data.azurerm_resources.aks_vnet.resources[0].id
}

resource "azurerm_virtual_network_peering" "aks_to_vnet" {
  name                      = "peer-aks-to-vnet"
  resource_group_name       = data.azurerm_kubernetes_cluster.aks.node_resource_group
  virtual_network_name      = data.azurerm_resources.aks_vnet.resources[0].name
  remote_virtual_network_id = module.network.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres_aks" {
  name                  = "link-aks-vnet"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = module.resource_group.rg_name
  virtual_network_id    = data.azurerm_resources.aks_vnet.resources[0].id
  tags                  = var.tags
}

#module "nsg" {
# source = "../../modules/nsg"

#  name                = "nsg-bastion-ssh"
#  resource_group_name = module.resource_group.rg_name
#  location            = var.location
#  direction           = "Inbound"
#  action              = "Allow"
#  protocol            = "Tcp"
#  destination_port    = "22"
#  source_address      = "10.1.0.0/26" # AzureBastionSubnet CIDR — replace with module.bastion output once bastion module is active
#}

#data "azurerm_kubernetes_cluster" "this" {
#  name                = module.aks.cluster_name
# resource_group_name = module.resource_group.rg_name
#}

#data "azurerm_resources" "aks_vnet" {
#  resource_group_name = data.azurerm_kubernetes_cluster.this.node_resource_group
#  type                 = "Microsoft.Network/virtualNetworks"
#}

#module "bastion" {
#  source = "../../modules/bastion"
#
#  location                = var.location
#  resource_group_name     = module.resource_group.rg_name
#  tags                    = var.tags
#  aks_vnet_id             = data.azurerm_resources.aks_vnet.resources[0].id
#  aks_vnet_name           = data.azurerm_resources.aks_vnet.resources[0].name
#  aks_vnet_resource_group = data.azurerm_kubernetes_cluster.this.node_resource_group
#  ssh_public_key          = var.jumpbox_ssh_public_key
#}
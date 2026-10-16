terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }


  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstatezam0809"
    container_name       = "tfstate-gh"
    key                  = "gh-dev.terraform.tfstate"
    use_oidc             = true
    use_azuread_auth     = true

  }
}

provider "azurerm" {
  storage_use_azuread = true
  use_oidc            = true
  features {}
}

module "resource_group" {
  # checkov:skip=CKV_TF_1:Internal module in a repo we control; tags are managed by the platform team and semantic versions are needed for consumer communication
  source   = "../../modules/resource-group"
  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}



module "storage_account" {
  source = "../../modules/storage-account"

  name                = var.storage_account_name
  resource_group_name = module.resource_group.rg_name
  location            = var.location
  replication_type    = "LRS"
  tags                = var.tags
}


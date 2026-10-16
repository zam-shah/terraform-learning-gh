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
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}
provider "azurerm" {
  storage_use_azuread = true
  features {}
}

module "resource_group" {
  source = "../../modules/resource-group"

  rg_name  = var.rg_name
  location = var.location
  tags     = var.tags
}

module "storage_account" {
  source = "../../modules/storage-account"

  name                = var.storage_account_name
  resource_group_name = module.resource_group.rg_name
  location            = var.location
  replication_type    = "GRS"
  tags                = var.tags
}
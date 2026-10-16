resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.location
  tags     = merge(var.tags, { module_version = "v2" })
}
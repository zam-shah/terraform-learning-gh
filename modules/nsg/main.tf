resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "this" {
  name                        = "${var.name}-rule"
  priority                    = 100
  direction                   = var.direction
  access                      = var.action
  protocol                    = var.protocol
  source_port_range           = "*"
  destination_port_range      = var.destination_port
  source_address_prefix       = var.source_address
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}
resource "azurerm_virtual_network" "bastion" {
  name                = "vnet-bastion-dev"
  address_space       = ["10.1.0.0/24"]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = ["10.1.0.0/26"]
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "snet-jumpbox"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bastion.name
  address_prefixes     = ["10.1.0.64/28"]
}

resource "azurerm_virtual_network_peering" "bastion_to_aks" {
  name                      = "peer-bastion-to-aks"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.bastion.name
  remote_virtual_network_id = var.aks_vnet_id
}

resource "azurerm_virtual_network_peering" "aks_to_bastion" {
  name                      = "peer-aks-to-bastion"
  resource_group_name       = var.aks_vnet_resource_group
  virtual_network_name      = var.aks_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.bastion.id
}

data "azurerm_resources" "aks_private_dns_zone" {
  resource_group_name = var.aks_vnet_resource_group
  type                = "Microsoft.Network/privateDnsZones"
}

resource "azurerm_private_dns_zone_virtual_network_link" "bastion_to_aks_dns" {
  name                  = "link-bastion-vnet"
  resource_group_name   = var.aks_vnet_resource_group
  private_dns_zone_name = data.azurerm_resources.aks_private_dns_zone.resources[0].name
  virtual_network_id    = azurerm_virtual_network.bastion.id
  tags                  = var.tags
}

resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = "bastion-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  tags                = var.tags

  ip_configuration {
    name                 = "bastion-ipconfig"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "nic-jumpbox-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "vm-jumpbox-dev"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_B1s"
  admin_username      = var.admin_username
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.jumpbox.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
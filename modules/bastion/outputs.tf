output "bastion_name" {
  description = "Name of the Bastion host"
  value       = azurerm_bastion_host.this.name
}

output "jumpbox_vm_name" {
  description = "Name of the jumpbox VM, used when connecting via Bastion"
  value       = azurerm_linux_virtual_machine.jumpbox.name
}

output "jumpbox_private_ip" {
  description = "Private IP of the jumpbox, for reference"
  value       = azurerm_network_interface.jumpbox.private_ip_address
}
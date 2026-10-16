output "id" {
  description = "id of the keyvault"
  value       = azurerm_key_vault.this.id

}

output "uri" {
  description = "uri for the keyvault"
  value       = azurerm_key_vault.this.vault_uri

}
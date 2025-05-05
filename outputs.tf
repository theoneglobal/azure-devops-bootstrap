output "storage_account_name" {
  value = azurerm_storage_account.bootstrap_storage.name
}

output "resource_group_name" {
  value = azurerm_resource_group.bootstrap_rg.name
}

output "container_name" {
  value = azurerm_storage_container.bootstrap_container.name
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "hostpool_id" {
  value = azurerm_virtual_desktop_host_pool.hostpool.id
}

output "hostpool_name" {
  value = azurerm_virtual_desktop_host_pool.hostpool.name
}

output "managed_identity_name" {
  value = azurerm_virtual_desktop_host_pool_registration_info.token.token
}
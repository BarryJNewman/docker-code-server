resource "random_pet" "prefix" {}

resource "azurerm_resource_group" "sse" {
  name     = "${random_pet.prefix.id}-rg"
  location = var.location
}

// Key Vault and Disk Encryption Set
data "azurerm_client_config" "current" {}

locals {
  current_user_object_id = coalesce(var.msi_id, data.azurerm_client_config.current.object_id)
}

resource "azurerm_key_vault" "sse" {
  name                        = "${random_pet.prefix.id}-kv"
  location                    = azurerm_resource_group.sse.location
  resource_group_name         = azurerm_resource_group.sse.name
  sku_name                    = "premium"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
}

resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.sse.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = local.current_user_object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Update",
    "GetRotationPolicy",
  ]

  secret_permissions = [
    "Get",
    "Delete",
    "Set",
  ]
}

resource "azurerm_key_vault_key" "sse" {
  name         = "ssekey"
  key_vault_id = azurerm_key_vault.sse.id
  key_type     = "RSA-HSM"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault_access_policy.current_user]
}

resource "azurerm_disk_encryption_set" "sse" {
  name                = "${random_pet.prefix.id}-des"
  resource_group_name = azurerm_resource_group.sse.name
  location            = azurerm_resource_group.sse.location
  key_vault_key_id    = azurerm_key_vault_key.sse.id
  #encryption_type     = "ConfidentialVmEncryptedWithCustomerKey"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_key_vault_access_policy" "disk-encryption" {
  key_vault_id = azurerm_key_vault.sse.id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
  ]

  tenant_id = azurerm_disk_encryption_set.sse.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.sse.identity.0.principal_id
}

output "keyvaulturl" {
  value = azurerm_key_vault.sse.vault_uri
}

output "keyvaultid" {
  value = azurerm_key_vault.sse.id
}

output "keyid" {
  value = azurerm_key_vault_key.sse.id
}

output "en_set_id" {
  value = azurerm_disk_encryption_set.sse.id
}
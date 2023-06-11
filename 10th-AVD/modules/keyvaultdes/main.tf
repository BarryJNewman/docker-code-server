data "azurerm_client_config" "current" {}

resource "random_string" "random" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_key_vault" "des" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption = true
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enabled_for_deployment = true
  enabled_for_template_deployment = true
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
     "Create",
     "Delete",
     "Get",
     "Purge",
     "Recover",
     "Update",
     "List",
     "Decrypt",
     "Sign"
    ]
  }
}



# resource "azurerm_key_vault_access_policy" "des" {
#   key_vault_id = azurerm_key_vault.des.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id
#   object_id    = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "Get",
#     "List",
#     "Rotate"
#   ]
# }

# resource "azurerm_key_vault_key" "des" {
#   name         = var.key_name
#   key_vault_id = azurerm_key_vault.des.id
#   key_type     = "RSA"
#   key_size     = 2048

#   key_opts = [
#     "unwrapKey",
#     "wrapKey",
#   ]
# }

output "id" {
  value = azurerm_key_vault_key.des.id
}

# resource "azurerm_key_vault_access_policy" "service-principal" {
#   key_vault_id = azurerm_key_vault.des.id
#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "Create",
#     "Delete",
#     "Get",
#     "Update",
#   ]

#   secret_permissions = [
#     "Get",
#     "Delete",
#     "Set"
#   ]

# }

# then generate a key used to encrypt the disks
resource "azurerm_key_vault_key" "des" {
  name         = "AVD-DES-${random_string.random.id}"
  key_vault_id = azurerm_key_vault.des.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  
}

#######

resource "azurerm_disk_encryption_set" "en-set" {
    
  name                = var.en_set_name
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = azurerm_key_vault_key.des.id

  identity {
    type = "SystemAssigned"
  }
 
}

resource "azurerm_key_vault_access_policy" "vm-disk" {
    
  key_vault_id = azurerm_key_vault.des.id

  tenant_id = azurerm_disk_encryption_set.en-set.identity.0.tenant_id
  object_id = azurerm_disk_encryption_set.en-set.identity.0.principal_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "Purge",
    "Recover",
    "Update",
    "List",
    "Decrypt",
    "Sign"
  ]
}

# resource "azurerm_key_vault_access_policy" "kv-user" {
#   key_vault_id = azurerm_key_vault.des.id

#   tenant_id = data.azurerm_client_config.current.tenant_id
#   object_id = data.azurerm_client_config.current.object_id

#   key_permissions = [
#     "Create",
#     "Delete",
#     "Get",
#     "Purge",
#     "Recover",
#     "Update",
#     "List",
#     "Decrypt",
#     "Sign"
#   ]
# }

resource "azurerm_role_assignment" "vm-disk" {
  scope                = azurerm_key_vault.des.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.en-set.identity.0.principal_id
}

resource "azurerm_key_vault_access_policy" "kv-access-policy-des" {
    
  key_vault_id = azurerm_key_vault.des.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_disk_encryption_set.en-set.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}


# resource "azurerm_key_vault_access_policy" "disk-encryption" {
#   key_vault_id = azurerm_key_vault.des.id

#   key_permissions = [
#     "Get",
#     "WrapKey",
#     "UnwrapKey",
#   ]

#   tenant_id = azurerm_disk_encryption_set.des.identity.0.tenant_id
#   object_id = azurerm_disk_encryption_set.des.identity.0.principal_id
# }


# # # grant the Managed Identity of the Disk Encryption Set "Reader" access to the Key Vault
# resource "azurerm_role_assignment" "disk-encryption-read-keyvault" {
#   scope                = azurerm_key_vault.des.id
#   role_definition_name = "Reader"
#   principal_id         = azurerm_disk_encryption_set.des.identity.0.principal_id
# }

### add rando
# resource "azurerm_monitor_diagnostic_setting" "kv-diag" {
#   name               = "diag-keyvault-des"
#   target_resource_id = azurerm_key_vault.des.id
#   log_analytics_workspace_id = var.log_analytics_workspace_id
  
#   log {
#     category = "AuditEvent"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }
#   log {
#     category = "AzurePolicyEvaluationDetails"
#     enabled  = true

#     retention_policy {
#       enabled = true
#     }
#   }

#   metric {
#     category = "AllMetrics"

#     retention_policy {
#       enabled = true
#     }
#   }
# }

output "en_set_id" {
  value = azurerm_disk_encryption_set.en-set.id
}
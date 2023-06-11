resource "azurerm_resource_group" "rg_storage" {
  location = var.deploy_location
  name     = var.rg_stor
}

resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}
resource "azurerm_storage_account" "storage" {
  name                     = "stor${random_string.random.id}"
  resource_group_name      = azurerm_resource_group.rg_storage.name
  location                 = azurerm_resource_group.rg_storage.location
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
}

resource "azurerm_storage_share" "FSShare" {
  name                 = "fslogix"
  storage_account_name = azurerm_storage_account.storage.name
  depends_on           = [azurerm_storage_account.storage]
}

data "azurerm_role_definition" "storage_role" {
  name = "Storage File Data SMB Share Contributor"
}

data "azuread_group" "aad_group" {
  display_name = "RCWP-AVD-USERS-GP"
}

resource "azurerm_role_assignment" "af_role" {
  scope              = azurerm_storage_account.storage.id
  role_definition_id = data.azurerm_role_definition.storage_role.id
  principal_id       = data.azuread_group.aad_group.id
}
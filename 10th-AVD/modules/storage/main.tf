resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

#Create Storage Account
resource "azurerm_storage_account" "mystorage" {
  name                     = "${var.storage_account_name}${random_string.resource_code.result}"
  resource_group_name      = var.storage_resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#Create Blob Container
resource "azurerm_storage_container" "dscpakfiles" {
  name                  = "dscpakfiles${random_string.resource_code.result}"
  storage_account_name  = azurerm_storage_account.mystorage.name
  container_access_type = "private"
}

# Create Blob Container
# resource "azurerm_storage_container" "mycontainer" {
#   name                  = "modules"
#   storage_account_name  = azurerm_storage_account.mystorage.name
#   container_access_type = "private"
# }

#Create Azure File Share
# resource "azurerm_storage_share" "myshare" {
#   name                 = "fsl${random_string.resource_code.result}"
#   storage_account_name = azurerm_storage_account.mystorage.name
# }

### feed in from modules add later
# data "azurerm_storage_account" "dsc_storage_account" {
#   name = var.dsc_storage_account_name
#   resource_group_name = var.dsc_storage_account_rg
# }

# data "azurerm_storage_container" "dscpakfiles" {
#   name = "dscpakfiles"
#   storage_account_name = data.azurerm_storage_account.dsc_storage_account.name
# }

# resource "azurerm_storage_blob" "dscpak" {
#   name                   = "${var.hostname_id}.zip"
#   storage_account_name   = data.azurerm_storage_account.dsc_storage_account.name
#   storage_container_name = data.azurerm_storage_container.dscpakfiles.name
#   type                   = "Block"
#   content_md5            = md5(file("./DSC/all.zip"))
#   source                 = "./DSC/all.zip"
# }

# get storage account

output "name" {
  value = azurerm_storage_account.mystorage.name
}
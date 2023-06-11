data "azurerm_storage_account" "dsc_storage_account" {
  name = var.dsc_storage_account_name
  resource_group_name = var.dsc_storage_account_rg
}

data "azurerm_storage_container" "dscpakfiles" {
  name = "dscpakfiles"
  storage_account_name = data.azurerm_storage_account.dsc_storage_account.name
}

data "archive_file" "init" {
  type        = "zip"
  source_dir  = "src/${var.dscpak_name}"
  output_path = "DSC/${var.dscpak_name}"
}

resource "null_resource" "provision-builder" {
  triggers = {
    src_hash = "${data.archive_file.init.output_md5}"
  }

  provisioner "local-exec" {
    command = "echo 'extenstion triggered'"
    #command = "az vm extension delete --ids ${var.virtual_machine_id}"
    interpreter = ["PowerShell", "-Command"]
  }
}
resource "azurerm_storage_blob" "dscpak" {
  name                   = "${var.dscpak_name}.zip"
  storage_account_name   = data.azurerm_storage_account.dsc_storage_account.name
  storage_container_name = data.azurerm_storage_container.dscpakfiles.name
  type                   = "Block"
  content_md5            = data.archive_file.init.output_md5
  source                 = "./DSC/${var.dscpak_name}"
}

locals {
  expand_command                       = "Expand-archive ${azurerm_storage_blob.dscpak.name} C:/DSC/"
  exec_dsc                             = "C:/DSC/dscpak.ps1 ${var.domain_username} '${var.domain_password}' nulluri"
  run                                  =  " ${local.expand_command};${local.exec_dsc};"
}

resource "azurerm_virtual_machine_extension" "runDSC" {
  count                     = (var.runDSC) ? 1 : 0
  name                      = data.archive_file.init.output_md5
  #automatic_upgrade_enabled = true
  auto_upgrade_minor_version = true
  virtual_machine_id        = var.virtual_machine_id
  publisher                 = "Microsoft.Compute"
  type                      = "CustomScriptExtension"
  type_handler_version      = "1.10"
  depends_on                = [azurerm_storage_blob.dscpak]
  #lifecycle {
  #  create_before_destroy = true
  #}

   settings = <<SETTINGS
    {
      "fileUris": ["${azurerm_storage_blob.dscpak.url}"],
      "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"${local.run}\""
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "storageAccountName": "${data.azurerm_storage_account.dsc_storage_account.name}",
      "storageAccountKey": "${data.azurerm_storage_account.dsc_storage_account.primary_access_key}"
    }
  PROTECTED_SETTINGS
}
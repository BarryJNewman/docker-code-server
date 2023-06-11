data "azurerm_client_config" "current" {}

# data "azurerm_storage_account" "fslogix" {
#   name = var.fslogix_storage_account_name
#   resource_group_name = var.fslogix_storage_account_rg
# }

# data "azurerm_storage_account" "persistavd" {
#   name = var.persistavd_storage_account_name
#   resource_group_name = var.fslogix_storage_account_rg
# }

# data "azurerm_key_vault" "des" {
#   name = var.des_key_vault_name
#   resource_group_name = var.des_key_vault_resource_group_name
# }

resource "azurerm_availability_set" "avd" {
  name                         = "${var.prefix}-availability-set"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}

data azurerm_virtual_network vnet {
  name = var.avd_vnet_name
  resource_group_name = var.avd_vnet_rg
}

data "azurerm_shared_image" "avd_sig_image" {
  name                = var.azure_managed_image_name
  gallery_name        = var.azure_shared_image_gallery_name
  resource_group_name = var.azure_sig_resource_group_name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.avd_subnet_name
  resource_group_name  = var.avd_subnet_rg_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = var.avd_address_prefixes
  private_link_service_network_policies_enabled = "false"
  private_endpoint_network_policies_enabled = "false"
}

data azurerm_route_table rt {
  name = var.avd_route_table_name
  resource_group_name = var.avd_route_table_rg
}

#######################################################################
## Create FSLOGIX Privatelink Endpoint exsisting VNET
#######################################################################
# resource "azurerm_private_endpoint" "fslogix-pl"{
#   name                  = "${var.prefix}-fslogix-pl"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   subnet_id             = azurerm_subnet.subnet.id

  

#   private_service_connection {
#     name                           = "${var.prefix}-privateserviceconnectionw"
#     private_connection_resource_id = data.azurerm_storage_account.fslogix.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]    
#   }

#   ip_configuration {
#     name                          = "${var.prefix}-pl-ipconfigw"
#     #subnet_id                     = azurerm_subnet.subnet.id
#     #private_ip_address_allocation = "static"
#     private_ip_address            = var.fslogix_ip
#     subresource_name              = "blob"
#     #private_ip_address_version    = "IPv4"
#   }
  
#   # private_dns_zone_group {
#   #   name                  = var.private_dns_zone_name
#   #   private_dns_zone_ids  = [ var.private_dns_zone_ids ]
#   # }

#   lifecycle {
#     prevent_destroy = false
#     ignore_changes = all
#   }
# }

# resource "azurerm_private_dns_a_record" "fslogix" {
#   name                = data.azurerm_storage_account.fslogix.name 
#   zone_name           = var.private_dns_zone_name
#   resource_group_name = var.private_dns_resource_group
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.fslogix-pl.private_service_connection.0.private_ip_address]
# }
#######################################################################

#######################################################################
## Create PersistAVD Privatelink Endpoint exsisting VNET
#######################################################################
# resource "azurerm_private_endpoint" "persistavd-pl"{
#   name                  = "${var.prefix}-persistavd-pl"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   subnet_id             = azurerm_subnet.subnet.id

  

#   private_service_connection {
#     name                           = "${var.prefix}-privateserviceconnectionw"
#     private_connection_resource_id = data.azurerm_storage_account.persistavd.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]    
#   }

#   ip_configuration {
#     name                          = "${var.prefix}-pl-ipconfigw"
#     #subnet_id                     = azurerm_subnet.subnet.id
#     #private_ip_address_allocation = "static"
#     private_ip_address            = var.persistavd_ip
#     subresource_name              = "blob"
#     #private_ip_address_version    = "IPv4"
#   }
  
#   # private_dns_zone_group {
#   #   name                  = var.private_dns_zone_name
#   #   private_dns_zone_ids  = [ var.private_dns_zone_ids ]
#   # }

#   lifecycle {
#     prevent_destroy = false
#     ignore_changes = all
#   }
# }

# resource "azurerm_private_dns_a_record" "persistavd" {
#   name                = var.persistavd_dns
#   zone_name           = var.private_dns_zone_name
#   resource_group_name = var.private_dns_resource_group
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.persistavd-pl.private_service_connection.0.private_ip_address]
# }
#######################################################################

resource "azurerm_subnet_route_table_association" "session_hosts" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = data.azurerm_route_table.rt.id
  
  lifecycle {
    prevent_destroy = false
    ignore_changes = [ route_table_id ]
  }
}

# ######################################################################
# # Create KV Privatelink Endpoint exsisting VNET
# ######################################################################
# resource "azurerm_private_endpoint" "keyvault-pl"{
#   name                  = "${var.prefix}-kv-pl"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   subnet_id             = azurerm_subnet.subnet.id

#   lifecycle {
#     prevent_destroy = false
#     ignore_changes = all
#   }

#   private_service_connection {
#     name                           = "${var.prefix}-KV-PE"
#     private_connection_resource_id = data.azurerm_key_vault.des.id 
#     is_manual_connection           = false
#     subresource_names              = ["vault"]
#   }
#   ip_configuration {
#     name                          = "${var.prefix}-kv-pl-ipconfig"
#     #subnet_id                     = azurerm_subnet.subnet.id
#     #private_ip_address_allocation = "static"
#     private_ip_address            = var.keyvault_ip
#     subresource_name              = "vault"
#     member_name = "default"
#     #private_ip_address_version    = "IPv4"
#   }
    
# }

# resource "azurerm_private_dns_a_record" "keyvault" {
#   name                = lower(data.azurerm_key_vault.des.name)
#   zone_name           = var.private_dns_zone_name
#   resource_group_name = var.private_dns_resource_group
#   ttl                 = 300
#   records             = ["${var.keyvault_ip}"]
# }

resource "random_string" "random" {
  count  = var.avd_vm_count
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_network_interface" "nic" {
  name                = "AVD-${var.intune_environment}-${random_string.random[count.index].id}-${count.index + 1}-NIC"
  resource_group_name = var.resource_group_name
  location            = var.location
  count               = var.avd_vm_count

  ip_configuration {
    name                          = "webipconfig${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  depends_on = [
    #azurerm_private_endpoint.persistavd-pl,
    #azurerm_private_endpoint.fslogix-pl
  ]
}

resource "azurerm_windows_virtual_machine" "vm" {
  
  name                       = "${var.prefix}-${var.intune_environment}-${random_string.random[count.index].id}"
  computer_name              = "AVD-${var.intune_environment}-${random_string.random[count.index].id}${count.index + 1}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  size                       = var.avd_vm_size
  network_interface_ids      = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  count                      = var.avd_vm_count
  vtpm_enabled               = true
  secure_boot_enabled        = true
  license_type               = "Windows_Client"
  admin_username             = "localadmin"
  admin_password             = var.VMPassword
  enable_automatic_updates   = true
  provision_vm_agent         = true
  encryption_at_host_enabled = false
  availability_set_id        = azurerm_availability_set.avd.id
  #delete_os_disk_on_termination = true
  #delete_data_disks_on_termination = true
  #source_image_id = data.azurerm_shared_image.avd_sig_image.id

  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
 
  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-avd"
    version   = "latest"
  }

  # source_image_reference {
  #   publisher = "microsoftwindowsdesktop"
  #   offer     = "office-365"
  #   sku       = "win11-22h2-avd-m365"
  #   version   = "latest"
  # }

  # Enable disk encryption
 
  os_disk {
    name                 = "AVD-${var.intune_environment}-${random_string.random[count.index].id}-${count.index + 1}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "2048"
    # disk_ios_read_write  = "7500"
    # disk_mbps_read_write = "250"
    # disk_encryption_set_id = var.en_set_id
  }

  
  # Customer-managed keys
  #key_vault_secret_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.KeyVault/vaults/<key-vault-name>/secrets/<secret-name>/"

  # Platform-managed keys
  # key_encryption_key {
  #   key_url = "/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Compute/keyVaults/<key-vault-name>/keys/<key-name>"
  # }

  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("${path.root}/modules/avd/${var.avd_vm_custom_data_file}")
  
# lifecycle {
#     prevent_destroy = false
#     ignore_changes = all
#   }
  
}

# resource "azurerm_managed_disk" "fslogix" {
#   name                 = "AVD-${var.intune_environment}-${random_string.random[count.index].id}-${count.index + 1}-datadisk"
#   count                = var.avd_vm_count
#   location             = var.location
#   resource_group_name  = var.resource_group_name
#   storage_account_type = "Premium_LRS"
#   create_option        = "Empty"
#   disk_size_gb         = "1024"
#   tier                 = "P50"
#   #disk_encryption_set_id = var.en_set_id
# }


# resource "azurerm_virtual_machine_data_disk_attachment" "fslogix" {
#   count = var.avd_vm_count
#   managed_disk_id    = azurerm_managed_disk.fslogix[count.index].id
#   virtual_machine_id = azurerm_windows_virtual_machine.vm[count.index].id
#   lun                ="10"
#   caching            = "ReadWrite"
# }



resource "azurerm_virtual_machine_extension" "joinsessionhost" {
  count                      = var.avd_vm_count
  name                       = "ext-joinsessionhost"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${var.hostpool_name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${var.managed_identity_name}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    #azurerm_private_endpoint.fslogix-pl,
    #azurerm_private_endpoint.persistavd-pl,
  ]

  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
}

resource "azurerm_virtual_machine_extension" "monitoragent" {
  count                      = var.avd_vm_count
  name                       = "ext-MicrosoftMonitoringAgent"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  
  settings                   = <<SETTINGS
    {
        "workspaceId": "${var.log_analytics_workspace_id}"
    }
  SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_primary_shared_key}"
    }
  PROTECTED_SETTINGS
  
  depends_on = [
    azurerm_virtual_machine_extension.joinsessionhost
  ]  
}

locals {
  run_command1 = "cp c:/azuredata/customdata.bin c:/azuredata/dscpak.ps1"
  #run_command2 = "c:/azuredata/dscpak.ps1 -fslogix_hostname ${var.fslogix_hostname} -fslogix_key ${data.azurerm_storage_account.fslogix.primary_access_key};"
  #run_command3 = "echo ${var.fslogix_hostname} > c:/lll.txt;"
  run          =  "${local.run_command1};"
}

resource "azurerm_virtual_machine_extension" "bootstrap" {
  count                      = var.avd_vm_count
  name                       = "ext-custom-FileBootstrap"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  protected_settings                   = <<SETTINGS
    {
        "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -NoProfile -NonInteractive -command \"${local.run}\""
    }
    SETTINGS
  
  timeouts {
    create = "60m"
  }

  depends_on = [
    
    azurerm_virtual_machine_extension.monitoragent
    
  ]
  
  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
}

resource "azurerm_virtual_machine_extension" "aad" {
  name                       = "ext-AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  count                      = var.avd_vm_count
  settings                   = <<-SETTINGS
    {
      "mdmId": "0000000a-0000-0000-c000-000000000000"
    }
    SETTINGS
  
  lifecycle {
    prevent_destroy = false
    ignore_changes = all
  }
  
  depends_on = [
    azurerm_virtual_machine_extension.bootstrap
  ]
}

# resource "azurerm_virtual_machine_extension" "sse" {
#   name                       = "ext-sse"
#   count                      = var.avd_vm_count
#   virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
#   publisher                  = "Microsoft.Azure.Security"
#   type                       = "AzureDiskEncryption"
#   type_handler_version       = 2.2
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#         "EncryptionOperation": "EnableEncryption",
#         "KeyVaultURL": "${var.keyvaulturl}",
#         "KeyVaultResourceId": "${var.keyvaultid}",                   
#         "KeyEncryptionKeyURL": "${var.keyid}",
#         "KekVaultResourceId": "${var.keyvaultid}",                  
#         "KeyEncryptionAlgorithm": "RSA-OAEP",
#         "VolumeType": "All"
#     }
# SETTINGS
 
# }

# data "azurerm_role_definition" "userlogin" {
#   name = "Virtual Machine User Login"
# }

# data "azuread_group" "adds_group" {
#   display_name     = var.aad_group_name
#   security_enabled = true
# }

# resource "azurerm_role_assignment" "userlogin" {
#   count = var.avd_vm_count
#   scope = azurerm_windows_virtual_machine.vm[count.index].id
#   role_definition_id = data.azurerm_role_definition.userlogin.id
#   principal_id = data.azuread_group.adds_group.id
# }
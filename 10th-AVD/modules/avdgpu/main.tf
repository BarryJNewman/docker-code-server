resource "azurerm_resource_group" "newrg" {
 name = "${var.prefix}-RG"
 location = var.location
}

# resource "azurerm_virtual_desktop_workspace" "workspace" {
#   name                = var.avd_workspace_display_name
#   resource_group_name = azurerm_resource_group.newrg.name
#   location            = azurerm_resource_group.newrg.location
# }

# resource "azurerm_virtual_desktop_host_pool" "hostpool" {
#   name                       = var.hostpool_name
#   resource_group_name        = azurerm_resource_group.newrg.name
#   location                   = azurerm_virtual_desktop_workspace.workspace.location
#   custom_rdp_properties      = "audiocapturemode:i:1;audiomode:i:0;targetisaadjoined:i:1;authentication level:i:0;encode redirected video capture:i:0;redirectclipboard:i:0;redirectprinters:i:0;usbdevicestoredirect:s:;redirectsmartcards:i:1;audiocapturemode:i:1;camerastoredirect:s:*;drivestoredirect:s:;screen mode id:i:1;smart sizing:i:1;dynamic resolution:i:1"
#   type                       = "Pooled"
#   maximum_sessions_allowed   = "15"
#   load_balancer_type         = "BreadthFirst"
#   start_vm_on_connect        = true
# }

resource "azurerm_virtual_desktop_application_group" "dag" {
  name                         = "${var.prefix}-dag"
  resource_group_name          = azurerm_resource_group.newrg.name
  location                     = azurerm_virtual_desktop_workspace.workspace.location
  type                         = "Desktop"
  default_desktop_display_name = var.avd_display_name
  host_pool_id                 = azurerm_virtual_desktop_host_pool.hostpool.id
  depends_on                   = [azurerm_virtual_desktop_host_pool.hostpool, azurerm_virtual_desktop_workspace.workspace]
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}


resource "azurerm_virtual_desktop_application_group" "ra" {
  name                = "${var.prefix}-ra"
  location            = azurerm_virtual_desktop_workspace.workspace.location
  resource_group_name = azurerm_resource_group.newrg.name

  type          = "RemoteApp"
  host_pool_id  = azurerm_virtual_desktop_host_pool.hostpool.id
  friendly_name = "RemoteApp"
  description   = "RemoteAppDescription"
  depends_on = [
    azurerm_virtual_desktop_application_group.dag,azurerm_virtual_desktop_workspace_application_group_association.ws-dag
  ]
}

resource "azurerm_virtual_desktop_application" "firefox" {
 name                         = "Firefox"
 application_group_id         = azurerm_virtual_desktop_application_group.ra.id
 friendly_name                = "FireFox"
 description                  = "FireFox based web browser"
 path                         = "C:\\Program Files\\Mozilla FireFox\\firefox.exe"
 command_line_argument_policy = "DoNotAllow"
 command_line_arguments       = "--incognito"
 show_in_portal               = false
 icon_path                    = "C:\\Program Files\\Mozilla FireFox\\firefox.exe"
 icon_index                   = 0
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-ra" {
  application_group_id = azurerm_virtual_desktop_application_group.ra.id
  workspace_id         = azurerm_virtual_desktop_workspace.workspace.id
}

resource "time_rotating" "avd_registration_expiration" {
  # Must be between 1 hour and 30 days.
  rotation_days = 30
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "token" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = time_rotating.avd_registration_expiration.rotation_rfc3339
}

resource "azurerm_monitor_diagnostic_setting" "avd-logs" {
    name = "${var.prefix}-diag-prod-army-avd-hp"
    target_resource_id = azurerm_virtual_desktop_host_pool.hostpool.id
    log_analytics_workspace_id = var.log_analytics_workspace_id
    depends_on = [azurerm_virtual_desktop_host_pool.hostpool]
   log {
    category = "Error"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Checkpoint"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Management"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Connection"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "HostRegistration"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "AgentHealthStatus"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "NetworkData"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "SessionHostManagement"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "application_group-logs" {
  name = "${var.prefix}-diag-prod-army-avd-ag"
  target_resource_id = azurerm_virtual_desktop_application_group.dag.id
  log_analytics_workspace_id = var.log_analytics_workspace_id 
  depends_on = [
    azurerm_virtual_desktop_application_group.dag
  ]
  log {
    category = "Checkpoint"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Error"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Management"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "avd_workspace-logs" {
  name = "${var.prefix}-diag-prod-army-avd-ag"
  target_resource_id = azurerm_virtual_desktop_application_group.dag.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  depends_on = [
    azurerm_virtual_desktop_workspace.workspace
  ]
  log {
    category = "Checkpoint"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Error"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Management"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_availability_set" "avd" {
  name                         = "${var.prefix}-availability-set"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.newrg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
}

data azurerm_virtual_network vnet {
  name = var.avd_vnet_name
  resource_group_name = var.avd_vnet_rg
}

resource "azurerm_subnet" "subnet" {
  name                 = var.avd_subnet_name
  resource_group_name  = var.avd_subnet_rg_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = var.avd_subnet_range
}

data azurerm_route_table rt {
  name = var.avd_route_table_name
  resource_group_name = var.avd_route_table_rg
}

resource "azurerm_subnet_route_table_association" "session_hosts" {
  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = data.azurerm_route_table.rt.id
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-vm-${count.index + 1}-nic-${count.index + 1}"
  resource_group_name = azurerm_resource_group.newrg.name
  location            = var.location
  count               = var.avd_vm_count

  ip_configuration {
    name                          = "webipconfig${count.index}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_string" "random" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_windows_virtual_machine" "vm" {
  depends_on = [
    azurerm_network_interface.nic
  ]
  name                       = "${var.prefix}-VM-${count.index + 1}"
  computer_name              = "AVD-${random_string.random.id}${count.index + 1}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.newrg.name
  size                       = var.avd_vm_size
  network_interface_ids      = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  count                      = var.avd_vm_count
  #vtpm_enabled               = true
  #secure_boot_enabled        = true
  admin_username             = "localadmin"
  admin_password             = var.VMPassword
  enable_automatic_updates   = true
  provision_vm_agent         = true
  encryption_at_host_enabled = true
  availability_set_id        = azurerm_availability_set.avd.id

  source_image_reference {
    publisher = "microsoftwindowsdesktop"
    offer     = "office-365"
    sku       = "win11-22h2-avd-m365"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.prefix}-vm-${count.index + 1}-disk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = "512"
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = filebase64("${path.root}/modules/avd/${var.avd_vm_custom_data_file}")
}

locals {
  registration_token = azurerm_virtual_desktop_host_pool_registration_info.token.token
  shutdown_command     = "shutdown -r -t 10"
  exit_code_hack       = "exit 0"
  commandtorun         = "New-Item -Path HKLM:/SOFTWARE/Microsoft/RDInfraAgent/AADJPrivate"
  powershell_command   = "${local.commandtorun}; ${local.shutdown_command}; ${local.exit_code_hack}"
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
}

resource "azurerm_virtual_machine_extension" "monitoring" {
  count                      = var.avd_vm_count
  name                       = "ext-MicrosoftMonitoringAgent"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "workspaceId": "${var.log_analytics_workspace_workspace_id}"
    }
  SETTINGS
  protected_settings         = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${var.log_analytics_workspace_primary_shared_key}"
    }
  PROTECTED_SETTINGS  
}

resource "azurerm_virtual_machine_extension" "da" {
  count                      = var.avd_vm_count
  name                       = "ext-DependencyAgentWindows"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "azuremonitor" {
  count                      = var.avd_vm_count
  name                       = "ext-AzureMonitor"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorWindowsAgent"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "guestconfiguration" {
  count                      = var.avd_vm_count
  name                       = "ext-GuestConfiguration"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.GuestConfiguration"
  type                       = "ConfigurationforWindows"
  type_handler_version       = "1.29"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
}

resource "azurerm_virtual_machine_extension" "networkwatcher" {
  count                      = var.avd_vm_count
  name                       = "ext-NetworkWatcher"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = false
}

resource "azurerm_virtual_machine_extension" "wvdhost_amdgpu" {
  count                = var.avd_vm_count
  virtual_machine_id   = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  name                 = "AmdGpuDriverWindows"
  publisher            = "Microsoft.HpcCompute"
  type                 = "AmdGpuDriverWindows"
  type_handler_version = "1.1"
  # depends_on = [
  #   azurerm_virtual_machine_extension.networkWatcher
  # ]
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_virtual_machine_extension" "bootstrap" {
  depends_on = [
    azurerm_virtual_machine_extension.aad,
    #azurerm_virtual_machine_extension.monitoring,
    azurerm_virtual_machine_extension.da,
    azurerm_virtual_machine_extension.azuremonitor,
    azurerm_virtual_machine_extension.guestconfiguration,
    azurerm_virtual_machine_extension.networkwatcher
  ]
  count                      = var.avd_vm_count
  name                       = "custom-FileBootstrap"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -command \"cp c:/azuredata/customdata.bin c:/azuredata/dscpak.ps1; c:/azuredata/dscpak.ps1; shutdown -r -t 10; exit 0;\""
    }
    SETTINGS
}

resource "azurerm_virtual_machine_extension" "addsessionhost" {
  depends_on = [
    #azurerm_virtual_machine_extension.bootstrap
  ]
  name                       = "ext-AddSessionHost"
  virtual_machine_id         = element(azurerm_windows_virtual_machine.vm.*.id, count.index)
  publisher                  = "Microsoft.Powershell"
  count                      = var.avd_vm_count
  type                       = "DSC"
  type_handler_version       = "2.9"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
        "ModulesUrl": "https://raw.githubusercontent.com/Azure/RDS-Templates/master/ARM-wvd-templates/DSC/Configuration.zip",
        "ConfigurationFunction" : "Configuration.ps1\\AddSessionHost",
        "Properties": {
            "hostPoolName": "${azurerm_virtual_desktop_host_pool.hostpool.name}",
            "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.token.token}",
            "aadJoin": true
        }
    }
SETTINGS
lifecycle {
    prevent_destroy = false
    ignore_changes = [ settings ]
  }  
}

data "azurerm_role_definition" "role" { 
  name = "Desktop Virtualization User"
}

data "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
}

resource "azurerm_role_assignment" "role" {
  scope              = azurerm_virtual_desktop_application_group.dag.id
  role_definition_id = data.azurerm_role_definition.role.id
  principal_id       = data.azuread_group.aad_group.id
}
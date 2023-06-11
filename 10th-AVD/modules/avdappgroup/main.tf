data "azurerm_role_definition" "role" { 
  name = "Desktop Virtualization User"
}

# data "azurerm_role_definition" "vm_aad" {
#   name = "Virtual Machine User Login"
# }

data "azuread_group" "aad_group" {
  display_name     = var.aad_group_name
}

# resource "azurerm_role_assignment" "vm_aad" {
#   scope              = azurerm_resource_group.shrg.id
#   role_definition_id = data.azurerm_role_definition.vm_useraad.id
#   principal_id       = data.azuread_group.adds_group.id
# }

resource "azurerm_virtual_desktop_application_group" "dag" {
  name                         = "${var.prefix}-dag"
  resource_group_name          = var.resource_group_name
  location                     = var.avd_workspace_location
  type                         = "Desktop"
  default_desktop_display_name = var.avd_display_name
  host_pool_id                 = var.hostpool_id
  #depends_on                   = [azurerm_virtual_desktop_host_pool.hostpool]
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-dag" {
  application_group_id = azurerm_virtual_desktop_application_group.dag.id
  workspace_id         = var.avd_workspace_id
}


# resource "azurerm_virtual_desktop_application_group" "ra" {
#   name                = "${var.prefix}-ra"
#   location            = var.avd_workspace_location
#   resource_group_name = var.resource_group_name

#   type          = "RemoteApp"
#   host_pool_id  = var.hostpool_id
#   friendly_name = "RemoteApp"
#   description   = "RemoteAppDescription"
#   depends_on = [
#     azurerm_virtual_desktop_application_group.dag,azurerm_virtual_desktop_workspace_application_group_association.ws-dag
#   ]
# }

# resource "azurerm_virtual_desktop_application" "firefox" {
#  name                         = "Firefox"
#  application_group_id         = azurerm_virtual_desktop_application_group.ra.id
#  friendly_name                = "FireFox"
#  description                  = "FireFox based web browser"
#  path                         = "C:\\Program Files\\Mozilla FireFox\\firefox.exe"
#  command_line_argument_policy = "DoNotAllow"
#  command_line_arguments       = "--incognito"
#  show_in_portal               = false
#  icon_path                    = "C:\\Program Files\\Mozilla FireFox\\firefox.exe"
#  icon_index                   = 0
# }

# resource "azurerm_virtual_desktop_workspace_application_group_association" "ws-ra" {
#   application_group_id = azurerm_virtual_desktop_application_group.ra.id
#   workspace_id         = var.avd_workspace_id
# }

resource "time_rotating" "avd_registration_expiration" {
  # Must be between 1 hour and 30 days.
  rotation_days = 30
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "token" {
  hostpool_id     = var.hostpool_id
  expiration_date = time_rotating.avd_registration_expiration.rotation_rfc3339
}

# resource "azurerm_role_assignment" "role_dag" {
#   scope              = azurerm_virtual_desktop_application_group.dag.id
#   role_definition_id = data.azurerm_role_definition.role.id
#   principal_id       = data.azuread_group.aad_group.id
# }

resource "azurerm_monitor_diagnostic_setting" "avd_workspace-logs" {
  name = "${var.prefix}-diag-prod-army-avd-dagroup"
  target_resource_id = azurerm_virtual_desktop_application_group.dag.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

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
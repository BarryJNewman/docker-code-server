resource "azurerm_virtual_desktop_workspace" "workspace" {
  name                = var.workspace_display_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_monitor_diagnostic_setting" "avd_workspace-logs" {
  name = "${var.prefix}-diag-prod-army-avd-workspace"
  target_resource_id = azurerm_virtual_desktop_workspace.workspace.id
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
  log {
    category = "Feed"
    enabled = "true"

    retention_policy {
      enabled = false
    }
  }
}
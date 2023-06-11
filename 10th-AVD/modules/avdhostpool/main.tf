resource "azurerm_virtual_desktop_host_pool" "hostpool" {
  name                       = var.hostpool_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  custom_rdp_properties      = "targetisaadjoined:i:1;authentication level:i:0;enablerdsaadauth:i:1;audiocapturemode:i:1;audiomode:i:0;encode redirected video capture:i:1;redirectclipboard:i:0;redirectprinters:i:0;usbdevicestoredirect:s:;redirectsmartcards:i:1;camerastoredirect:s:*;drivestoredirect:s:;screen mode id:i:1;smart sizing:i:1;dynamic resolution:i:1;bandwidthautodetect:i:1;networkautodetect:i:1;compression:i:1;videoplaybackmode:i:1;redirectlocation:i:1;redirectwebauthn:i:1;autoreconnection enabled:i:1;redirectcomports:i:0;keyboardhook:i:1;devicestoredirect:s:"
  type                       = "Pooled"
  start_vm_on_connect        = true
  maximum_sessions_allowed   = 20
  load_balancer_type         = var.load_balancer_type
  scheduled_agent_updates {
    enabled = true
    schedule {
      day_of_week = "Saturday"
      hour_of_day = 2
    }
  }
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "token" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.hostpool.id
  expiration_date = var.avd_reg
}

resource "azurerm_monitor_diagnostic_setting" "avd-logs" {
    name = "${var.hostpool_name}diag-prod-avd.hp"
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

# resource "azurerm_virtual_desktop_scaling_plan" "armyavd" {
#   name                = var.scaling_plan_name
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   friendly_name       = "ArmyAVD Scaling Plan"
#   description         = "ArmyAVD Scaling Plan"
#   time_zone           = "Eastern Standard Time"
#   schedule {
#     name                                 = "Weekdays"
#     days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
#     ramp_up_start_time                   = "07:00"
#     ramp_up_load_balancing_algorithm     = "BreadthFirst"
#     ramp_up_minimum_hosts_percent        = 20
#     ramp_up_capacity_threshold_percent   = 10
#     peak_start_time                      = "08:00"
#     peak_load_balancing_algorithm        = "BreadthFirst"
#     ramp_down_start_time                 = "17:00"
#     ramp_down_load_balancing_algorithm   = "DepthFirst"
#     ramp_down_minimum_hosts_percent      = 10
#     ramp_down_force_logoff_users         = true
#     ramp_down_wait_time_minutes          = 45
#     ramp_down_notification_message       = "Please log off in the next 45 minutes..."
#     ramp_down_capacity_threshold_percent = 5
#     ramp_down_stop_hosts_when            = "ZeroSessions"
#     off_peak_start_time                  = "20:00"
#     off_peak_load_balancing_algorithm    = "DepthFirst"
#   }
#   host_pool {
#     hostpool_id          = azurerm_virtual_desktop_host_pool.hostpool.id
#     scaling_plan_enabled = false
#   }
#   depends_on = [azurerm_virtual_desktop_host_pool.hostpool]
# }
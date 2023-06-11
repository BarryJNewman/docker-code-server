resource "azurerm_private_dns_zone" "dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_vnet_associate" {
  name                  = "${var.environment}-private-dns-zone-vnet-associate"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_monitor_diagnostic_setting" "kv-diag" {
  name               = "diag-keyvault-${var.prefix}"
  target_resource_id = azurerm_key_vault.kv.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  
  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "AzurePolicyEvaluationDetails"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}

output "id" {
  value = azurerm_private_dns_zone.dns_zone.id
}

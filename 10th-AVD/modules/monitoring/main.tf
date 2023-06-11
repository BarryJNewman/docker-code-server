# resource azurerm_resource_group newrg {
#  name = "${var.prefix}-Monitoring-RG"
#  location = var.location
# }

# resource "azurerm_log_analytics_workspace" "law" {
#   name                       = "${var.prefix}-law"
#   location                   = var.location
#   resource_group_name        = azurerm_resource_group.newrg.name
#   sku                        = "PerGB2018"
#   retention_in_days          = "30"
#   internet_ingestion_enabled = true
#   internet_query_enabled     = true
# }

# resource "azurerm_log_analytics_solution" "vminsights" {
#   solution_name         = "VMInsights"
#   location              = var.location
#   resource_group_name   = azurerm_resource_group.newrg.name
#   workspace_resource_id = azurerm_log_analytics_workspace.law.id
#   workspace_name        = azurerm_log_analytics_workspace.law.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/VMInsights"
#   }
# }

# resource "azurerm_log_analytics_solution" "changetracking" {
#   solution_name         = "ChangeTracking"
#   location              = var.location
#   resource_group_name   = azurerm_resource_group.newrg.name
#   workspace_resource_id = azurerm_log_analytics_workspace.law.id
#   workspace_name        = azurerm_log_analytics_workspace.law.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ChangeTracking"
#   }
# }

# resource "azurerm_log_analytics_solution" "updates" {
#   solution_name         = "Updates"
#   location              = var.location
#   resource_group_name   = azurerm_resource_group.newrg.name
#   workspace_resource_id = azurerm_log_analytics_workspace.law.id
#   workspace_name        = azurerm_log_analytics_workspace.law.name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/Updates"
#   }
# }

# resource "azurerm_automation_account" "automation" {
#   name                = "${var.prefix}-automation-account"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.newrg.name
#   sku_name            = "Basic"
# }

# resource "azurerm_log_analytics_linked_service" "link" {
#   resource_group_name = azurerm_resource_group.newrg.name
#   workspace_id        = azurerm_log_analytics_workspace.law.id
#   read_access_id      = azurerm_automation_account.automation.id
# }
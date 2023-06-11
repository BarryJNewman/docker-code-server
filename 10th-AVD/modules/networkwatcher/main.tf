# Configure the providers.
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.22"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.2"
    }
  }
}

resource "random_string" "random" {
  length  = 5
  upper   = false
  special = false
}

provider "azurerm" {
  #skip_provider_registration = true
  #use_oidc                   = true
  environment                 = "usgovernment"
  features {
    key_vault {
      purge_soft_delete_on_destroy                            = false
      purge_soft_deleted_hardware_security_modules_on_destroy = false
      purge_soft_deleted_certificates_on_destroy              = false
      purge_soft_deleted_keys_on_destroy                      = false
      purge_soft_deleted_secrets_on_destroy                   = false
      recover_soft_deleted_key_vaults                         = true
      recover_soft_deleted_certificates                       = false
      recover_soft_deleted_keys                               = false
      recover_soft_deleted_secrets                            = false
    }
  }
}

provider "azuread" {
  environment = "usgovernment"
}

data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "loganetworkmon" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
}

data "azurerm_virtual_network" "loganetworkmon" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "this" {
  count               = length(data.azurerm_virtual_network.this.subnets)
  name                = data.azurerm_virtual_network.this.subnets[count.index].name
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name = data.azurerm_virtual_network.this.resource_group_name
}

resource "azurerm_network_watcher_flow_log" "this" {
  count               = length(data.azurerm_virtual_network.this.subnets)
  network_watcher_id  = azurerm_network_watcher.this.id
  resource_group_name = data.azurerm_virtual_network.this.resource_group_name

  traffic_analytics {
    workspace_id       = azurerm_log_analytics_workspace.this.workspace_id
    workspace_region   = azurerm_log_analytics_workspace.this.location
    workspace_resource_id = azurerm_log_analytics_workspace.this.id
    enabled            = true
  }

  target_resource_id          = data.azurerm_subnet.this[count.index].id
  network_security_group_id   = data.azurerm_subnet.this[count.index].network_security_group_id

  retention_policy {
    enabled = true
    days    = 7
  }
}
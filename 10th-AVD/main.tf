# Configure the providers.
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.22"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "<= 3.52.0"
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

# locals {
#   name-prefix = "${var.project_name}-${var.environment}"
# }

provider "azurerm" {
  #skip_provider_registration = true
  #use_oidc                   = true
  #subscription_id = "ddd12f73-81ae-4773-a580-4c8dd1453e55"
  #tenant_id       = "fae6d70f-954b-4811-92b6-0530d6f84c43"
  #client_id       = "0bb041b6-4a39-49a1-99e6-22683408cc6a"
  #client_secret   = "n4h05UJNV940vDmHNa_Kh~-xLT1~t~KSZd"
  environment     = "usgovernment"
  
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
  #tenant_id       = "fae6d70f-954b-4811-92b6-0530d6f84c43"
  #client_id       = "0bb041b6-4a39-49a1-99e6-22683408cc6a"
  #client_secret   = "n4h05UJNV940vDmHNa_Kh~-xLT1~t~KSZd"
  environment     = "usgovernment"
}

data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_rg
}

data "azurerm_virtual_network" "vnet" {
  name = var.avd_vnet_name
  resource_group_name = var.avd_vnet_rg
}

data "azurerm_key_vault" "myKV" {
  name                = var.keyvault_name
  resource_group_name = var.keyvault_resource_group
}

#Pull the VM local admin password from the Key Vault for use in the build
data "azurerm_key_vault_secret" "vmPW" {
  key_vault_id = data.azurerm_key_vault.myKV.id
  name         = "VMPassword"
}

# module "log_analytics_network_monitoring" {
#   source = "./modules/log_analytics_network_monitoring"

#   resource_group_name  = module.rg-avd.name
#   location             = var.location
#   virtual_network_name = "your_virtual_network_name"
#   workspace_name       = "your_log_analytics_workspace_name"
# }

module "rg-avd" {
  source              = "./modules/resourcegroup"
  count = var.shard_count 
  resource_group_name = "${var.environment}-${var.user_lut_num}-${count.index + 1}-RG"
  location            = var.location
}

# module "keyvaultdes" {
#   source              = "./modules/keyvaultdes"
#   count               = var.shard_count
#   key_name            = "AVD-${var.user_lut_num}-${count.index + 1}-DES-KEY"
#   en_set_name         = "AVD-${var.user_lut_num}-${count.index + 1}-DES-EN-SET"
#   key_vault_name      = "AVD-${var.user_lut_num}-${count.index + 1}-DES-KV"
#   resource_group_name = element(module.rg-avd.*.name,count.index)
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
#   location            = var.location
# }

module "kvsse" {
  source              = "./modules/kvsse"
  count               = var.shard_count
  #key_name            = "AVD-${var.user_lut_num}-${count.index + 1}-DES-KEY"
  #en_set_name         = "AVD-${var.user_lut_num}-${count.index + 1}-DES-EN-SET"
  #key_vault_name      = "AVD-${var.user_lut_num}-${count.index + 1}-DES-KV"
  #resource_group_name = element(module.rg-avd.*.name,count.index)
  #log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  #msi_id = "a7daef2a-faba-4d23-94f4-c8359df9d6d5"
  location            = var.location
}

# module "azuredns" {
#   source              = "./modules/azuredns"
#   #name                  = "${var.environment}-private-dns-zone-vnet-associate"
#   resource_group_name   = element(module.rg-avd.*.name,0)
#   virtual_network_id    = data.azurerm_virtual_network.vnet.id
#   private_dns_zone_name = var.private_dns_zone_name
#   environment = var.environment
#   #fslogix_ip = cidrhost("${var.avd_subnet_range["${count.index}"]}", count.index + 5)
#   #shard_count = var.shard_count
#   #log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
# }

resource "time_rotating" "avd_registration_expiration" {
  # Must be between 1 hour and 30 days.
  rotation_days = 30
}

module workspace {
  source = "./modules/avdworkspace"
  count = var.shard_count
  location  = var.location
  prefix = "AVD-ENG${count.index + 1}"
  resource_group_name = element(module.rg-avd.*.name,count.index)
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_display_name = var.workspace_display_name
}

module "hostpool_ga" {
  source = "./modules/avdhostpool"
  count = var.shard_count
  hostpool_name = "${var.environment}-${var.user_lut_num}-${count.index + 1}-HP-GA"
  scaling_plan_name = "${var.environment}-${var.user_lut_num}-${count.index + 1}-SP"
  resource_group_name = element(module.rg-avd.*.name,count.index)
  location = var.location
  avd_reg = resource.time_rotating.avd_registration_expiration.rotation_rfc3339
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  load_balancer_type = var.load_balancer_type
  keyvault_name = var.keyvault_name
  
}

module "session_hosts" {
    source = "./modules/avd"
    count = var.shard_count
    intune_environment = var.intune_environment
    #private_dns_zone_ids = module.azuredns.id
    private_dns_zone_name = var.private_dns_zone_name
    private_dns_resource_group = element(module.rg-avd.*.name,0)
    location = var.location
    fslogix_ip = cidrhost("${var.avd_subnet_range["${count.index}"]}", count.index + 5)
    fslogix_scale_ip = cidrhost("${var.avd_subnet_range["${count.index}"]}", count.index + 6)
    #
    # des_key_vault_name = "AVD-${var.user_lut_num}-${count.index + 1}-DES-KV"
    # des_key_vault_resource_group_name = element(module.rg-avd.*.name,count.index)
    
    ###
    # en_set_id = element(module.kvsse.*.en_set_id,count.index)
    # keyid = element(module.kvsse.*.keyid,count.index)
    # keyvaulturl = element(module.kvsse.*.keyvaulturl,count.index)
    # keyvaultid = element(module.kvsse.*.keyvaultid,count.index)
    # keyvault_ip = cidrhost("${var.avd_subnet_range["${count.index}"]}", count.index + 7)
    # ###
    persistavd_ip = cidrhost("${var.avd_subnet_range["${count.index}"]}", count.index + 8)
    persistavd_storage_account_name = var.persistavd_storage_account_name
    persistavd_dns = "${var.persistavd_storage_account_name}${count.index + 1}"
    fslogix_storage_account_name = "${var.fslogix_storage_account_name}${count.index + 1}"
    fslogix_hostname = "${var.fslogix_hostname}${count.index + 1}"
    fslogix_storage_account_rg = var.fslogix_storage_account_rg
    prefix = "${var.environment}-${var.user_lut_num}-${count.index + 1}"
    resource_group_name = element(module.rg-avd.*.name,count.index)
    avd_vm_custom_data_file = "dscpak.ps1"
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.workspace_id
    log_analytics_workspace_name = data.azurerm_log_analytics_workspace.log_analytics_workspace.name
    log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key
    hostpool_name = "${var.environment}-${var.user_lut_num}-${count.index + 1}-HP-GA"
    avd_vm_count = var.avd_vm_count
    avd_vm_size = "Standard_D16as_v5"
    avd_display_name = var.avd_display_name
    avd_workspace_display_name = var.avd_display_name
    aad_group_name = var.aad_group_name
    VMPassword = data.azurerm_key_vault_secret.vmPW.value
    avd_vnet_name = var.avd_vnet_name
    avd_subnet_rg_name = var.avd_subnet_rg_name
    avd_vnet_rg = var.avd_vnet_rg
    avd_address_prefixes = ["${var.avd_subnet_range["${count.index}"]}"]
    avd_subnet_name = "${var.avd_subnet_name}-${count.index}"
    avd_route_table_name = var.avd_route_table_name
    managed_identity_name = module.hostpool_ga["${count.index}"].managed_identity_name
    avd_route_table_rg = var.avd_route_table_rg
    azure_managed_image_name = var.azure_managed_image_name
    azure_shared_image_gallery_name = var.azure_shared_image_gallery_name
    azure_sig_resource_group_name = var.azure_sig_resource_group_name
    depends_on = [
      module.hostpool_ga,
      module.workspace,
      #module.keyvaultdes,
      #module.azuredns
      #azurerm_key_vault.main
    ]
}

# module "application_groups" {
#   source = "./modules/avdappgroup"
#   count = var.shard_count
#   prefix = "${var.environment}-${var.user_lut_num}-${count.index + 1}"
#   resource_group_name = element(module.rg-avd.*.name,count.index)
#   location = var.location
#   hostpool_name = "${var.environment}-${var.user_lut_num}-${count.index + 1}}-HP-GA"
#   hostpool_id = module.hostpool_ga["${count.index}"].hostpool_id
#   aad_group_name = var.aad_group_name
#   application_group_name = "${var.environment}-AG-${count.index + 1}"
#   avd_vnet_name = var.avd_vnet_name
#   avd_vnet_rg = var.avd_vnet_rg
#   avd_workspace_id = element(module.workspace.*.id,count.index)
#   log_analytics_workspace_name = data.azurerm_log_analytics_workspace.log_analytics_workspace.name
#   log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.log_analytics_workspace.primary_shared_key
#   #avd_subnet_range = ["10.49.10.0/24"]
#   managed_identity_name = module.hostpool_ga["${count.index}"].managed_identity_name
#   log_analytics_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
#   log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
#   avd_route_table_rg = var.avd_route_table_rg
#   avd_route_table_name = var.avd_route_table_name
#   avd_workspace_display_name = var.workspace_display_name
#   avd_display_name = "${var.avd_display_name}${count.index + 1}"
#   avd_workspace_location = var.location
#   depends_on = [
#     module.session_hosts,
#     module.rg-avd
#   ]
# }
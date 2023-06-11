variable "prefix" {
  type        = string
  default = ""
  description = "the prefix used in naming our resources"
}

variable "environment" {
  type        = string
  default = ""
  description = "the prefix used in naming our resources"
}

variable "shard_count" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "avd_vm_count" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "intune_environment" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "private_dns_zone_name" {
  type        = string
  description = ""
}


variable "user_lut_num" {
  type        = string
  default = ""
  description = ""
}

variable "location" {
  type        = string
  description = "Resource group location"
}

variable "keyvault_name" {
  type        = string
  default     = ""
  description = "the name of the keyvault"
}

variable "aad_group_name" {
  type        = string
  default     = ""
  description = ""
}

variable "keyvault_resource_group" {
  description = "Password for the Domain Join User account provided"
  type        = string
  default     = ""
}

variable "load_balancer_type" {
  description = ""
  type        = string
  default     = ""
}

variable "hostpool_name" {
  type        = string
  default     = ""
  description = ""
}

variable "avd_vnet_name" {
  type        = string
  description = ""
}

variable "avd_display_name" {
  type        = string
  description = ""
}

variable "avd_subnet_name" {
  type        = string
  default     = ""
  description = ""
}


variable "avd_subnet_rg_name" {
  type        = string
  description = ""
}

variable "avd_rg_name" {
  type        = string
  default     = ""
  description = ""
}

variable "avd_vnet_rg" {
  type        = string
  default     = ""
  description = ""
}

variable "avd_route_table_name" {
  type        = string
  default     = ""
  description = ""
}

variable "avd_route_table_rg" {
  type        = string
  default     = ""
  description = ""
}

variable avd_subnet_range {
  type        = list(string)
}

variable "azure_managed_image_name" {
  description = ""
}

variable "azure_shared_image_gallery_name" {
  description = ""
}

variable "workspace_display_name" {
  description = ""
}

variable "azure_sig_resource_group_name" {
  description = ""
}

variable "fslogix_storage_account_name" {
  description = ""
}

variable "fslogix_storage_account_rg" {
  description = ""
}

variable "fslogix_hostname" {
  type        = string
  description = ""
}

variable "fslogix_ip" {
  type        = string
  default     = ""
  description = ""
}

variable "persistavd_storage_account_name" {
  type        = string
  description = ""
}

variable "log_analytics_workspace_rg" {
  type        = string
  description = ""
}

variable "log_analytics_workspace_name" {
  type        = string
  description = ""
}
#variable "fslogix_key" {
#  type        = string
#  description = ""
#}

variable "prefix" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "hostpool_name" {
  type        = string
  description = ""
}

variable "hostpool_id" {
  type        = string
  description = ""
}

variable "location" {
  type        = string
  description = "the default/preferred location for our resources"
}

variable "aad_group_name" {
  description = ""
}


variable "avd_route_table_name" {
  description = "the name of the route table to associate with the hostpool subnet"
}

variable "managed_identity_name" {
  description = "managed id token"
}

variable "avd_display_name" {
  description = "the display name of the desktop presented to end users"
}

variable "avd_workspace_display_name" {
  description = "the display name of the workspace presented to end users"
}

variable "avd_workspace_id" {
  description = ""
}

variable "resource_group_name" {
  description = "the display name of the workspace presented to end users"
}

variable "container_name" {
  default     = "Army Container Name"
  description = "the display name of the workspace presented to end users"
}

variable "avd_subnet_name" {
  default     = "vGFE-Clients0001-Subnet"
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable "avd_subnet_rg_name" {
  default     = "CAZ-MANAGE-P-RGP-CrossTenant"
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable "avd_vnet_rg" {
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable "avd_vnet_name" {
  description = "the subnet name to deploy the AVD PaaS services to"
}

# variable avd_subnet_range {
#   type        = list(string)
# }

variable "avd_route_table_rg" {
  description = ""
}

variable "application_group_name" {
  type        = string
  description = "Azure Active Directory Group for AVD users"
}

variable "avd_workspace_location" {
  type        = string
  description = "the path to the custom data file to use for the virtual machines"
}

variable "log_analytics_id" {
  description = ""
}

variable "log_analytics_workspace_id" {
  description = ""
}

variable "log_analytics_workspace_name" {
  description = ""
}

variable "log_analytics_workspace_primary_shared_key" {
  description = ""
}
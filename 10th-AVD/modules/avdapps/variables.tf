variable "prefix" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "hostpool_name" {
  type        = string
  default     = ""
  description = ""
}

variable "location" {
  type        = string
  description = "the default/preferred location for our resources"
}


variable "avd_vm_count" {
  default     = "4"
  description = "the number of virtual machines to create"
}

variable "avd_vm_size" {
  default     = ""
  description = "the virutal machine size to leverage"
}

variable "avd_route_table_name" {
  description = "the name of the route table to associate with the hostpool subnet"
}

variable "avd_display_name" {
  description = "the display name of the desktop presented to end users"
}

variable "avd_workspace_display_name" {
  description = "the display name of the workspace presented to end users"
}

variable "avd_subnet_name" {
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable "avd_subnet_rg_name" {
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable "avd_vnet_rg" {
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable "avd_vnet_name" {
  description = "the subnet name to deploy the AVD PaaS services to"
}

variable avd_subnet_range {
  type        = list(string)
}

variable "avd_route_table_rg" {
  description = ""
}

variable "VMPassword" {
  description = ""
}

variable "aad_group_name" {
  type        = string
  default     = ""
  description = "Azure Active Directory Group for AVD users"
}

variable "avd_vm_custom_data_file" {
  type        = string
  default     = ""
  description = "the path to the custom data file to use for the virtual machines"
}


variable "log_analytics_workspace_id" {
  description = ""
}

variable "log_analytics_workspace_workspace_id" {
  description = ""
}

variable "log_analytics_workspace_name" {
  description = ""
}

variable "log_analytics_workspace_primary_shared_key" {
  description = ""
}
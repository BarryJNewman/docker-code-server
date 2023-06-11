variable "resource_group_name" {
  type        = string
  default = "CAZ-MANAGE-P-RGP-CrossTenant"
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  
  description = "The location where resources will be deployed"
}

variable "virtual_network_name" {
  type        = string
  default = "CAZ-MANAGE-P-RCWPAVD-VNET"
  description = "The name of the virtual network"
}

variable "workspace_name" {
  type        = string
  default = "CAZ-AVD-NETWORKING-LAW-P-IL5"
  description = "The name of the log analytics workspace"
}
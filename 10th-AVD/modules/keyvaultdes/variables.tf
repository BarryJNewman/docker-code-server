variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault"
}

variable "key_name" {
  type        = string
  description = "Name of the customer-managed key"
}

variable "en_set_name" {
  type        = string
  description = "Name of the customer-managed key"
}

variable "location" {
  type        = string
  description = "Azure region where the Key Vault will be created"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name where the Key Vault will be created"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = ""
}
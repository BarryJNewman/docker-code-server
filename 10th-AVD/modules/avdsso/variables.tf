variable "prefix" {
  type        = string
  default = ""
  description = "the prefix used in naming our resources"
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "the name of the keyvault"
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

variable "hostpool_name" {
  type        = string
  default     = ""
  description = ""
}


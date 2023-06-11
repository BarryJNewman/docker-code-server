variable "hostpool_name" {
  description = "Hostname Name to be created"
  type        = string
  default     = null
}

variable "prefix" {
  description = "Hostname Name to be created"
  type        = string
  default     = ""
}

variable "scaling_plan_name" {
  description = "Hostname Name to be created"
  type        = string
}

variable "avd_reg" {
  description = "Hostname Name to be created"
  type        = string
  default     = ""
}

variable "load_balancer_type" {
  description = ""
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "Hostname Name to be created"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Hostname Name to be created"
  type        = string
  default     = ""
}

variable "location" {
  description = "Hostname Name to be created"
  type        = string
  default = ""
}

variable "keyvault_name" {
  type        = string
  default     = ""
  description = "the name of the keyvault"
}

variable "tags" {
  description = "Tags to be used for this resource deployment."
  type        = map(any)
  default     = null
}
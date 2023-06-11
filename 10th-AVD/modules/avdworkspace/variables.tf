variable "prefix" {
  type        = string
  description = "the prefix used in naming our resources"
}
variable "location" {
  type        = string
  description = "the default/preferred location for our resources"
}

variable "workspace_display_name" {
  default     = ""
  description = "the number of virtual machines to create"
}

variable "resource_group_name" {
  default     = ""
  description = "the virutal machine size to leverage"
}

variable "log_analytics_workspace_id" {
  description = ""
}
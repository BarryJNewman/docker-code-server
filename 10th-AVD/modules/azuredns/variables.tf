variable "environment" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "resource_group_name" {
  description = ""
}

variable "private_dns_zone_name" {
  type        = string
  description = ""
}

variable "virtual_network_id" {
  type        = string
  description = ""
}

variable "location" {
  description = "Prefix of the hostnames used for servernames"
  type        = string
}

variable "storage_account_name" {
  description = "Resource Group where VMs will be placed"
  type        = string
}

variable "storage_resource_group" {
  description = "Resource Group where VMs will be placed"
  type        = string
}
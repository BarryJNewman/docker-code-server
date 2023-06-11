variable "dsc_storage_account_rg" {
  description = "Resource Group Name to be created"
  type = string
}

variable "location" {
  description = "Location of resource group"
  type = string
}

variable "domain_password" {
  description = "Password for the Domain Join User account provided"
  type        = string
  sensitive   = true
}

variable "domain_username" {
  description = "Domain user that will be used to join this computer to the domain"
  type        = string
}

variable "dsc_storage_account_name" {
  description = "Storage Account Name for DSC definitions"
  type = string
}

variable "dscpak_name" {
  description = "Storage Account Name for DSC definitions"
  type = string
}

variable "virtual_machine_id" {
  description = "Storage Account Name for DSC definitions"
  type = string
}

# variable "hostname_id" {
#   description = "Identifier for the VM name that goes after the prefix to signify workload"
#   type        = string
# }

variable "runDSC" {
  description = "Custom DSC Script from BLOB"
  type        = bool
}
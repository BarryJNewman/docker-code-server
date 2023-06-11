variable "prefix" {
  type        = string
  description = "the prefix used in naming our resources"
}

variable "hostpool_name" {
  type        = string
  description = ""
}

variable "location" {
  type        = string
  description = "the default/preferred location for our resources"
}

variable "intune_environment" {
  type        = string
  description = ""
}

# variable "private_dns_zone_ids" {
#   type        = string
#   description = ""
# }

variable "private_dns_zone_name" {
  type        = string
  description = ""
}

variable "persistavd_dns" {
  type        = string
  description = ""
}

variable "private_dns_resource_group" {
  type        = string
  description = ""
}

variable "avd_vm_count" {
  description = "the number of virtual machines to create"
}

variable "avd_vm_size" {
  description = "the virutal machine size to leverage"
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

variable "resource_group_name" {
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

variable avd_address_prefixes {
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
  description = "Azure Active Directory Group for AVD users"
}

variable "avd_vm_custom_data_file" {
  type        = string
  description = "the path to the custom data file to use for the virtual machines"
}


# variable "log_analytics_id" {
#   description = ""
# }

variable "fslogix_hostname" {
  type        = string
  description = ""
}

variable "fslogix_scale_ip" {
  type        = string
  description = ""
}

variable "fslogix_ip" {
  type        = string
  description = ""
}

# variable "keyvault_ip" {
#   type        = string
#   description = ""
# }

# variable "keyvaulturl" {
#   type        = string
#   description = ""
# }

# variable "keyid" {
#   type        = string
#   description = ""
# }

# variable "keyvaultid" {
#   type        = string
#   description = ""
# }

# variable "en_set_id" {
#   type        = string
#   description = ""
# }


# variable "des_key_vault_resource_group_name" {
#   type        = string
#   description = ""
# }


variable "persistavd_ip" {
  type        = string
  description = ""
}

variable "persistavd_storage_account_name" {
  type        = string
  description = ""
}

#variable "fslogix_key" {
#  type        = string
#  description = ""
#}


variable "log_analytics_workspace_id" {
  description = ""
}

variable "log_analytics_workspace_name" {
  description = ""
}

variable "log_analytics_workspace_primary_shared_key" {
  description = ""
}

variable "azure_managed_image_name" {
  description = ""
}

variable "azure_shared_image_gallery_name" {
  description = ""
}

variable "azure_sig_resource_group_name" {
  description = ""
}

variable "fslogix_storage_account_name" {
  description = ""
}

variable "fslogix_storage_account_rg" {
  description = ""
}

variable "location" {

}

variable "rg_name" {
  
}

data "azurerm_automation_account" "dsc" {
  name                = "avdautomation"
  resource_group_name = var.rg_name
  
}

resource "azurerm_automation_module" "storage" {
  name                    = "AccessControlDSC"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/AccessControlDSC/1.4.1"
  }
}

resource "azurerm_automation_module" "AuditPolicyDsc" {
  name                    = "AuditPolicyDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/AuditPolicyDsc/1.4.0.0"
  }
}

resource "azurerm_automation_module" "xStorage" {
  name                    = "xStorage"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xstorage.3.4.0.nupkg"
  }
}

resource "azurerm_automation_module" "AuditSystemDsc" {
  name                    = "AuditSystemDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/AuditSystemDsc/1.1.0"
  }
}

resource "azurerm_automation_module" "CertificateDsc" {
  name                    = "CertificateDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/CertificateDsc/5.0.0"
  }
}

resource "azurerm_automation_module" "ComputerManagementDsc" {
  name                    = "ComputerManagementDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/ComputerManagementDsc/8.4.0"
  }
}

resource "azurerm_automation_module" "FileContentDsc" {
  name                    = "FileContentDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/FileContentDsc/1.3.0.151"
  }
}

resource "azurerm_automation_module" "GPRegistryPolicyDsc" {
  name                    = "GPRegistryPolicyDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/GPRegistryPolicyDsc/1.2.0"
  }
}

resource "azurerm_automation_module" "nx" {
  name                    = "nx"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/nx/1.0"
  }
}
resource "azurerm_automation_module" "PSDscResources" {
  name                    = "PSDscResources"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/PSDscResources/2.12.0.0"
  }
}
resource "azurerm_automation_module" "SecurityPolicyDsc" {
  name                    = "SecurityPolicyDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/SecurityPolicyDsc/2.10.0.0"
  }
}
resource "azurerm_automation_module" "SqlServerDsc" {
  name                    = "SqlServerDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/SqlServerDsc/13.3.0"
  }
}
resource "azurerm_automation_module" "WindowsDefenderDsc" {
  name                    = "WindowsDefenderDsc"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/WindowsDefenderDsc/2.1.0"
  }
}
resource "azurerm_automation_module" "xDnsServer" {
  name                    = "xDnsServer"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/xDnsServer/1.16.0.0"
  }
}
resource "azurerm_automation_module" "xWebAdministration" {
  name                    = "xWebAdministration"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/xWebAdministration/3.2.0"
  }
}
resource "azurerm_automation_module" "PowerSTIG" {
  name                    = "PowerSTIG"
  resource_group_name     = var.rg_name
  automation_account_name = data.azurerm_automation_account.dsc.name

  module_link {
    uri = "https://www.powershellgallery.com/api/v2/package/PowerSTIG/4.10.1"
  }
}
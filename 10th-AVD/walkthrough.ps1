az cloud set --name AzureUSGovernment

az cloud list --output table

#upload pfx file to keyvault
$keyvaultname = "CAZ-VMKV-P-DKV-10th-VM"
$certpath = "./deps/armyadfssso.pfx"
$certname = "avdadfs"
az keyvault certificate import --vault-name $keyvaultname --name $certname --file $certpath --password "1qaz!QAZ2wsx@WSX"

Location=usgovvirginia
Publisher=MicrosoftWindowsDesktop
Offer="office-365"
Sku="22h1-pro"

az vm image list --all -l $Location -p $Publisher -f $Offer -s $Sku --output table


resource "null_resource" "FSLogix" {
    count = var.NumberOfSessionHosts
    provisioner "local-exec" {
      command = "az vm run-command invoke --command-id RunPowerShellScript --name ${element(azurerm_windows_virtual_machine.main.*.name, count.index)} -g ${azurerm_resource_group.resourcegroup.name} --scripts 'New-ItemProperty -Path HKLM:\\SOFTWARE\\FSLogix\\Profiles -Name VHDLocations -Value \\\\cloudninjafsl11072022.file.core.windows.net\\avdprofiles -PropertyType MultiString;New-ItemProperty -Path HKLM:\\SOFTWARE\\FSLogix\\Profiles -Name Enabled -Value 1 -PropertyType DWORD;New-ItemProperty -Path HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Lsa\\Kerberos\\Parameters -Name CloudKerberosTicketRetrievalEnabled -Value 1 -PropertyType DWORD;New-Item -Path HKLM:\\Software\\Policies\\Microsoft\\ -Name AzureADAccount;New-ItemProperty -Path HKLM:\\Software\\Policies\\Microsoft\\AzureADAccount  -Name LoadCredKeyFromProfile -Value 1 -PropertyType DWORD;Restart-Computer'"
      interpreter = ["PowerShell", "-Command"]
    }
    depends_on = [
         azurerm_virtual_machine_extension.AADLoginForWindows
      ]
  }

### create vnet
$rgname = "CAZ-MANAGE-P-RGP-CrossTenant"
$Location = "usgovvirginia"
$vnetname = "CAZ-MANAGE-P-RCWPAVD-EAST-VNET"
$subnetname = "AVD-subnet"
$subnetprefix = ""

  
# create azure resource group
az group create --name $rgname --location $location

# create azure vnet
az network vnet create --resource-group $rgname --name $vnetname --address-prefixes "10.49.0.0/16"

# create subnet
#az network vnet subnet create --resource-group $rgname --vnet-name $vnetname --name $subnetname --address-prefixes

# create azure route table
$routetablename = "CAZ-AVDFW-RCWPAVDA365-EAST-P-RT"
$rgname = "CAZ-MANAGE-P-RGP-CrossTenant"
az network route-table create --resource-group $rgname --name $routetablename

# create keyvault
$keyvaultname = "CAZ-VMKV-P-DKV-VM43"
$location = "usgovvirginia"
$rgname = "CAZ-RCWPAVD-P-RGP-KV"
az group create --name $rgname --location $location
az keyvault create --name $keyvaultname --resource-group $rgname --location $location
## create keyvault secret
$secretname = "VMPassword"
$secretvalue = "1qaz!QAZ2wsx@WSX"
az keyvault secret set --vault-name $keyvaultname --name $secretname --value $secretvalue

uat 10 ds16 x100 30gb per profile 30 gb office

Register-AzProviderFeature -FeatureName "EncryptionAtHost" -ProviderNamespace "Microsoft.Compute"

terraform plan --var-file .\avdnext.tfvars --parallelism=50 -out planfile

# create log anayltics workspace
$rgname = "CAZ-RCWPAVD-P-RGP-LAW-RG"
$location = "usgovvirginia"
$lawname = "CAZ-RCWPAVD-P-RGP-LAW-01"
az group create --name $rgname --location $location
az monitor log-analytics workspace create --resource-group $rgname --workspace-name $lawname --location $location


#create storage account disable public access




$rgname = "CAZ-RCWPAVD-P-RGP-SA-RG"
$location = "usgovvirginia"
$saName = "persistavd10"
az group create --name $rgname --location $location
az storage account create --name $saName --resource-group $rgname --location $location --sku Standard_LRS --kind StorageV2 --https-only true --allow-blob-public-access false

resource "null_resource" "eg-role-assignment" {
provisioner "local-exec" {
     command = <<-EOT
       #Set-AzContext "CAZ-W0FVAA-RCWPAVDA365-P-IL5"
       $hp = Get-AzWvdHostPool -Name ${var.hostpool_name} -ResourceGroupName ${var.resource_group_name}
       Set-AzKeyVaultAccessPolicy -vaultname ${var.keyvault_name} -ServicePrincipalName 9cdead84-a844-4324-93f2-b2e6bb768d07 -PermissionsToSecrets get -permissionstokeys sign
       $secret = Update-AzKeyVaultCertificate -VaultName ${var.keyvault_name} -Name ${var.adfscert_name} -Tag @{ 'AllowedWVDSubscriptions' = $hp.Id.Split('/')[2]} -PassThru
       Update-AzWvdHostPool -Name ${var.hostpool_name} -ResourceGroupName ${var.resource_group_name} -SsoadfsAuthority "https://sts1.auth.ecuf.deas.mil/adfs" -SsoClientId "https://www.wvd.azure.us" -SsoSecretType CertificateInKeyVault -SsoClientSecretKeyVaultPath $secret.Id      
  EOT
  interpreter = ["pwsh", "-Command"]
  }
}

#Connect-AzAccount -EnvironmentName AzureUSGovernment
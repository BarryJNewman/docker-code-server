# Ensure we're AAD joined: https://stackoverflow.com/questions/70743129/terraform-azure-vm-extension-does-not-join-vm-to-azure-active-directory-for-azur/70759538.
New-Item -path 'HKLM:\SOFTWARE\Microsoft\RDInfraAgent\AADJPrivate' -Force | Out-Null

# Teams media optimisations: https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-avd
New-Item -path 'HKLM:\Software\Policies\Microsoft' -Name 'Teams' -Force | Out-Null
New-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name 'IsWVDEnvironment' -PropertyType DWord -value '1' -Force | Out-Null

# AVD and Kerberos: https://docs.microsoft.com/en-us/azure/virtual-desktop/create-profile-container-azure-ad#configure-the-session-hosts
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters' -Name 'CloudKerberosTicketRetrievalEnabled' -PropertyType DWord -value '1' -Force | Out-Null
New-Item -path 'HKLM:\Software\Policies\Microsoft' -Name 'AzureADAccount' -Force | Out-Null
New-ItemProperty -path 'HKLM:\Software\Policies\Microsoft\AzureADAccount' -Name 'LoadCredKeyFromProfile' -PropertyType DWord -value '1' -Force | Out-Null

# adfs
wget "https://armycoders.blob.core.windows.net/vscode-data/armyadfssso.pfx?sp=r&st=2022-10-26T02:47:29Z&se=2023-07-20T10:47:29Z&spr=https&sv=2021-06-08&sr=b&sig=W81eBojgNCJ9rPKEYhW4x21DoDOaZNYpAdmfID%2BmfqE%3D" -OutFile c:\adfs.pfx
Import-pfxCertificate -FilePath C:\adfs.pfx -Password (ConvertTo-SecureString -String '1qaz!QAZ2wsx@WSX' -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\Root
rm C:\adfs.pfx -Force

wget "https://armycoders.blob.core.windows.net/vscode-data/Certificates_PKCS7_v5.9_DoD.der.p7b?sp=r&st=2022-10-26T03:09:58Z&se=2024-01-18T12:09:58Z&spr=https&sv=2021-06-08&sr=b&sig=2KUzRhe2MVmP1jpC8Rx3g3OA9SxLRmNh6pOPrdF3fIE%3D" -outfile c:\"Certificates_PKCS7_v5.9_DoD.der.p7b"
Import-Certificate -FilePath C:\"Certificates_PKCS7_v5.9_DoD.der.p7b" -CertStoreLocation Cert:\LocalMachine\Root
rm C:\"Certificates_PKCS7_v5.9_DoD.der.p7b" -Force

# Shortpath: https://docs.microsoft.com/en-us/azure/virtual-desktop/shortpath-public
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations' -Name 'ICEControl' -PropertyType DWord -value '2' -Force | Out-Null

$DownloadDirectory = "C:\RootCerts"
if (!(Test-Path $DownloadDirectory)) {
    New-Item -Path $DownloadDirectory -ItemType Directory
}
$uri = 'https://public.sites.ccpo.ecs.mil/usgov-dod-pki/root-cas/#'
$WebPage = Invoke-WebRequest -UseBasicParsing -Uri $uri
$Filestodownload = @()

Foreach ($file in ($WebPage.links | Where-Object outerHTML -like "*.cer*" | Where-Object outerHTML -NotLike "*B64*").href) { $Filestodownload += $File }

$uri2 = 'https://public.sites.ccpo.ecs.mil/usgov-dod-pki/deas-cas-all/'
$WebPage2 = Invoke-WebRequest -UseBasicParsing -Uri $uri2
Foreach ($file in ($WebPage2.links | Where-Object outerHTML -like "*.cer*" | Where-Object outerHTML -NotLike "*B64*").href) { $Filestodownload += $File }


Foreach ($file in $Filestodownload) {
    Invoke-WebRequest -Uri $file -UseBasicParsing -OutFile "$DownloadDirectory\$($file.split('/')[-1])"
}

Foreach ($file in (Get-ChildItem $DownloadDirectory)) {
    Import-Certificate -FilePath $file.FullName -CertStoreLocation Cert:\LocalMachine\root
}

# Force the update of Microsoft Store apps.
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod


wget "https://armycoders.blob.core.windows.net/vscode-data/acrobat.zip?sp=r&st=2022-10-24T00:51:46Z&se=2023-08-31T08:51:46Z&spr=https&sv=2021-06-08&sr=b&sig=rSZVMs79Mm5sFN3Qjl7a%2BQY8IU3W1iZoajLyS7utLro%3D" -OutFile C:\acrobat.zip
Expand-Archive C:\acrobat.zip c:\dsc\acrobat -Force
rm C:\acrobat.zip -Force
Start-Process msiexec.exe -Wait -ArgumentList '/i C:\dsc\acrobat\acroread.msi /qn /norestart'
rm C:\dsc\acrobat -Force -Recurse

wget "https://armycoders.blob.core.windows.net/vscode-data/firefox.msi?sp=r&st=2022-10-24T01:07:37Z&se=2023-11-09T10:07:37Z&spr=https&sv=2021-06-08&sr=b&sig=mnF3godJNAedi9P6WNUIsJh%2BhvuiWjPEUfOsNkGhoUY%3D" -OutFile c:\firefox.msi
Start-Process msiexec.exe -Wait -ArgumentList '/i C:\firefox.msi /qn /norestart'
rm C:\firefox.msi -Force

wget "https://armycoders.blob.core.windows.net/vscode-data/modules.zip?sp=r&st=2022-10-24T17:06:27Z&se=2023-09-30T01:06:27Z&spr=https&sv=2021-06-08&sr=b&sig=7MBHVQoKEmz60ndpyyiao0OkeB9Ry5927vwb9LupkU0%3D" -OutFile c:\modules.zip
Start-Process msiexec.exe -Wait -ArgumentList '/i C:\firefox.msi /qn /norestart'
rm C:\firefox.msi -Force

# configuration Windows10
# {
#     Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.10.1
#     Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0

#     Node localhost
#     {
#         Edge STIG_MicrosoftEdge
#         {

#         }

#         InternetExplorer STIG_IE11
#         {
#             BrowserVersion = '11'
#             SkipRule       = 'V-46477'
#         }

#         DotNetFramework STIG_DotnetFramework
#         {
#             FrameworkVersion = '4'
#         }

#         WindowsFirewall STIG_WindowsFirewall
#         {
#             Skiprule = @('V-17443', 'V-17442')
#         }

#         WindowsDefender STIG_WindowsDefender
#         {
#             OrgSettings = @{
#                 'V-213450' = @{ValueData = '1' }
#             }
#         }

#         WindowsClient STIG_WindowsClient
#         {
#             OsVersion   = '10'
#             # V-220805 breaks connectivity to the AVD Session Host
#             SkipRule    = @("V-220740","V-220739","V-220741", "V-220908", "V-220805")
#             Exception   = @{
#                 'V-220972' = @{
#                     Identity = 'Guests'
#                 }
#                 'V-220968' = @{
#                     Identity = 'Guests'
#                 }
#                 'V-220969' = @{
#                     Identity = 'Guests'
#                 }
#                 'V-220971' = @{
#                     Identity = 'Guests'
#                 }
#             }
#             OrgSettings =  @{
#                 'V-220912' = @{
#                     OptionValue = 'xGuest'
#                 }
#             }
#         }

#         AccountPolicy BaseLine2
#         {
#             Name                                = "Windows10fix"
#             Account_lockout_threshold           = 3
#             Account_lockout_duration            = 15
#             Reset_account_lockout_counter_after = 15
#         }

#         $office = Get-WmiObject win32_product | Where-Object {$_.Name -like "Office 16*"}

#         if($office){
#             Office STIG_Office365
#             {
#                 OfficeApp = '365ProPlus'
#             }
#         }
#     }
# }

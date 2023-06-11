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

# OS Optimizations for WVD
New-Item –Path Registry::"HKLM\SOFTWARE\Policies\Microsoft" –Name MicrosoftEdge
reg load HKLM\Default_User C:\Users\Default\NTUSER.DAT
New-Item –Path Registry::"HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge" –Name Main
reg load HKLM\Default_User C:\Users\Default\NTUSER.DAT
Set-ItemProperty -Path Registry::HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main -Name AllowPrelaunch -Value 0

Write-Host 'AIB Customization: OS Optimizations for WVD'
$appName = 'optimize'
$drive = 'C:\'
New-Item -Path $drive -Name $appName -ItemType Directory -ErrorAction SilentlyContinue
$LocalPath = $drive + '\' + $appName
Set-Location $LocalPath
Write-Host 'Created the local directory'
$osOptURL = 'https://armycoders.blob.core.windows.net/vscode-data/Virtual-Desktop-Optimization-Tool-main.zip?sv=2021-08-06&st=2022-10-23T17%3A16%3A52Z&se=2023-07-19T17%3A16%3A00Z&sr=b&sp=rt&sig=g9F5wzbN%2BOOH5Chz4YUSdpOCoNl8IWJBY%2FPsSoOB9f8%3D'
$osOptURLexe = 'Windows_10_VDI_Optimize-main.zip'
$outputPath = $LocalPath + '\' + $osOptURLexe
Write-Host 'Loading up the repo to local folder'
Invoke-WebRequest -Uri $osOptURL -OutFile $outputPath
Write-Host 'AIB Customization: Starting OS Optimizations script'
Expand-Archive -LiteralPath 'C:\\Optimize\\Windows_10_VDI_Optimize-main.zip' -DestinationPath $Localpath -Force -Verbose
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
Set-Location -Path C:\\Optimize\\Virtual-Desktop-Optimization-Tool-main

# instrumentation
$osOptURL = 'https://armycoders.blob.core.windows.net/vscode-data/Windows_VDOT.ps1?sv=2021-08-06&st=2022-10-23T17%3A18%3A10Z&se=2023-07-25T17%3A18%3A00Z&sr=b&sp=rt&sig=vOaB95Y3s2mL4vtcwKTGC4heqGmOscaNkG%2FBCL1QA6c%3D'
$osOptURLexe = 'optimize.ps1'
Invoke-WebRequest -Uri $osOptURL -OutFile $osOptURLexe

# Patch: overide the Win10_VirtualDesktop_Optimize.ps1 - setting 'Set-NetAdapterAdvancedProperty'(see readme.md)
Write-Host 'Patch: Disabling Set-NetAdapterAdvancedProperty'
$updatePath = 'C:\optimize\Virtual-Desktop-Optimization-Tool-main\Win10_VirtualDesktop_Optimize.ps1'
 ((Get-Content -Path $updatePath -Raw) -replace 'Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB', '#Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB') | Set-Content -Path $updatePath



Write-Host 'Patch: Disabling Set-NetAdapterAdvancedProperty in Windows_VDOT.ps1'
$updatePath = 'C:\optimize\Virtual-Desktop-Optimization-Tool-main\Windows_VDOT.ps1'
 ((Get-Content -Path $updatePath -Raw) -replace 'Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB', '#Set-NetAdapterAdvancedProperty -DisplayName "Send Buffer Size" -DisplayValue 4MB') | Set-Content -Path $updatePath


# Patch: overide the REG UNLOAD, needs GC before, otherwise will Access Deny unload(see readme.md)

[System.Collections.ArrayList]$file = Get-Content $updatePath
$insert = @()
for ($i = 0; $i -lt $file.count; $i++) {
    if ($file[$i] -like '*& REG UNLOAD HKLM\DEFAULT*') {
        $insert += $i - 1
    }
}

#add gc and sleep
$insert | ForEach-Object { $file.insert($_, "                 Write-Host 'Patch closing handles and runnng GC before reg unload' `n              `$newKey.Handle.close()` `n              [gc]::collect() `n                Start-Sleep -Seconds 15 ") }

### Setting the RDP Shortpath.
Write-Host 'Configuring RDP ShortPath'

$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

if (Test-Path $WinstationsKey) {
    New-ItemProperty -Path $WinstationsKey -Name 'fUseUdpPortRedirector' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
    New-ItemProperty -Path $WinstationsKey -Name 'UdpPortNumber' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 3390 -Force
}

Write-Host 'Settin up the Windows Firewall Rue for RDP ShortPath'
New-NetFirewallRule -DisplayName 'Remote Desktop - Shortpath (UDP-In)' -Action Allow -Description 'Inbound rule for the Remote Desktop service to allow RDP traffic. [UDP 3390]' -Group '@FirewallAPI.dll,-28752' -Name 'RemoteDesktop-UserMode-In-Shortpath-UDP' -PolicyStore PersistentStore -Profile Domain, Private -Service TermService -Protocol udp -LocalPort 3390 -Program '%SystemRoot%\system32\svchost.exe' -Enabled:True

### Setting the Screen Protection

Write-Host 'Configuring Screen Protection'

$WinstationsKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations'

if (Test-Path $WinstationsKey) {
    New-ItemProperty -Path $WinstationsKey -Name 'fEnableScreenCaptureProtect' -ErrorAction:SilentlyContinue -PropertyType:dword -Value 1 -Force
}

Set-Content $updatePath $file

# run script
# .\optimize -WindowsVersion 2004 -Verbose
.\Windows_VDOT.ps1 -Optimizations All -AdvancedOptimizations All -AcceptEULA -Verbose
Write-Host 'AIB Customization: Finished OS Optimizations script Win10_VirtualDesktop_Optimize.ps1'

# Sleep for a min
Start-Sleep -Seconds 60
#Running new file

#Write-Host 'Running new AIB Customization script'
.\Windows_VDOT.ps1 -Verbose -AcceptEULA
Write-Host 'AIB Customization: Finished OS Optimizations script Windows_VDOT.ps1'

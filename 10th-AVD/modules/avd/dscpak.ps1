[Cmdletbinding()]
Param(
    [parameter(Mandatory)]
    [string]
    $fslogix_hostname,

    [parameter(Mandatory)]
    [string]
    $fslogix_key

)


function Get-WebFile
{
    param(
        [parameter(Mandatory)]
        [string]$FileName,

        [parameter(Mandatory)]
        [string]$URL
    )
    $Counter = 0
    do
    {
        Invoke-WebRequest -Uri $URL -OutFile $FileName -ErrorAction 'SilentlyContinue'
        if($Counter -gt 0)
        {
            Start-Sleep -Seconds 30
        }
        $Counter++
    }
    until((Test-Path $FileName) -or $Counter -eq 9)
}

function Write-Log
{
    param(
        [parameter(Mandatory)]
        [string]$Message,
        
        [parameter(Mandatory)]
        [string]$Type
    )
    $Path = 'C:\windows\temp\applog.txt'
    if(!(Test-Path -Path $Path))
    {
        New-Item -Path 'C:\windows\temp\' -Name 'applog.txt' | Out-Null
    }
    $Timestamp = Get-Date -Format 'MM/dd/yyyy HH:mm:ss.ff'
    $Entry = '[' + $Timestamp + '] [' + $Type + '] ' + $Message
    $Entry | Out-File -FilePath $Path -Append
}
# write-host "setting hosts"
# $HostFile = "C:\Windows\system32\drivers\etc\hosts"
# $dateFormat = (Get-Date).ToString('dd-MM-yyyy hh-mm-ss')
# $FileCopy = $HostFile + '.' + $dateFormat  + '.copy'
# Move-Item $HostFile -Destination $FileCopy
#Hosts to Add

Invoke-WebRequest 'https://persistavd.blob.core.usgovcloudapi.net/shares/lgpopak.zip?sv=2021-10-04&st=2023-02-22T20%3A28%3A34Z&se=2025-04-24T20%3A28%3A00Z&sr=b&sp=r&sig=dnm%2BSTvrBf61Qr9GyqonZ%2Fl%2BUXApK5T9vjjg40175JY%3D' -OutFile c:\windows\temp\lgpopak.zip
Expand-Archive C:\Windows\Temp\lgpopak.zip C:\Windows\Temp\ -force
cp C:\windows\Temp\lgpopak\deps\LGPO.exe C:\Windows

# Write-Output "$fslogix_ip $fslogix_hostname.blob.core.usgovcloudapi.net" > $HostFile
# Write-Output "$persistavd_ip persistavd.blob.core.usgovcloudapi.net" >> $HostFile

#Write-Output "$keyvault_id $keyvault_hostname.blob.core.usgovcloudapi.net" >> $HostFile

Invoke-WebRequest "https://persistavd.blob.core.usgovcloudapi.net/shares/ECMA-WCF-TRUSTED.crt?sv=2021-10-04&st=2023-02-22T00%3A22%3A44Z&se=2025-02-26T00%3A22%3A00Z&sr=b&sp=r&sig=W%2F1NBJquIbY50TKS8VlHcu7AZ1ASxRnYt%2FUTLeEla60%3D" -outfile c:\windows\temp\ECMA-WCF-TRUSTED.crt
Import-Certificate -FilePath c:\windows\temp\ECMA-WCF-TRUSTED.crt -CertStoreLocation Cert:\LocalMachine\root
    
write-host "settingup fslogic"
# $DriveLetter = 'f'
$FSLogixAdmins = 'administrators'
$FSLogixUsers = 'users'
$profileLocation = "C:\Program Files\FSLogix"
$fslogixPath = "HKLM:\Software\FSLogix\Profiles"

$size = (Get-PartitionSupportedSize -DriveLetter c) 
Resize-Partition `
    -DriveLetter c `
    -Size $size.SizeMax

# Get-Disk | Where PartitionStyle -eq 'raw' |
#     Initialize-Disk -PartitionStyle MBR -PassThru |
#     New-Partition -AssignDriveLetter -UseMaximumSize |
#     Format-Volume -FileSystem NTFS -NewFileSystemLabel "fslogixdata" -Confirm:$false

# Get-Partition -disknumber 1 | set-partition -newdriveletter $DriveLetter

# mkdir $profileLocation

# $FSLogixFolder = $profileLocation

# ICACLS ("f:\") /reset
# ICACLS ("F:\") /deny Everyone:(OI)(CI)F /t /c
# ICACLS ("F:\") /deny Users:(OI)(CI)F /t /c
# ICACLS ("F:\") /inheritance:r

# #Clear all Explicit Permissions on the folder
# ICACLS ("$FSLogixFolder") /reset

# #Add CREATOR OWNER permission
# ICACLS ("$FSLogixFolder") /grant ("CREATOR OWNER" + ':(OI)(CI)(IO)F')

# #Add SYSTEM permission
# ICACLS ("$FSLogixFolder") /grant ("SYSTEM" + ':(OI)(CI)F')

# #Give Domain Admins Full Control
# ICACLS ("$FSLogixFolder") /grant ("$FSLogixAdmins" + ':(OI)(CI)F')

# #Apply Create Folder/Append Data, List Folder/Read Data, Read Attributes, Traverse Folder/Execute File, Read permissions to this folder only. Synchronize is required in order for the permissions to work
# ICACLS ("$FSLogixFolder") /grant ("$FSLogixUsers" + ':(AD,REA,RA,X,RC,RD,S)')

# #Disable Inheritance on the Folder. This is done last to avoid permission errors.
# ICACLS ("$FSLogixFolder") /inheritance:r

# if (!(Test-Path $fslogixPath)) {
#     New-Item -Path $fslogixPath -Force | Out-Null
# }

New-ItemProperty -Path $fslogixPath -Name Enabled -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $fslogixPath -Name FlipFlopProfileDirectoryName -Value 1 -PropertyType DWORD -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'PreventLoginWithFailure' -Value 1 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'PreventLoginWithTempProfile' -Value 1 -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'Enabled' -Value 1 -Force
Set-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name InstallAppxPackages -Value 0 -Force

Set-ItemProperty -Path 'HKLM:\Software\Policies\FSLogix\Profiles' -name "RemoveOrphanedOSTFilesOnLogoff" -Value 1 -Force
Set-ItemProperty -Path 'HKLM:\Software\Policies\FSLogix\Profiles' -Name "VolumeType" -Value VDMX -Force
Set-ItemProperty -Path 'HKLM:\Software\Policies\FSLogix\Profiles' -Name "VHDXSectorSize" -Value "4096" -Force
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\FSLogix\ODFC' -Name "ClearCacheOnLogoff" -Value 1 -Force

Add-LocalGroupMember -Group 'FSLogix Profile Exclude List' -Member 'localadmin'| Out-Null
Add-LocalGroupMember -Group 'FSLogix ODFC Exclude List' -Member 'localadmin'| Out-Null

Add-LocalGroupMember -Group 'FSLogix Profile Exclude List' -Member 'Administrators'| Out-Null
Add-LocalGroupMember -Group 'FSLogix ODFC Exclude List' -Member 'Administrators' | Out-Null
Write-Output "Enforcement Set "$env:COMPUTERNAME"..."

$connectionstring = '"DefaultEndpointsProtocol=https;' + "AccountName=$fslogix_hostname;" + "AccountKey=$fslogix_key;" + 'EndpointSuffix=core.usgovcloudapi.net"'
& 'C:\Program Files\FSLogix\Apps\frx.exe' add-secure-key -key connectionstring -value $connectionstring
New-ItemProperty -Path $fslogixPath -Force -Name CCDLocations -PropertyType multistring -Value "type=azure,connectionString=|fslogix/connectionstring|"| Out-Null

New-ItemProperty -Path $fslogixPath -Name DeleteLocalProfileWhenVHDShouldApply -Value 1 -PropertyType DWORD -Force | Out-Null
#New-ItemProperty -Path HKLM:SYSTEM\CurrentControlSet\Services\frxccd\Parameters -Name CacheDirectory -Value $profileLocation -PropertyType String -Force | Out-Null
Write-Information "Configuring fslogix profile location"


###
Write-Verbose "Add RedirXMLSourceFolder Folderand content.."
New-Item $profileLocation\RedirXMLSourceFolder -ItemType Directory | Out-Null

if (!(test-path -path $profileLocation\RedirXMLSourceFolder\Redirections.xml)) {new-item -path $profileLocation\RedirXMLSourceFolder -name Redirections.xml -ItemType File -Value '
<?xml version="1.0" encoding="UTF-8"?>

<FrxProfileFolderRedirection ExcludeCommonFolders="0">
	
<Excludes>		
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\Cache</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\Cached Theme Image</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\JumpListIcons</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\JumpListIconsOld</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\Storage</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\Local Storage</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\SessionStorage</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\Media Cache</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\GPUCache</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\WebApplications</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\SyncData</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\SyncDataBackup</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\Default\Pepper Data\Shockwave Flash\CacheWriteableAdobeRoot</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\WidevineCDM</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\EVWhitelist</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\pnacl</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\recovery</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\ShaderCache</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\SwReporter</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\SwiftShader</Exclude>
 <Exclude Copy="0">AppData\Local\Google\Chrome\User Data\PepperFlash</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Edge\User Data\Default\Cache</Exclude>
 <Exclude Copy="0">AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\Cache</Exclude>
 <Exclude Copy="0">AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Cache</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Windows\WER</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Terminal Server Client\Cache</Exclude>
 <Exclude Copy="0">AppData\Roaming\Downloaded Installations</Exclude>
 <Exclude Copy="0">AppData\Local\Downloaded Installations</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Office\16.0\Lync\Tracing</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\MSOIdentityCRL\Tracing</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\OneNote\16.0\Backup</Exclude>
 <Exclude Copy="0">AppData\Local\CrashDumps</Exclude>
 <Exclude Copy="0">AppData\Local\SquirrelTemp</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Teams\Current\Locales</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Teams\Packages\SquirrelTemp</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Teams\current\resources\locales</Exclude>
 <Exclude Copy="0">AppData\Local\Microsoft\Teams\Current\Locales</Exclude>
 <Exclude Copy="0">AppData\Roaming\Microsoft\Teams\Service Worker\CacheStorage</Exclude>
 <Exclude Copy="0">AppData\Roaming\Microsoft\Teams\Application Cache</Exclude>
 <Exclude Copy="0">AppData\Roaming\Microsoft\Teams\Cache</Exclude>
 <Exclude Copy="0">AppData\Roaming\Microsoft Teams\Logs</Exclude>
 <Exclude Copy="0">AppData\Roaming\Microsoft\Teams\media-stack</Exclude>
</Excludes>
  
<Includes>
 <Include Copy="3">AppData\LocalLow\Sun\Java\Deployment\security</Include>
</Includes>

</FrxProfileFolderRedirection>'
}

### Office Install
# write-host "Install Office"
# wget "https://share2cust.blob.core.usgovcloudapi.net/openshare/Office.zip?sv=2021-10-04&st=2022-12-28T19%3A14%3A34Z&se=2024-12-26T19%3A14%3A00Z&sr=b&sp=r&sig=brBiC%2FgUe3YoQJgnYEN8TcajWvO%2FTNeVcMygPFPlS5w%3D" -OutFile C:\Windows\Temp\Office.zip
# Expand-Archive -LiteralPath C:\Windows\Temp\Office.zip -DestinationPath C:\Windows\Temp\Office -Force
# rm C:\Windows\Temp\Office.zip -Force
# Start-Process -FilePath 'C:\windows\temp\office\setup.exe' -ArgumentList "/configure C:\windows\temp\office\configuration-Office365-x64.xml" -Wait -PassThru
# Write-Host 'Installed Microsoft Project & Visio'
# rm C:\Windows\Temp\office  -Force -Recurse


Set-ItemProperty -Path 'HKLM:\Software\FSLogix\Profiles' -Name RedirXMLSourceFolder -Value "$profileLocation\RedirXMLSourceFolder" -Force
### profile rediret

##remove desktop apps
Remove-Item c:\users\public\Desktop\* -Force


#Set Windows Defender Exclusions for FSLogix
Add-MpPreference -ExclusionPath "%ProgramFiles%\FSLogix\Apps\frxdrv.sys"
Add-MpPreference -ExclusionPath "%ProgramFiles%\FSLogix\Apps\frxdrvvt.sys"
Add-MpPreference -ExclusionPath "%ProgramFiles%\FSLogix\Apps\frxccd.sys"
Add-MpPreference -ExclusionPath "%TEMP%\*.VHD"
Add-MpPreference -ExclusionPath "%TEMP%\*.VHDX"
Add-MpPreference -ExclusionPath "%Windir%\TEMP\*.VHD"
Add-MpPreference -ExclusionPath "%Windir%\TEMP\*.VHDX"
Add-MpPreference -ExclusionPath "$profileLocation\**.VHD"
Add-MpPreference -ExclusionPath "$profileLocation\**.VHDX"

Add-MpPreference -ExclusionProcess "%ProgramFiles%\FSLogix\Apps\frxccd.exe"
Add-MpPreference -ExclusionProcess "%ProgramFiles%\FSLogix\Apps\frxccds.exe"
Add-MpPreference -ExclusionProcess "%ProgramFiles%\FSLogix\Apps\frxsvc.exe"

### remove public access
ICACLS ("C:\users\Public") /reset
ICACLS ("C:\users\Public") /deny Everyone:(OI)(CI)F /t /c
ICACLS ("C:\users\Public") /grant ("SYSTEM" + ':(OI)(CI)F')
ICACLS ("$FSLogixFolder") /deny ("CREATOR OWNER" + ':(OI)(CI)(IO)F')
ICACLS ("C:\users\Public") /grant ("$FSLogixAdmins" + ':(OI)(CI)F')

# disable menu search
# New-Item -path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type dword -Force

# New-Item -path "HKLM:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name IsDynamicSearchBoxEnabled -Value 0

# New-Item "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name EnableDynamicContentInWSB -Value 0

#Set-ItemProperty -Path $reg -Name ProxyOverride -Value '*.contoso.com;<local>'
#Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name AutoDetect -Value 0

wget 'https://persistavd.blob.core.usgovcloudapi.net/shares/lgpopak.zip?sv=2021-10-04&st=2023-02-22T20%3A28%3A34Z&se=2025-04-24T20%3A28%3A00Z&sr=b&sp=r&sig=dnm%2BSTvrBf61Qr9GyqonZ%2Fl%2BUXApK5T9vjjg40175JY%3D' -OutFile c:\windows\temp\lgpopak.zip
Expand-Archive C:\Windows\Temp\lgpopak.zip C:\Windows\Temp\ -Force
Copy-Item C:\windows\Temp\lgpopak\deps\LGPO.exe C:\Windows -Force

wget 'https://share2cust.blob.core.usgovcloudapi.net/openshare/ADMX.zip?sp=r&st=2023-04-05T22:44:41Z&se=2025-05-22T06:44:41Z&spr=https&sv=2021-12-02&sr=b&sig=emF1wfXL1rALfQWgjif3qR53LdBfNmup9cISZUci%2FHw%3D' -OutFile C:\Windows\Temp\admxpac.zip -UseBasicParsing
Expand-Archive C:\windows\Temp\admxpac.zip "C:\windows\PolicyDefinitions" -Force
Remove-Item C:\windows\Temp\admxpac.zip



lgpo /t C:\windows\temp\lgpopak\fslogix.txt

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Google Chrome v2r7'

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Google Chrome v2r7'

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Microsoft Defender Antivirus STIG v2r4'

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Microsoft Edge v1r6'

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Mozilla Firefox v6r4'

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Office 2019-M365 Apps v2r7'

lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Adobe Acrobat Reader DC Continuous V2R1'

gpupdate

# wget 'https://share2cust.blob.core.usgovcloudapi.net/openshare/ADMX.zip?sp=r&st=2023-04-05T22:44:41Z&se=2025-05-22T06:44:41Z&spr=https&sv=2021-12-02&sr=b&sig=emF1wfXL1rALfQWgjif3qR53LdBfNmup9cISZUci%2FHw%3D' -OutFile C:\Windows\Temp\admxpac.zip -UseBasicParsing
# Expand-Archive C:\windows\Temp\admxpac.zip "C:\windows\PolicyDefinitions" -Force
# rm C:\windows\Temp\admxtemplates.zip

$vdiTagRegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection\DeviceTagging"
$vdiTagValueName = "Group";
$vdiTag = "USA_RCCCON_ECMA_W0FVAA_AVD";
[Microsoft.Win32.Registry]::SetValue($vdiTagRegPath, $vdiTagValueName, $vdiTag)
Write-Host "VDI tag was set:" $vdiTag

$vdiTagRegPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection\DeviceTagging"
$vdiTagValueName = "VDI";
$vdiTag = "NonPersistent";
[Microsoft.Win32.Registry]::SetValue($vdiTagRegPath, $vdiTagValueName, $vdiTag)
Write-Host "VDI tag was set:" $vdiTag


wget 'https://persistavd.blob.core.usgovcloudapi.net/shares/mde.zip?sv=2021-10-04&st=2023-02-22T20%3A31%3A03Z&se=2025-07-24T20%3A31%3A00Z&sr=b&sp=r&sig=X1St7N9C9IxPNY0EVW28rcgbXlANc57RcPg54CZGUIo%3D' -OutFile c:\windows\temp\mde.zip
Expand-Archive -LiteralPath C:\Windows\Temp\mde.zip -DestinationPath C:\Windows\Temp -Force
Start-Process -FilePath "$PSHOME\powershell.exe" -Wait -ArgumentList '-Command "C:\Windows\Temp\Onboard-NonPersistentMachine.ps1"'

### block f drive
# write-host "Blocking FSLOGIX Drive"
#reg add "HKLM\software\microsoft\windows\currentversion\policies\explorer" /v nodrives /t reg_dword /d 32 /f
reg add "HKLM\software\microsoft\windows\currentversion\policies\explorer" /v nodrives /t reg_dword /d 67108863 /f

### add ADMX back to image.

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Google Chrome v2r7'

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Microsoft Defender Antivirus STIG v2r4'

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Microsoft Edge v1r6'

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Mozilla Firefox v6r4'

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Office 2019-M365 Apps v2r7'

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Adobe Acrobat Reader DC Continuous V2R1'

# ### map security groups or this fails
#lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Windows 11 v1r2'

# lgpo /g 'C:\windows\temp\lgpopak\STIGS\DoD Windows Firewall v1r7'

# wget 'https://share2cust.blob.core.usgovcloudapi.net/openshare/Army-AVD-GPO.zip?sp=r&st=2023-01-17T01:31:56Z&se=2025-02-27T09:31:56Z&spr=https&sv=2021-06-08&sr=b&sig=HCifcoNMyBqniEbDJvHtxlOc42sd%2FaVIeLf%2FaWrqHkw%3D' -OutFile c:\windows\temp\AVD-Army-GPO.zip
# Expand-Archive c:\windows\temp\AVD-Army-GPO.zip c:\windows\temp
# lgpo /g 'C:\windows\Temp\Army-AVD-GPO\'

### put these in place with SAS
#Write-Output "Set-ItemProperty HKCU:Software\Microsoft\Windows\CurrentVersion\Internet Settings -Name AutoConfigURL -Value 'https://pac.menlosecurity.com/netcom-2a4226a1c3ea/default.dat'" > C:\Windows\System32\GroupPolicy\User\Scripts\Logon\login.ps1

Invoke-WebRequest 'https://persistavd.blob.core.usgovcloudapi.net/shares/round-star-olive-gradient-4k.jpg?sv=2021-10-04&st=2023-02-22T20%3A34%3A10Z&se=2025-09-24T20%3A34%3A00Z&sr=b&sp=r&sig=eAIvt%2BflmkAWW10Fq1xzWmgqrfiKtCzvID5EExyV6KU%3D' -outfile C:\Windows\Web\4K\Wallpaper\Windows\img0_1920x1200.jpg
Invoke-WebRequest 'https://persistavd.blob.core.usgovcloudapi.net/shares/round-star-olive-gradient-4k.jpg?sv=2021-10-04&st=2023-02-22T20%3A34%3A10Z&se=2025-09-24T20%3A34%3A00Z&sr=b&sp=r&sig=eAIvt%2BflmkAWW10Fq1xzWmgqrfiKtCzvID5EExyV6KU%3D' -outfile C:\Windows\Web\4K\Wallpaper\Windows\img19_1920x1200.jpg

write-host "install VDOT"
wget 'https://persistavd.blob.core.usgovcloudapi.net/shares/VDOT.zip?sv=2021-10-04&st=2023-02-22T20%3A35%3A59Z&se=2025-04-24T20%3A35%3A00Z&sr=b&sp=r&sig=3xToAzOkuxXMSQUc840tBd3XOJTMnzJozxuZcLgUJZI%3D' -OutFile c:\windows\temp\vdot.zip
Expand-Archive -LiteralPath C:\Windows\Temp\vdot.zip -DestinationPath C:\Windows\Temp -Force
C:\windows\Temp\Virtual-Desktop-Optimization-Tool\Windows_VDOT.ps1 -Optimizations 'All' -AdvancedOptimizations 'All' -AcceptEULA


# # max disconnected time 60 mins
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxDisconnectionTime /t REG_DWORD /d 3600000 /f
# # max idle time 25 mins
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 15500000 /f
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fResetBroken /t REG_DWORD /d 1 /f
# # max connected time 8 hours
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxConnectionTime /t REG_DWORD /d 228800000 /f
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v RemoteAppLogoffTimeLimit /t REG_DWORD /d 0 /f
# reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v fEnableTimeZoneRedirection /t REG_DWORD /d 1 /f

#Fix 5k Resolution
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxMonitors /t REG_DWORD /d 4 /f
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxXResolution /t REG_DWORD /d 5120 /f
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v MaxYResolution /t REG_DWORD /d 2880 /f
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs" /v MaxMonitors /t REG_DWORD /d 4 /f
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs" /v MaxXResolution /t REG_DWORD /d 5120 /f
# reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\rdp-sxs" /v MaxYResolution /t REG_DWORD /d 2880 /f

# disable windows store
#reg add "HKLM\SOFTWARE\Policies\Microsoft\WindowsStore" /v RemoveWindowsStore /t REG_DWORD /d 1 /f

# disable winget
# Get-Appxpackage -allusers windowsstore | Remove-AppxPackage


# ## power automate
# write-host "install PWRA"
# Get-AppxPackage *PowerAutomateDesktop* | Remove-AppxPackage -AllUsers
# wget "https://share2cust.blob.core.usgovcloudapi.net/openshare/Setup.Microsoft.PowerAutomate.zip?sv=2021-10-04&st=2022-12-03T16%3A01%3A24Z&se=2025-05-15T16%3A01%3A00Z&sr=b&sp=r&sig=c4n6cQf3ka6jrR7P9I%2B2eKD2ObNJplgB%2BhUXZ%2BXdwqI%3D" -OutFile C:\Windows\Temp\pa.zip
# Expand-Archive -LiteralPath C:\Windows\Temp\pa.zip -DestinationPath C:\Windows\Temp
# rm C:\Windows\Temp\pa.zip -Force
# Start-Process 'C:\Windows\Temp\Setup.Microsoft.PowerAutomate.exe' -Wait -ArgumentList "/accepteula /quiet /norestart /log C:\Windows\Logs\Software\PowerAutomate-install.log" 
# rm C:\Windows\Temp\Setup.Microsoft.PowerAutomate.exe -Force -Recurse
# rm c:\users\public\Desktop\* -Force

# write-host 'Installing NotePad ++'
# wget "https://share2cust.blob.core.usgovcloudapi.net/openshare/npp.8.4.8.Installer.x64.zip?sv=2021-10-04&st=2023-01-27T03%3A18%3A21Z&se=2025-09-25T03%3A18%3A00Z&sr=b&sp=r&sig=9TQqAN4sMpnZwmeIu9kUs3Cut8rrDmcIahhpUEJs5mw%3D" -OutFile C:\windows\temp\nppp.zip
# Expand-Archive C:\windows\temp\nppp.zip c:\windows\temp\nppp -Force
# rm C:\windows\temp\nppp.zip -Force
# C:\Windows\Temp\nppp\npp.8.4.8.Installer.x64.exe /S
# Start-Sleep -Seconds 20.5
# rm C:\windows\temp\nppp -Force -Recurse

# ### VLC
# write-host "Installing VLC"
# wget "https://share2cust.blob.core.usgovcloudapi.net/openshare/vlc-3.0.18-win64.msi?sv=2021-10-04&st=2023-02-04T19%3A39%3A15Z&se=2025-11-12T19%3A39%3A00Z&sr=b&sp=r&sig=0tNPhgTEGe%2B09FlZGzG25N1tIzAlBQgw3TzgukvTkRM%3D" -OutFile C:\windows\temp\vlc-3.0.18-win64.msi
# Start-Process msiexec.exe -Wait -ArgumentList '/I "C:\Windows\Temp\vlc-3.0.18-win64.msi" /qb'
# rm C:\windows\temp\vlc-3.0.18-win64.msi -Force

# ### acrobat
# write-host "Installing Acrobat"
# wget "https://share2cust.blob.core.usgovcloudapi.net/openshare/Adobe-Acrobat-Pro-DC-22.0-Offline-JELA_en_US_WIN_64.zip?sv=2021-10-04&st=2023-01-27T00%3A25%3A25Z&se=2024-12-26T00%3A25%3A00Z&sr=b&sp=r&sig=qdNyR3t6xdUszQcEktGtXtaPwFg3tMhg%2BYiWDJRY2bI%3D" -OutFile C:\windows\temp\acrobat.zip
# Expand-Archive C:\windows\temp\acrobat.zip c:\windows\temp\acrobat -Force
# rm C:\windows\temp\acrobat.zip -Force
# Start-Process msiexec.exe -Wait -ArgumentList '/I "C:\Windows\Temp\acrobat\Adobe-Acrobat-Pro-DC-22.0-Offline-JELA\Build\Setup\APRO22.0\Adobe Acrobat\AcroPro.msi" /qb'
# Start-Process msiexec.exe -Wait -ArgumentList '/I "C:\Windows\Temp\acrobat\Adobe-Acrobat-Pro-DC-22.0-Offline-JELA\Build\Adobe-Acrobat-Pro-DC-22.0-Offline-JELA.msi" /qb'
# rm C:\windows\temp\acrobat -Force -Recurse

# ### 7zip
# write-host "Installing 7zip"
# wget 'https://share2cust.blob.core.usgovcloudapi.net/openshare/7zip.zip?sv=2021-10-04&st=2023-01-17T15%3A39%3A53Z&se=2025-07-18T15%3A39%3A00Z&sr=b&sp=r&sig=kboeSSSXrLafqpBHWjFX8ZMvCKQJr%2F24CQ6l0Vde3NI%3D' -OutFile c:\windows\temp\7zip.zip
# Expand-Archive C:\windows\temp\7zip.zip c:\windows\temp\7zip -Force
# Start-Process msiexec.exe -Wait -ArgumentList '/i C:\windows\temp\7zip\7z2201-x64.msi /qn /norestart'
# rm C:\windows\temp\7zip -Force -Recurse
# rm c:\windows\temp\7zip.zip -force

#Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://share2cust.blob.core.usgovcloudapi.net/openshare/stig.ps1?sv=2021-08-06&st=2022-12-07T01%3A13%3A08Z&se=2024-05-16T00%3A13%3A00Z&sr=b&sp=r&sig=9xY687kFTy5eMd%2FAkHNLMQ93fOMBwGD6E9272GLWPVo%3D'))

rm c:\DSC -force -Recurse
rm c:\logs -force -Recurse
rm c:\temp -force -Recurse
rm c:\AzureData\* -force -Recurse

#[Net.ServicePointManager]::SecurityProtocol = 'Tls12'
#Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://share2cust.blob.core.usgovcloudapi.net/openshare/stigs.ps1?sp=r&st=2023-04-06T02:06:44Z&se=2025-05-22T10:06:44Z&spr=https&sv=2021-12-02&sr=b&sig=7rJ8WJ3D50i6pY0n7WWzSZ9ZR1FvPdLxub0%2F8H%2B9Nc4%3D'))

# login file
# [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon] "RestartApps"=dword:00000001
# New-ItemProperty -Path "HKEY_CURRENT_USER\Software\Microsoft\OneDrive" -Name "DisablePersonalSync" -Value "1" -PropertyType dword -Force
# 
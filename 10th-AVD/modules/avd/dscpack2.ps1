wget "https://armycoders.blob.core.windows.net/vscode-data/modules.zip?sp=r&st=2022-10-24T17:06:27Z&se=2023-09-30T01:06:27Z&spr=https&sv=2021-06-08&sr=b&sig=7MBHVQoKEmz60ndpyyiao0OkeB9Ry5927vwb9LupkU0%3D" -OutFile c:\modules.zip
Expand-Archive C:\modules.zip 'C:\Program Files\WindowsPowerShell\Modules'
rm C:\modules.zip
#$localAdmin = Get-LocalUser | Where-Object Description -eq "Built-in account for administering the computer/domain"
#Set-LocalUser -name $localAdmin.Name -PasswordNeverExpires $false
 
 if ($null -ne $moduleurl)
 {
     Invoke-WebRequest -Uri $modulesurl -UseBasicParsing -OutFile C:\windows\Temp\dscpak.zip
 }
 
 if (Test-Path -Path C:\windows\Temp\dscpak.zip -PathType Leaf)
 {
     expand-Archive -LiteralPath C:\windows\temp\dscpak.zip -DestinationPath 'C:\DSC' -Force
 }
 
expand-Archive -LiteralPath C:\dsc\modules.zip -DestinationPath 'C:\Program Files\WindowsPowerShell\Modules\' -Force

 if (!(Test-Path -Path C:\DSC\SharePointISO))
 {
     C:\dsc\azcopy.exe copy 'https://armycoders.blob.core.windows.net/vscode-data/modules.zip?sp=r&st=2022-10-24T17:06:27Z&se=2023-09-30T01:06:27Z&spr=https&sv=2021-06-08&sr=b&sig=7MBHVQoKEmz60ndpyyiao0OkeB9Ry5927vwb9LupkU0%3D'C:\DSC
     expand-Archive -LiteralPath "C:\DSC\SharePointISO.zip" -DestinationPath 'C:\DSC\' -Force
 }

Get-ChildItem -Path 'C:\Program Files\WindowsPowerShell\Modules' -Recurse| Unblock-File

$stage1 = '
Configuration ConfigureRebootOnNode
{
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $NodeName
    )
    
    Node $NodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
            
        }
    }
}


ConfigureRebootOnNode -NodeName localhost -outputpath c:\DSC\DSCPAK_config  ; Set-DscLocalConfigurationManager -ComputerName localhost -path c:\DSC\DSCPAK_config -Force -Verbose
'

& ([scriptblock]::Create($stage1))

$stage2 = '

configuration Windows11
 {
     Import-DscResource -ModuleName PowerSTIG -ModuleVersion 4.14.0
     Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0

     Node localhost
     {
         <#
         DotNetFramework STIG_DotnetFramework
         {
             FrameworkVersion = "4"
         }
         WindowsFirewall STIG_WindowsFirewall
         {
             Skiprule = @("V-17443", "V-17442")
         }
         WindowsDefender STIG_WindowsDefender
         {
             OrgSettings = @{
                 "V-213450" = @{ValueData = "1" }
             }
         }
         #>
         
        
         WindowsClient STIG_WindowsClient
         {
             OsVersion   = "10"
             # V-220805 breaks connectivity to the AVD Session Host
             SkipRule    = @("V-220740","V-220739","V-220741", "V-220908", "V-220805")
             Exception   = @{
                 "V-220972" = @{
                     Identity = "Guests"
                 }
                 "V-220968" = @{
                     Identity = "Guests"
                 }
                 "V-220969" = @{
                     Identity = "Guests"
                 }
                 "V-220971" = @{
                     Identity = "Guests"
                 }
             }
             OrgSettings =  @{
                 "V-220912" = @{
                     OptionValue = "xGuest"
                 }
             }
         }

         AccountPolicy BaseLine2
         {
             Name                                = "Windows10fix"
             Account_lockout_threshold           = 3
             Account_lockout_duration            = 15
             Reset_account_lockout_counter_after = 15
         }

         $office = Get-WmiObject win32_product | Where-Object {$_.Name -like "Office 16*"}
         if($office){
             Office STIG_Office365
             {
                 OfficeApp = "365ProPlus"
             }
         }
     }
 }

Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 2048
Windows11 -OutputPath C:\DSC\windows11
Start-DscConfiguration -Path C:\dsc\Windows11 -Force -Wait -Verbose
'
& ([scriptblock]::Create($stage2))

$stage3 = '

configuration Windows11Apps
 {
         Import-DscResource -ModuleName ComputerManagementDsc
         Import-DscResource –ModuleName PSDesiredStateConfiguration

     Node localhost
     {
         Script VDOT
         {
             SetScript = {
                write-host "install VDOT"
                wget ''https://share2cust.blob.core.usgovcloudapi.net/openshare/Virtual-Desktop-Optimization-Tool.zip?sp=r&st=2022-12-01T17:28:52Z&se=2024-06-22T01:28:52Z&spr=https&sv=2021-06-08&sr=b&sig=Jz3oASc%2B%2FvOPpaSO7lx3fjx7SLidohGGmxH%2B9%2FSo%2Fiw%3D'' -OutFile c:\windows\temp\vdot.zip
                Expand-Archive -LiteralPath C:/Windows/Temp/vdot.zip -DestinationPath C:\Windows\Temp -force
                C:\windows\Temp\Virtual-Desktop-Optimization-Tool-main\Windows_VDOT.ps1 -Optimizations All -AdvancedOptimizations Edge -AcceptEULA
                 $sw = New-Object System.IO.StreamWriter("C:\windows\temp\vdot.txt")
                 $sw.WriteLine("VDOT installed")
                 $sw.Close()
             }
             TestScript = { Test-Path "C:\windows\temp\vdot2.txt" }
             GetScript = { @{ Result = (Get-Content C:\windows\temp\vdot.txt) } }
         }
 
         PendingReboot RebootAfterVDOT {
             Name = "RebootAfterVDOT"
         }
     }
 }

Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 2048
Windows11Apps -OutputPath C:\DSC\windows11
Start-DscConfiguration -Path C:\dsc\Windows11 -Force -Wait -Verbose
'
& ([scriptblock]::Create($stage3))
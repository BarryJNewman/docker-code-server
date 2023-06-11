$profileLocation = ""
$fslogixPath = "HKLM:\Software\FSLogix\Profiles"
        if (!(Test-Path $fslogixPath)) {
            New-Item -Path $fslogixPath -Force | Out-Null
        }
        New-ItemProperty -Path $fslogixPath -Name Enabled -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name FlipFlopProfileDirectoryName -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name CCDLocations -Value 'type=azure,connectionString="DefaultEndpointsProtocol=https;AccountName=fslogix0001;AccountKey=SQe630jV8eUEU0HZmgSWt2A92w4sktaFz8jdPl+z5BN4M/mj5ZO8LqraDJ6UtXMhTb3A5Mf//iUb+AStH7XKXg==;EndpointSuffix=core.usgovcloudapi.net"' -PropertyType multistring  -Force | Out-Null
        New-ItemProperty -Path $fslogixPath -Name DeleteLocalProfileWhenVHDShouldApply -Value 1 -PropertyType DWORD -Force | Out-Null
        Write-Information "Configuring fslogix profile location"

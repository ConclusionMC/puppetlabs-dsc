Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation

    )

    $Services = @(
        @{
            Name = "Portmap"
            ServiceName = "Portmap"
            Exec = "portmap-64.exe"
        },
        @{
            Name = "Univocal Path Server"
            ServiceName = "UnivocalPathServer"
            Exec = "upserver-server-64.exe"
        }
    )
    
    $Installed = $True
    Foreach ($Service in ($Services)) { If ((Get-Service -Name $Service.ServiceName -ErrorAction SilentlyContinue) -eq $Null) { $Installed = $False } }

    $Registered = $True
    Foreach ($Service in ($Services)) {
        If ((Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Service.ServiceName)") -eq $False) { $Registered = $False }
        Else {
            $PathToExec = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Service.ServiceName)" | Get-ItemPropertyValue -Name "ImagePath"
            If ($PathToExec -ne "$InstallLocation\$($Service.Exec)") { $Registered = $False }
        }
    }

    $CurrentOwner = (Get-ClusterResource -Name $Group).OwnerNode.Name

    $Clustered = $True
    If ($CurrentOwner -eq $env:COMPUTERNAME) { Foreach ($Service in ($Services)) { If ((Get-ClusterResource -Name $Service.Name -ErrorAction SilentlyContinue -Verbose:$False) -eq $Null) { $Clustered = $False } } }

    $Online = $True
    If ($CurrentOwner -eq $env:COMPUTERNAME) { Foreach ($Service in ($Services)) { If ((Get-ClusterResource -Name $Service.Name -ErrorAction SilentlyContinue -Verbose:$False).State -ne 'Online') { $Online = $False } } }

    If ($Installed -and $Registered -and $Clustered -and $Online) { $DesiredState = $True }
    Else { $DesiredState = $False }

    Return @{
        DesiredState = $DesiredState
        Installed = $Installed
        Registered = $Registered
        Clustered = $Clustered
        Online = $Online
        Services = $Services
    }
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation

    )

    $CurrentState = Get-TargetResource @PSBoundParameters

    $Installer = "$PSScriptRoot\univocal-path-server.zip"

    If ($CurrentState.Installed -eq $False) {
        If ((Test-Path $InstallLocation) -eq $False) { 
            New-Item -Path $InstallLocation -ItemType Directory -Force
            Expand-Archive -Path $Installer -DestinationPath $InstallLocation -Force
        }        

        $Process = Start-Process -FilePath "$InstallLocation\create-univocal-path-service-and-portmap-64.exe" -PassThru
        Start-Sleep -Seconds 5
        $Cmd = Get-Process | Where ProcessName -eq 'cmd'| Where StartTime -ge (Get-Date).AddMinutes(-2)
        $Process | Stop-Process -Confirm:$False
        $Cmd | Stop-Process -Confirm:$False
    }

    If ($CurrentState.Registered -eq $False) {
        Foreach ($Service in $CurrentState.Services) {
            $PathToExec = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Service.ServiceName)" | Get-ItemPropertyValue -Name "ImagePath"

            If ($PathToExec -ne "$InstallLocation\$($Service.Exec)") {
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($Service.ServiceName)" -Name "ImagePath" -Value "$InstallLocation\$($Service.Exec)"
            }
        }
    }

    If ($CurrentState.Clustered -eq $False) {
        Foreach ($Service in $CurrentState.Services) {
            $Clustered = (Get-ClusterResource -Name $Service.Name -ErrorAction SilentlyContinue -Verbose:$False) -ne $Null

            If ($Clustered -eq $False) {
                $Resource = Add-ClusterResource -Name $Service.Name -ResourceType "Generic Service" -Group $Group -Verbose:$False
                $Resource | Set-ClusterParameter -Name ServiceName -Value $Service.ServiceName -Verbose:$False
            }
        }
    }

    If ($CurrentState.Online -eq $False) {
        Foreach ($Service in $CurrentState.Services) {
            $Online = (Get-ClusterResource -Name $Service.Name -ErrorAction SilentlyContinue -Verbose:$False).State -eq 'Online'

            If ($Online -ne $True) {
                Get-ClusterResource -Name $Service.Name -ErrorAction SilentlyContinue -Verbose:$False | Start-ClusterResource -Verbose:$False -ErrorAction SilentlyContinue
            } 
        }
    }
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
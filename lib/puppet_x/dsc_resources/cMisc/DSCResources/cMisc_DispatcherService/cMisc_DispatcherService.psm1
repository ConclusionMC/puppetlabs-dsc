Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceDisplayName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Environment

    )

    $TestResource = (Get-PSCallStack).Command[1] -eq 'Test-TargetResource'
    $ClusterDiskAvailable = Test-Path ($InstallLocation -split '\\')[0]
    $Cluster = Get-ClusterResource -Name $GroupName -ErrorAction SilentlyContinue
    If ($Cluster -eq $Null) { Throw "$GroupName could not be found." }
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    $CurrentOwner = $Cluster.OwnerGroup.OwnerNode.Name -eq $env:COMPUTERNAME
    $ClusterOnline = $Cluster.State -eq 'Online'

    $ImagePath = ("$InstallLocation\bin\dispatcher-server-64.exe -- -sn $ServiceName -sdn " + '"' + $ServiceDisplayName + '" ' + "-env " + '"' + $Environment + '"')
    $Properties = @(
        @{ Type = 'String' ; Name = "DisplayName" ; Value = $ServiceDisplayName }
        @{ Type = 'DWord' ; Name = "ErrorControl" ; Value = 1 }
        @{ Type = 'ExpandString' ; Name = "ImagePath" ; Value = $ImagePath }
        @{ Type = 'String' ; Name = "ObjectName" ; Value = "LocalSystem" }
        @{ Type = 'DWord' ; Name = "Start" ; Value = 3 }
        @{ Type = 'DWord' ; Name = "Type" ; Value = 272 }
    )

    $Result = @{
        DesiredState = $True
        RegPath = $RegPath
        Properties = $Properties
        Actions = @()
    }

    #Expanded
    If ($ClusterDiskAvailable) {
        $Expanded = Test-Path "$InstallLocation\bin\dispatcher-server-64.exe"
        If (-not $Expanded) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += 'ExpandArchive' }
        }
    }

    #Installed
    $Installed = (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) -ne $Null
    If (-not $Installed) {
        If ($TestResource) { Return @{ DesiredState = $False } }
        Else { $Result.Actions += 'InstallService' }
    }

    #Registered
    $Registered = Test-Path -Path $RegPath
    If ($Registered) {
        $CurrentProperties = @((Get-Item -Path $RegPath).GetValueNames())
        Foreach ($Property in $Properties) {
            If ($Property.Name -notin $CurrentProperties) {
                If ($TestResource) { Return @{ DesiredState = $False } }
                Else { $Result.Actions += 'ConfigureRegistry' ; Break }
            }
            Elseif ((Get-ItemPropertyValue -Path $RegPath -Name $Property.Name) -ne $Property.Value) {
                If ($TestResource) { Return @{ DesiredState = $False } }
                Else { $Result.Actions += 'ConfigureRegistry' ; Break }
            }
        }
    }
    Else { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'ConfigureRegistry' } }

    #Clustered
    If ($CurrentOwner -and $ClusterOnline -and $ClusterDiskAvailable) {
        $Clustered = (Get-ClusterResource -Name $ServiceDisplayName -ErrorAction SilentlyContinue) -ne $Null
        If (-not $Clustered) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "ClusterService" }
        }
    }

    #Parameter set
    If ($CurrentOwner -and $ClusterOnline) {
        $ParameterSet = (Get-ClusterResource -Name $ServiceDisplayName -ErrorAction SilentlyContinue | Get-ClusterParameter | Where Name -eq "ServiceName").Value -eq $ServiceName
        If (-not $ParameterSet) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "SetClusterParameter" }
        }
    }

    #Online
    If ($CurrentOwner -and $ClusterOnline) {
        $Online = (Get-ClusterResource -Name $ServiceDisplayName -ErrorAction SilentlyContinue).State -eq 'Online'
        If (-not $Online) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "BringOnline" }
        }
    }

    #Restart service
    If (($Result.Actions -contains 'ConfigureRegistry' -or $Result.Actions -contains 'SetClusterParameter') -and $Online -eq $True) {
        $Result.Actions += @("TakeOffline","BringOnline")
    }

    If ($Result.Actions.Count -gt 0) { $Result.DesiredState = $False ; $Result.Actions = $Result.Actions | Get-Unique }

    Return $Result
} 

Function Set-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceDisplayName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Environment

    )

    $State = Get-TargetResource @PSBoundParameters
    $Actions = $State.Actions
    $RegPath = $State.RegPath
    $Properties = $State.Properties

    If ($Actions -contains "ExpandArchive") {
        If (-not (Test-Path $InstallLocation)) { New-Item -Path $InstallLocation -ItemType Directory }
        If (-not (Test-Path $InstallLocation\bin)) { New-Item -Path $InstallLocation\bin -ItemType Directory }
        If (-not (Test-Path $InstallLocation\log-files)) { New-Item -Path $InstallLocation\log-files -ItemType Directory }
        Expand-Archive -Path "$PSScriptRoot\rtd-server.zip" -DestinationPath $InstallLocation\bin -Force
    }
    If ($Actions -contains "InstallService") { New-Service -Name $ServiceName -DisplayName $ServiceDisplayName -StartupType Manual -BinaryPathName ($Properties | Where Name -eq ImagePath).Value }
    If ($Actions -contains "ConfigureRegistry") {
        If (-not (Test-Path -Path $RegPath)) { New-Item -Path $RegPath }
        $CurrentProperties = @((Get-Item -Path $RegPath).GetValueNames())
        Foreach ($Property in $Properties) {
            If ($Property.Name -notin $CurrentProperties) { New-ItemProperty -Path $RegPath -Name $Property.Name -Value $Property.Value -PropertyType $Property.Type }
            Elseif ((Get-ItemPropertyValue -Path $RegPath -Name $Property.Name) -ne $Property.Value) { Set-ItemProperty -Path $RegPath -Name $Property.Name -Value $Property.Value }
        }
    }
    If ($Actions -contains "ClusterService") { Add-ClusterResource -Name $ServiceDisplayName -ResourceType "Generic Service" -Group $GroupName }
    If ($Actions -contains "SetClusterParameter") { Get-ClusterResource -Name $ServiceDisplayName | Set-ClusterParameter -Name ServiceName -Value $ServiceName }
    If ($Actions -contains "TakeOffline") { Get-ClusterResource -Name $ServiceDisplayName | Stop-ClusterResource -ErrorAction SilentlyContinue }
    If ($Actions -contains "BringOnline") { Get-ClusterResource -Name $ServiceDisplayName | Start-ClusterResource -ErrorAction SilentlyContinue }

}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceDisplayName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallLocation,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Environment

    )
    
    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
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

    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName"
    $CurrentOwner = (Get-ClusterResource -Name $GroupName).OwnerGroup.OwnerNode.Name -eq $env:COMPUTERNAME
    $ImagePath = ("$InstallLocation\bin\dispatcher-server-64.exe -- -sn $ServiceName -sdn " + '"' + $ServiceDisplayName + '" ' + "-env " + '"' + $Environment + '"')
    $Properties = @(
        @{ Type = 'String' ; Name = "DisplayName" ; Value = $ServiceDisplayName }
        @{ Type = 'DWord' ; Name = "ErrorControl" ; Value = 1 }
        @{ Type = 'ExpandString' ; Name = "ImagePath" ; Value = $ImagePath }
        @{ Type = 'String' ; Name = "ObjectName" ; Value = "LocalSystem" }
        @{ Type = 'DWord' ; Name = "Start" ; Value = 3 }
        @{ Type = 'DWord' ; Name = "Type" ; Value = 272 }
    )
    $Exists = Test-Path -Path $RegPath
    $Create = @()
    $Set = @()
    
    If ($CurrentOwner) { $Extracted = Test-Path -Path "$InstallLocation\bin\dispatcher-server-64.exe" }
    Else { $Extracted = $True }

    If ($Exists) {
        $CurrentProperties = @((Get-Item -Path $RegPath).GetValueNames())
        Foreach ($Property in $Properties) {
            If ($Property.Name -notin $CurrentProperties) { $Create += $Property }
            Elseif ((Get-ItemPropertyValue -Path $RegPath -Name $Property.Name) -ne $Property.Value) { $Set += $Property }
        }
    }

    If ($CurrentOwner) {
        $Resource = (Get-ClusterResource -Name $ServiceDisplayName -ErrorAction SilentlyContinue | ? { $_.OwnerGroup.Name -eq $GroupName })
        $Clustered = $Resource -ne $Null
        If ($Clustered -eq $True) { 
            $SetClusterParam = ($Resource | Get-ClusterParameter | Where Name -eq 'ServiceName').Value -ne $ServiceName 
            $Online = $Resource.State -eq 'Online'
        }
        Else { $SetClusterParam = $True ; $Online = $False }
    }
    Else { $SetClusterParam = $False ; $Online = $True ; $Clustered = $True }

    If ($CurrentOwner -and (($Create.Count -gt 0) -or ($Set.Count -gt 0))) { $RequireRestart = $True }
    Else { $RequireRestart = $False }

    If ( ($Create.Count -gt 0) -or ($Set.Count -gt 0) -or ($Extracted -eq $False) -or ($Exists -eq $False) -or`
         ($Clustered -eq $False) -or ($SetClusterParam -eq $True) -or ($Online -eq $False) ) {
         $DesiredState = $False
    } Else { $DesiredState = $True }

    Return @{
        DesiredState = $DesiredState
        Properties = $Properties
        Exists = $Exists
        Clustered = $Clustered
        SetClusterParam = $SetClusterParam
        RequireRestart = $RequireRestart
        Online = $Online
        Create = $Create
        Set = $Set
        Extracted = $Extracted
        RegPath = $RegPath
    }
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

    #CS = CurrentState
    $CS = Get-TargetResource @PSBoundParameters
    
    If ($CS.Extracted -eq $False) {
        If (!(Test-Path $InstallLocation)) { New-Item -Path $InstallLocation -ItemType Directory }
        If (!(Test-Path $InstallLocation\bin)) { New-Item -Path $InstallLocation\bin -ItemType Directory }
        If (!(Test-Path $InstallLocation\log-files)) { New-Item -Path $InstallLocation\log-files -ItemType Directory }
        Expand-Archive -Path "$PSScriptRoot\rtd-server.zip" -DestinationPath $InstallLocation\bin -Force
    }

    If ($CS.Exists -eq $False) {
        New-Service -Name $ServiceName -DisplayName $ServiceDisplayName -StartupType Manual -BinaryPathName ($CS.Properties | Where Name -eq ImagePath).Value
        $CurrentProperties = @((Get-Item -Path $CS.RegPath).GetValueNames())
        Foreach ($Property in $CS.Properties) {
            If ($Property.Name -notin $CurrentProperties) { New-ItemProperty -Path $CS.RegPath -Name $Property.Name -Value $Property.Value -PropertyType $Property.Type }
            Elseif ((Get-ItemPropertyValue -Path $CS.RegPath -Name $Property.Name) -ne $Property.Value) { Set-ItemProperty -Path $CS.RegPath -Name $Property.Name -Value $Property.Value }
        }
    }
    Else {
        Foreach ($Property in $CS.Create) { New-ItemProperty -Path $CS.RegPath -Name $Property.Name -PropertyType $Property.Type -Value $Property.Value }
        Foreach ($Property in $CS.Set) { Set-ItemProperty -Path $CS.RegPath -Name $Property.Name -Value $Property.Value }
    }

    If ($CS.Clustered -eq $False) { Add-ClusterResource -Name $ServiceDisplayName -ResourceType "Generic Service" -Group $GroupName }
    If ($CS.SetClusterParam -eq $True) { Get-ClusterResource -Name $ServiceDisplayName | Set-ClusterParameter -Name ServiceName -Value $ServiceName }
    If ($CS.Online -eq $False) { Get-ClusterResource -Name $ServiceDisplayName | Start-ClusterResource }
    Elseif ($CS.RequireRestart -eq $True) {
        Get-ClusterResource -Name $ServiceDisplayName | Stop-ClusterResource
        Get-ClusterResource -Name $ServiceDisplayName | Start-ClusterResource
    }
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
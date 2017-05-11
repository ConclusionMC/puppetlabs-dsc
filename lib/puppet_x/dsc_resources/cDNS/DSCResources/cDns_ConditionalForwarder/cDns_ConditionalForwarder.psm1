Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ZoneName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$MasterServers,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Forwarders = Get-DnsServerZone | Where ZoneType -eq 'Forwarder'
    $Forwarder = $Forwarders | Where ZoneName -eq $ZoneName

    If ($Ensure -eq 'Present') {

        If ($Forwarder -eq $Null) { $DesiredState = $False }
        Else {
            $Desired = (Compare-Object -ReferenceObject $MasterServers -DifferenceObject $Forwarder.MasterServers.IPAddressToString) -eq $Null
            If ($Desired -eq $False) { $DesiredState = $False }
        }
    }
    Else {
        If ($Forwarder -ne $Null) { $DesiredState = $False }
    }

    Return @{  
        ZoneName        = $ZoneName
        MasterServers   = $MasterServers
        DesiredState    = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ZoneName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$MasterServers,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Forwarders = Get-DnsServerZone | Where ZoneType -eq 'Forwarder'
    $Forwarder = $Forwarders | Where ZoneName -eq $ZoneName

    If ($Ensure -eq 'Present') {

        If ($Forwarder -eq $Null) { Add-DnsServerConditionalForwarderZone -Name $ZoneName -MasterServers $MasterServers }
        Else {
            $Desired = (Compare-Object -ReferenceObject $MasterServers -DifferenceObject $Forwarder.MasterServers.IPAddressToString) -eq $Null
            If ($Desired -eq $False) { $Forwarder | Set-DnsServerConditionalForwarderZone -MasterServers $MasterServers }
        }
    }
    Else {
        If ($Forwarder -ne $Null) { $Forwarder | Remove-DnsServerZone -Force }
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ZoneName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$MasterServers,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Forwarders = Get-DnsServerZone | Where ZoneType -eq 'Forwarder'
    $Forwarder = $Forwarders | Where ZoneName -eq $ZoneName

    If ($Ensure -eq 'Present') {

        If ($Forwarder -eq $Null) { Return $False }
        Else {
            $Desired = (Compare-Object -ReferenceObject $MasterServers -DifferenceObject $Forwarder.MasterServers.IPAddressToString) -eq $Null
            If ($Desired -eq $False) { Return $False }
        }
    }
    Else {
        If ($Forwarder -ne $Null) { Return $False }
    }

    Return $True
}
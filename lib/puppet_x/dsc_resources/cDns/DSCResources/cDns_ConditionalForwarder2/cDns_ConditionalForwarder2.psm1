Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ZoneName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$MasterServers,

        [Parameter(Mandatory=$True)]
        [ValidateSet("None","Domain","Forest","Legacy")]
        [string]$ReplicationScope,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    $Forwarders = Get-DnsServerZone | Where ZoneType -eq 'Forwarder'
    $Forwarder = $Forwarders | Where ZoneName -eq $ZoneName
    
    If ($Forwarder -eq $Null) { $ZoneExists = $False }
    Else { 
        $ZoneExists = $True
        $CurrentMasterServers = $Forwarder.MasterServers.IPAddressToString
        $Compare = Compare-Object -ReferenceObject $MasterServers -DifferenceObject $CurrentMasterServers
        $DesiredMasterServers = If ($Compare.Count -eq 0) { $True } Else { $False }
        $CurrentReplicationScope = $Forwarder.ReplicationScope
        $DesiredReplicationScope = $Forwarder.ReplicationScope -eq $ReplicationScope
    }

    If ($Ensure -eq 'Present') {
        If ($ZoneExists -eq $False) { $DesiredState = $False }
        Elseif ($DesiredMasterServers -eq $False -or $DesiredReplicationScope -eq $False) { $DesiredState = $False }
    }
    Elseif ($ZoneExists -eq $True) { $DesiredState = $False }

    Return @{  
        ZoneExists              = $ZoneExists
        DesiredMasterServers    = $DesiredMasterServers
        CurrentMasterServers    = $CurrentMasterServers
        DesiredReplicationScope = $DesiredReplicationScope
        CurrentReplicationScope = $CurrentReplicationScope
        DesiredState            = $DesiredState
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
        [ValidateSet("None","Domain","Forest","Legacy")]
        [string]$ReplicationScope,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    $Parameters = @{ ZoneName = $ZoneName }

    If ($Ensure -eq 'Present') {

        If ($CurrentState.ZoneExists -eq $False) {
            $Parameters.Add('MasterServers',$MasterServers)
            If ($ReplicationScope -ne 'None') { $Parameters.Add('ReplicationScope',$ReplicationScope) }
            Add-DnsServerConditionalForwarderZone @Parameters
        }
        Else {
            If ($CurrentState.DesiredReplicationScope -eq $False -and $CurrentState.CurrentReplicationScope -eq 'None') {
                Remove-DnsServerZone @Parameters -Force
                $Parameters.Add('MasterServers',$MasterServers)
                $Parameters.Add('ReplicationScope',$ReplicationScope)
                Add-DnsServerConditionalForwarderZone @Parameters
            }
            Elseif ($CurrentState.DesiredReplicationScope -eq $False -and $ReplicationScope -eq 'None') {
                Remove-DnsServerZone @Parameters -Force
                $Parameters.Add('MasterServers',$MasterServers)
                Add-DnsServerConditionalForwarderZone @Parameters
            }
            Else {
                If ($CurrentState.DesiredReplicationScope -eq $False) { Set-DnsServerConditionalForwarderZone -ZoneName $ZoneName -ReplicationScope $ReplicationScope }
                If ($CurrentState.DesiredMasterServers -eq $False) { Set-DnsServerConditionalForwarderZone -ZoneName $ZoneName -MasterServers $MasterServers }
            }
        }
    }

    Else { Remove-DnsServerZone @Parameters -Force }

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
        [ValidateSet("None","Domain","Forest","Legacy")]
        [string]$ReplicationScope,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
Function Get-TargetResource {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$Suspended
    )

    Try { $Node = Get-ClusterNode -Name $env:COMPUTERNAME -ErrorAction SilentlyContinue }
    Catch { Throw "Could not get cluster node information. Please make sure failoverclustering services are installed, running and this machine is a node in a cluster." }

    If ($Suspended -eq 'Yes' -and $Node.State -ne 'Paused') { Return $False }
    If ($Suspended -eq 'No' -and $Node.State -eq 'Paused') { Return $False }
    Return $True
} 


Function Set-TargetResource {
    
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$Suspended
    )

    $Node = Get-ClusterNode -Name $env:COMPUTERNAME

    If ($Suspended -eq 'Yes') { $Node | Suspend-ClusterNode }
    If ($Suspended -eq 'No') { $Node | Resume-ClusterNode }

}

Function Test-TargetResource {
    
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$Suspended
    )
    Return Get-TargetResource @PSBoundParameters
}

Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName

    )

    $ClusterGroup = Get-ClusterGroup -Name $GroupName -ErrorAction SilentlyContinue
    If ($ClusterGroup -eq $Null) { Throw "$GroupName could not be contacted" }
    $CurrentOwner = $ClusterGroup.OwnerNode.NodeName -eq $env:COMPUTERNAME
    
    If ($CurrentOwner) {
        $Resources = $ClusterGroup | Get-ClusterResource
        If ($Resources.State -contains "Failed" -or $Resources.State -contains "Offline") { Return $False }
    }

    Return $True

} 


Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName

    )

    $ClusterGroup = Get-ClusterGroup -Name $GroupName
    $ClusterGroup | Get-ClusterResource | % { $_ | Start-ClusterResource -ErrorAction SilentlyContinue }
    
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName

    )

    Return Get-TargetResource @PSBoundParameters
}

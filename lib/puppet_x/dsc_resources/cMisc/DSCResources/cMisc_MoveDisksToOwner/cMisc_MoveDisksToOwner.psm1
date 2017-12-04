Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName

    )

    $Group = Get-ClusterGroup -Name $GroupName -ErrorAction SilentlyContinue
    If ($Group -eq $Null) { Throw "$GroupName could not be found" }
    $CurrentOwner = $Group.OwnerNode.NodeName
    $Disks = Get-ClusterResource | Where ResourceType -eq 'Physical Disk' | Where OwnerGroup -eq $GroupName
    $Quorum = (Get-ClusterQuorum -ErrorAction SilentlyContinue).QuorumResource
    Foreach ($Disk in @($Disks , $Quorum)) { If ($Disk.OwnerGroup.OwnerNode.Name -ne $CurrentOwner) { Return $False } }
    Return $True
} 


Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName

    )

    $Group = Get-ClusterGroup -Name $GroupName
    $CurrentOwner = $Group.OwnerNode.NodeName

    cluster group "cluster group" /move:$CurrentOwner
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName

    )

    Return Get-TargetResource @PSBoundParameters
}

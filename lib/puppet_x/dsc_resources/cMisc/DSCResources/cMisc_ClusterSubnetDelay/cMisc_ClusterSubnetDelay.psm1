Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateRange(1000,2000)]
        [Uint32]$SameSubnet,

        [Parameter(Mandatory=$True)]
        [ValidateRange(1000,4000)]
        [Uint32]$CrossSubnet

    )

    $Cluster = Get-Cluster -Verbose:$False


    If (($Cluster.CrossSubnetDelay -ne $CrossSubnet) -or ($Cluster.SameSubnetDelay -ne $SameSubnet)) { $DesiredState = $False }
    Else { $DesiredState = $True }

    Return @{
        DesiredState = $DesiredState
        Cluster = $Cluster
    }
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateRange(1000,2000)]
        [Uint32]$SameSubnet,

        [Parameter(Mandatory=$True)]
        [ValidateRange(1000,4000)]
        [Uint32]$CrossSubnet

    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    If ($CurrentState.Cluster.CurrentSameSubnet -ne $SameSubnet) { 
        Write-Verbose "Setting SameSubnetDelay to $SameSubnet"
        $CurrentState.Cluster.SameSubnetDelay = $SameSubnet
    }
    
    If ($CurrentState.Cluster.CurrentCrossSubnet -ne $CrossSubnet) { 
        Write-Verbose "Setting CrossSubnetDelay to $CrossSubnet"
        $CurrentState.Cluster.CrossSubnetDelay = $CrossSubnet 
    }
}

Function Test-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateRange(1000,2000)]
        [Uint32]$SameSubnet,

        [Parameter(Mandatory=$True)]
        [ValidateRange(1000,4000)]
        [Uint32]$CrossSubnet

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}

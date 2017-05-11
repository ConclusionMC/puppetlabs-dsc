Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [uint32]$RefreshPeriod,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $CurrentRefreshPeriod = (WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'Automatic Refresh Policy' -Context 0,1
    $CurrentRefreshPeriod = [int]((($CurrentRefreshPeriod.Context.PostContext | Select-String -Pattern 'period') -split ': ')[1] -split ' ')[0]

    If ($CurrentRefreshPeriod -ne $RefreshPeriod) { $DesiredState = $False }
    Else { $DesiredState = $True }


    Return @{
        RefreshPeriod  = $RefreshPeriod
        DesiredState   = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [uint32]$RefreshPeriod,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    WdsUtil /Set-Server /Server:Localhost /RefreshPeriod:$RefreshPeriod

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [uint32]$RefreshPeriod,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $CurrentRefreshPeriod = (WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'Automatic Refresh Policy' -Context 0,1
    $CurrentRefreshPeriod = [int]((($CurrentRefreshPeriod.Context.PostContext | Select-String -Pattern 'period') -split ': ')[1] -split ' ')[0]

    If ($CurrentRefreshPeriod -ne $RefreshPeriod) { Return $False }

    Return $True 

}
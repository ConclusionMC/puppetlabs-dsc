Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [uint32]$RefreshPeriod,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BcdRefreshPolicy = $WdsConfig | Select-String -Pattern 'BCD Refresh Policy' -Context 0,2

    $CurrentRefreshPeriod = [uint32]((($BcdRefreshPolicy.Context.PostContext | Select-String -Pattern 'Refresh period') -split ': ')[1] -split ' ')[0]
    If ($CurrentRefreshPeriod -ne $RefreshPeriod) { $DesiredState = $False }

    $CurrentlyEnabled = (($BcdRefreshPolicy.Context.PostContext | Select-String -Pattern 'Enabled') -split ': ')[1].Trim()
    If ($CurrentlyEnabled -ne $Enabled) { $DesiredState = $False }

    Return @{
        RefreshPeriod  = $RefreshPeriod
        Enabled        = $Enabled
        DesiredState   = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [uint32]$RefreshPeriod,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BcdRefreshPolicy = $WdsConfig | Select-String -Pattern 'BCD Refresh Policy' -Context 0,2

    $CurrentRefreshPeriod = [uint32]((($BcdRefreshPolicy.Context.PostContext | Select-String -Pattern 'Refresh period') -split ': ')[1] -split ' ')[0]
    If ($CurrentRefreshPeriod -ne $RefreshPeriod) { WdsUtil /Set-Server /Server:Localhost /BcdRefreshPolicy /RefreshPeriod:$RefreshPeriod }

    $CurrentlyEnabled = (($BcdRefreshPolicy.Context.PostContext | Select-String -Pattern 'Enabled') -split ': ')[1].Trim()
    If ($CurrentlyEnabled -ne $Enabled) { WdsUtil /Set-Server /Server:Localhost /BcdRefreshPolicy /Enabled:$Enabled }

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [uint32]$RefreshPeriod,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BcdRefreshPolicy = $WdsConfig | Select-String -Pattern 'BCD Refresh Policy' -Context 0,2

    $CurrentRefreshPeriod = [uint32]((($BcdRefreshPolicy.Context.PostContext | Select-String -Pattern 'Refresh period') -split ': ')[1] -split ' ')[0]
    If ($CurrentRefreshPeriod -ne $RefreshPeriod) { Return $False }

    $CurrentlyEnabled = (($BcdRefreshPolicy.Context.PostContext | Select-String -Pattern 'Enabled') -split ': ')[1].Trim()
    If ($CurrentlyEnabled -ne $Enabled) { Return $False }

    Return $True 

}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$ResetBootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BootProgramPolicy = $WdsConfig | Select-String -Pattern 'Boot program policy' -Context 0,4
    $CurrentResetBootProgram = (($BootProgramPolicy.Context.PostContext | Select-String -Pattern 'Reset boot program') -split ': ')[1].Trim()

    $Hash = @{ 'Yes' = 'Enabled' ; 'No' = 'Disabled' }
    If ($CurrentResetBootProgram -ne $Hash[$ResetBootProgram]) { $DesiredState = $False }
    Else { $DesiredState = $True }


    Return @{
        ResetBootProgram  = $ResetBootProgram
        DesiredState      = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$ResetBootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    WdsUtil /Set-Server /Server:Localhost /ResetBootProgram:$ResetBootProgram

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$ResetBootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BootProgramPolicy = $WdsConfig | Select-String -Pattern 'Boot program policy' -Context 0,4
    $CurrentResetBootProgram = (($BootProgramPolicy.Context.PostContext | Select-String -Pattern 'Reset boot program') -split ': ')[1].Trim()

    $Hash = @{ 'Yes' = 'Enabled' ; 'No' = 'Disabled' }
    If ($CurrentResetBootProgram -ne $Hash[$ResetBootProgram]) { Return $False }
    Else { Return $True }

}
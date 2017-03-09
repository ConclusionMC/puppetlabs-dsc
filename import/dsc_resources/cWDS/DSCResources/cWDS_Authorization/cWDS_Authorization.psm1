Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Authorization,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Hash = @{ 'Yes' = 'authorized' ; 'No'  = 'not authorized' }

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $AuthorizationState = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'Server Authorization:' -Context 0,1

    $CurrentAuthorization = [string](($AuthorizationState.Context.PostContext | Select-String -Pattern 'authorization state') -split 'state: ')[1].Trim()
    $DesiredAuthorization = $Hash[$Authorization]


    If ($CurrentAuthorization -eq $DesiredAuthorization) { $DesiredState = $True }
    Else { $DesiredState = $False }
    
    Return @{
        Authorization = $KnownClients
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Authorization,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($Authorization -eq 'Yes') { Wdsutil /Set-Server /Server:Localhost /Authorize:Yes }
    Elseif ($Authorization -eq 'No') { Wdsutil /Set-Server /Server:Localhost /Authorize:No }

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Authorization,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Hash = @{ 'Yes' = 'authorized' ; 'No'  = 'not authorized' }

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $AuthorizationState = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'Server Authorization:' -Context 0,1

    $CurrentAuthorization = [string](($AuthorizationState.Context.PostContext | Select-String -Pattern 'authorization state') -split 'state: ')[1].Trim()
    $DesiredAuthorization = $Hash[$Authorization]


    If ($CurrentAuthorization -eq $DesiredAuthorization) { Return $True }
    Else { Return $False }   

}
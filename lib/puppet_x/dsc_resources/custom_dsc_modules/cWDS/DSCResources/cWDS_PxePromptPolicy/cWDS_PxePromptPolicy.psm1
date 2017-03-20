Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("OptIn", "OptOut", "NoPrompt")]
        [string]$KnownClients,
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("OptIn", "OptOut", "NoPrompt")]
        [string]$NewClients,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $PxePromptPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'boot program policy:' -Context 0,2

    $CurrentKnownClients = [string](($PxePromptPolicy.Context.PostContext | Select-String -Pattern 'known client') -split 'policy: ')[1].Trim()
    $CurrentNewClients = [string](($PxePromptPolicy.Context.PostContext | Select-String -Pattern 'new client') -split 'policy: ')[1].Trim()


    If (($KnownClients.ToLower() -ne $CurrentKnownClients) -OR ($NewClients.ToLower() -ne $CurrentNewClients)) { $DesiredState = $False }
    Else { $DesiredState = $True } 
    
    Return @{
        KnownClients  = $KnownClients
        NewClients    = $NewClients
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("OptIn", "OptOut", "NoPrompt")]
        [string]$KnownClients,
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("OptIn", "OptOut", "NoPrompt")]
        [string]$NewClients,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $PxePromptPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'boot program policy:' -Context 0,2

    $CurrentKnownClients = [string](($PxePromptPolicy.Context.PostContext | Select-String -Pattern 'known client') -split 'policy: ')[1].Trim()
    $CurrentNewClients = [string](($PxePromptPolicy.Context.PostContext | Select-String -Pattern 'new client') -split 'policy: ')[1].Trim()

    If ($KnownClients.ToLower() -ne $CurrentKnownClients) { Wdsutil /Set-Server /Server:Localhost /PxePromptPolicy /Known:$KnownClients }
    If ($NewClients.ToLower() -ne $CurrentNewClients) { Wdsutil /Set-Server /Server:Localhost /PxePromptPolicy /New:$NewClients }

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("OptIn", "OptOut", "NoPrompt")]
        [string]$KnownClients,
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("OptIn", "OptOut", "NoPrompt")]
        [string]$NewClients,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $PxePromptPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'boot program policy:' -Context 0,2

    $CurrentKnownClients = [string](($PxePromptPolicy.Context.PostContext | Select-String -Pattern 'known client') -split 'policy: ')[1].Trim()
    $CurrentNewClients = [string](($PxePromptPolicy.Context.PostContext | Select-String -Pattern 'new client') -split 'policy: ')[1].Trim()

    If (($KnownClients.ToLower() -ne $CurrentKnownClients) -OR ($NewClients.ToLower() -ne $CurrentNewClients)) { Return $False }
    Else { Return $True } 

}
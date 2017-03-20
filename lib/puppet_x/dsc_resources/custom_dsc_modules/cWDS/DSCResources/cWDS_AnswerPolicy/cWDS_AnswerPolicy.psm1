Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("All", "Known", "None")]
        [string]$AnswerClients,

        [Parameter(Mandatory=$True)]
        [uint32]$ResponseDelay,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $AnswerPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'answer policy:' -Context 0,3

    $CurrentAnswerClients = [string](($AnswerPolicy.Context.PostContext | Select-String -Pattern 'answer clients') -split 'answer clients: ')[1].Trim()
    $CurrentOnlyKnownClients = [string](($AnswerPolicy.Context.PostContext | Select-String -Pattern 'answer only known clients') -split 'answer only known clients: ')[1].Trim()
    $CurrentResponseDelay = [uint32]((($AnswerPolicy.Context.PostContext | Select-String -Pattern 'response delay') -split 'response delay: ')[1] -split " ")[0].Trim()

    If ($AnswerClients -eq 'All') {
        If (($CurrentAnswerClients -eq 'yes') -AND ($CurrentOnlyKnownClients -eq 'no')) { $DesiredState = $True }
        Else { $DesiredState = $False }
    }
    Elseif ($AnswerClients -eq 'Known') {
        If (($CurrentAnswerClients -eq 'yes') -AND ($CurrentOnlyKnownClients -eq 'yes')) { $DesiredState = $True }
        Else { $DesiredState = $False }
    }
    Elseif ($AnswerClients -eq 'None') {
        If ($CurrentAnswerClients -eq 'no') { $DesiredState = $True }
        Else { $DesiredState = $False }
    }
    
    If ($CurrentResponseDelay -ne $ResponseDelay) { $DesiredState = $False }
    
    Return @{
        AnswerClients  = $AnswerClients
        ResponseDelay  = $ResponseDelay
        DesiredState   = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("All", "Known", "None")]
        [string]$AnswerClients,

        [Parameter(Mandatory=$True)]
        [uint32]$ResponseDelay,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $AnswerPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'answer policy:' -Context 0,3

    $CurrentAnswerClients = [string](($AnswerPolicy.Context.PostContext | Select-String -Pattern 'answer clients') -split 'answer clients: ')[1].Trim()
    $CurrentOnlyKnownClients = [string](($AnswerPolicy.Context.PostContext | Select-String -Pattern 'answer only known clients') -split 'answer only known clients: ')[1].Trim()
    $CurrentResponseDelay = [uint32]((($AnswerPolicy.Context.PostContext | Select-String -Pattern 'response delay') -split 'response delay: ')[1] -split " ")[0].Trim()

    If ($AnswerClients -eq 'All') {
        If (($CurrentAnswerClients -ne 'yes') -OR ($CurrentOnlyKnownClients -ne 'no')) { Wdsutil /Set-Server /Server:Localhost /AnswerClients:All }
    }
    Elseif ($AnswerClients -eq 'Known') {
        If (($CurrentAnswerClients -ne 'yes') -OR ($CurrentOnlyKnownClients -ne 'yes')) { Wdsutil /Set-Server /Server:Localhost /AnswerClients:Known }
    }
    Elseif ($AnswerClients -eq 'None') {
        If ($CurrentAnswerClients -ne 'no') { Wdsutil /Set-Server /Server:Localhost /AnswerClients:None }
    }
    
    If ($CurrentResponseDelay -ne $ResponseDelay) { Wdsutil /Set-Server /Server:Localhost /ResponseDelay:$ResponseDelay }
    
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("All", "Known", "None")]
        [string]$AnswerClients,

        [Parameter(Mandatory=$True)]
        [uint32]$ResponseDelay,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $AnswerPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'answer policy:' -Context 0,3

    $CurrentAnswerClients = [string](($AnswerPolicy.Context.PostContext | Select-String -Pattern 'answer clients') -split 'answer clients: ')[1].Trim()
    $CurrentOnlyKnownClients = [string](($AnswerPolicy.Context.PostContext | Select-String -Pattern 'answer only known clients') -split 'answer only known clients: ')[1].Trim()
    $CurrentResponseDelay = [uint32]((($AnswerPolicy.Context.PostContext | Select-String -Pattern 'response delay') -split 'response delay: ')[1] -split " ")[0].Trim()

    If ($AnswerClients -eq 'All') {
        If (($CurrentAnswerClients -ne 'yes') -OR ($CurrentOnlyKnownClients -ne 'no')) { Return $False }
    }
    Elseif ($AnswerClients -eq 'Known') {
        If (($CurrentAnswerClients -ne 'yes') -OR ($CurrentOnlyKnownClients -ne 'yes')) { Return $False }
    }
    Elseif ($AnswerClients -eq 'None') {
        If ($CurrentAnswerClients -ne 'no') { Return $False }
    }
    
    If ($CurrentResponseDelay -ne $ResponseDelay) { Return $False }
    
    Return $True 

}
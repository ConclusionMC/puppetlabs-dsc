Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchString,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ExecuteParameter,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    $Config = (wdsutil /get-server /server:localhost /show:config) 

    $SearchResult = $Config | Select-string -Pattern $SearchString -SimpleMatch
    If ($SearchResult -eq $Null) { $DesiredState = $False }

    Return @{
        ConfigurationName = $ConfigurationName
        ConfigHash = $ConfigHash
        DesiredState = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchString,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ExecuteParameter,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Invoke-Expression -command "wdsutil.exe /set-server $ExecuteParameter"

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$SearchString,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ExecuteParameter,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $Config = (wdsutil /get-server /server:localhost /show:config) 
    $SearchResult = $Config | Select-string -Pattern $SearchString -SimpleMatch
        
    If ($SearchResult -eq $Null) { Return $False }   
    Else { Return $True }
    
}
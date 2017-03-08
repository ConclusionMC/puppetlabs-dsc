Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance[]]$ConfigHash,


        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    $Config = (wdsutil /get-server /server:localhost /show:config) 

    Foreach($SearchString in $ConfigHash){            
        $SearchResult = $Config | Select-string -Pattern $SearchString.Key -SimpleMatch
        if ($SearchResult -eq $Null) { $DesiredState = $False }    
    }

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
        [Microsoft.Management.Infrastructure.CimInstance[]]$ConfigHash,


        [Parameter(Mandatory=$False)]
        [bool]$DesiredState
    )

    $Config = (wdsutil /get-server /server:localhost /show:config) 

    Foreach($SearchString in $ConfigHash){
            
        $SearchResult = $Config | Select-string -Pattern $SearchString.Key -SimpleMatch
        if ($SearchResult -eq $Null) { $Parameter = $SearchString.Value ; Invoke-Expression -command "wdsutil.exe /set-server $Parameter" }
    
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConfigurationName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Management.Infrastructure.CimInstance[]]$ConfigHash,


        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $Config = (wdsutil /get-server /server:localhost /show:config) 

    Foreach($SearchString in $ConfigHash){            
        $SearchResult = $Config | Select-string -Pattern $SearchString.Key -SimpleMatch
        If ($SearchResult -eq $Null) { Return $False }    
    }            

    Return $True
}
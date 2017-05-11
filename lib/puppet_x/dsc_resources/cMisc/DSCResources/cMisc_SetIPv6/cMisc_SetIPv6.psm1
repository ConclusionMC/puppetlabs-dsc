Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InterfaceAlias,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$State,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $RequiredState = If ($State -eq 'Enabled') { $True } Else { $False }
    $CurrentState = (Get-NetAdapterBinding -Name $InterfaceAlias -ComponentID 'ms_tcpip6').Enabled
    If ($CurrentState -ne $RequiredState) { $DesiredState = $False }
    Else { $DesiredState = $True }    

    Return @{  
        InterfaceAlias = $InterfaceAlias
        State          = $State
        DesiredState   = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InterfaceAlias,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$State,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($State -eq 'Enabled') { Enable-NetAdapterBinding -Name $InterfaceAlias -ComponentID 'ms_tcpip6' }
    Else { Disable-NetAdapterBinding -Name $InterfaceAlias -ComponentID 'ms_tcpip6' }

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InterfaceAlias,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$State,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $RequiredState = If ($State -eq 'Enabled') { $True } Else { $False }
    $CurrentState = (Get-NetAdapterBinding -Name $InterfaceAlias -ComponentID 'ms_tcpip6').Enabled
    If ($CurrentState -ne $RequiredState) { Return $False }
    Else { Return $True }    
}
Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Server','Scope','Reservation')]
        [string]$Level,

        [Parameter(Mandatory=$False)]
        [boolean]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_3,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_12,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Option_6,  

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_15,  
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_66,   
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_67,                  

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,  
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ReservedIP,  

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    $Parameters = @{}

    If ($Level -eq 'Scope') {        
        $ScopeID = (Get-DhcpServerv4Scope | Where Name -eq $ScopeName).ScopeId.IPAddressToString
        $Parameters.Add('ScopeId',$ScopeID)
    }
    If ($Level -eq 'Reservation') {
        $Parameters.Add('ReservedIP',$ReservedIP)
    }

    $RequiredOptions = @()
    $SupportedOptions = 3,6,12,15,66,67
    $SupportedOptions | % { If ($PSBoundParameters.ContainsKey("Option_$_")) { $RequiredOptions += $_ } }
    $CurrentValues = @()
    
    Foreach ($Option in $RequiredOptions) {
        $State = $True
        
        $CurrentValue = (Get-DhcpServerv4OptionValue @Parameters -OptionId $Option -ErrorAction SilentlyContinue).Value
        $RequiredValue = (Get-Variable -Name "Option_$Option").Value
        
        If ($CurrentValue -eq $Null) { $CurrentValue = 'NotSet' ; $State = $False }
        Elseif ($RequiredValue -is [array]) {
            $Comparison = Compare-Object -ReferenceObject $RequiredValue -DifferenceObject $CurrentValue
            If ($Comparison -ne $Null) { $State = $False }
        }
        Elseif ($RequiredValue -ne $CurrentValue) { $State = $False }
        
        $CurrentValues += New-Object -TypeName PsObject -Property @{ 
            OptionId = $Option
            CurrentValue = $CurrentValue
            RequiredValue = $RequiredValue
            DesiredState = $State 
        } 
    }    
    
    If ($Purge -eq $True) {        
        $CurrentOptions = (Get-DhcpServerv4OptionValue @Parameters | Where OptionId -in $SupportedOptions).OptionId
        $ToRemove = (Compare-Object -ReferenceObject $CurrentOptions -DifferenceObject $RequiredOptions | Where SideIndicator -eq '<=').InputObject        
    }

    If (($CurrentValues | Where DesiredState -eq $False) -ne $Null) { $DesiredState = $False }
    Elseif ($Purge -eq $True -and $ToRemove -ne $Null) { $DesiredState = $False }

    Return @{
        SupportedOptions = $SupportedOptions
        RequiredOptions = $RequiredOptions
        CurrentValues = $CurrentValues
        RemoveOptions = $ToRemove
        Parameters = $Parameters
        DesiredState = $DesiredState
    }    
}

Function Set-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Server','Scope','Reservation')]
        [string]$Level,

        [Parameter(Mandatory=$False)]
        [boolean]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_3,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_12,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Option_6,  

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_15,  
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_66,   
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_67,                  

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,  
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ReservedIP,  

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    $Parameters = $CurrentState.Parameters
    Foreach ($Option in ($CurrentState.CurrentValues | Where DesiredState -eq $False)) {
        Set-DhcpServerv4OptionValue @Parameters -OptionId $Option.OptionId -Value $Option.RequiredValue -Force
    }

    If ($CurrentState.RemoveOptions -ne $Null) { $CurrentState.RemoveOptions | % { Remove-DhcpServerv4OptionValue @Parameters -OptionId $_ } }
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateSet('Server','Scope','Reservation')]
        [string]$Level,

        [Parameter(Mandatory=$False)]
        [boolean]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_3,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_12,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Option_6,  

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_15,  
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_66,   
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_67,                  

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,  
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ReservedIP,  

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
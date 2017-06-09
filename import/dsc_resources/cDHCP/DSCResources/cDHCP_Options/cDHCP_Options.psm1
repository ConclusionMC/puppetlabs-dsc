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
        [bool]$DesiredState

    )

    $DesiredState = $True
    $Parameters = @{}

    If ($Level -eq 'Scope') {  
        
        $ScopeID = (Get-DhcpServerv4Scope | Where Name -eq $ScopeName).ScopeId.IPAddressToString
        $Parameters.Add('ScopeId',$ScopeID)
    }

    If ($Level -eq 'Reservation') { 

        $Parameters.Add('ReservedIP',$ReservedIP)
    }

    $SetOptions = @()
    $Options = 3,6,15,66,67
    $Options | % { If ($PSBoundParameters.ContainsKey("Option_$_")) { $SetOptions += $_ } }
    
    $SetOptions | % {
        
        $CurrentValue = (Get-DhcpServerv4OptionValue @Parameters -OptionId $_ -ErrorAction SilentlyContinue).Value
        $RequiredValue = (Get-Variable -Name "Option_$_").Value
        $IsSet = !([string]::IsNullOrEmpty($CurrentValue)) 
        If (($IsSet -eq $True -AND $RequiredValue -ne $CurrentValue) -OR $IsSet -eq $False) { $DesiredState = $False }
    }
    
    If ($Purge -eq $True) {
        
        $CurrentSetOptions = (Get-DhcpServerv4OptionValue @Parameters | Where OptionId -in $Options).OptionId
        $ToRemove = (Compare-Object -ReferenceObject $CurrentSetOptions -DifferenceObject $SetOptions | Where SideIndicator -eq '<=').InputObject        
        If ($ToRemove -ne $Null) { $DesiredState = $False }
    }

    Return @{
        Name           = $Name 
        Level          = $Level
        Purge          = $Purge
        Option_3       = $Option_3
        Option_6       = $Option_6
        Option_15      = $Option_15
        Option_66      = $Option_66
        Option_67      = $Option_67
        ScopeName      = $ScopeName
        ReservedIP     = $ReservedIP
        DesiredState   = $DesiredState
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
        [bool]$DesiredState

    )

    $Parameters = @{}

    If ($Level -eq 'Scope') {  
        $ScopeID = (Get-DhcpServerv4Scope | Where Name -eq $ScopeName).ScopeId.IPAddressToString
        $Parameters.Add('ScopeId',$ScopeID)
    }

    If ($Level -eq 'Reservation') { 
        $Parameters.Add('ReservedIP',$ReservedIP)
    }

    $SetOptions = @()
    $Options = 3,6,15,66,67
    $Options | % { If ($PSBoundParameters.ContainsKey("Option_$_")) { $SetOptions += $_ } }

    Foreach ($Option in $SetOptions) {
        $CurrentValue = (Get-DhcpServerv4OptionValue @Parameters -OptionId $Option -ErrorAction SilentlyContinue).Value
        $RequiredValue = (Get-Variable -Name "Option_$Option").Value
        $IsSet = !([string]::IsNullOrEmpty($CurrentValue))
        If ($IsSet -eq $True -and $RequiredValue -is [array]) {
            $Comparison = Compare-Object -ReferenceObject $RequiredValue -DifferenceObject $CurrentValue
            If ($Comparison -ne $Null) { Set-DhcpServerv4OptionValue @Parameters -OptionId $Option -Value $RequiredValue -Force }
        }
        Elseif ($RequiredValue -ne $CurrentValue -or $IsSet -eq $False) { Set-DhcpServerv4OptionValue @Parameters -OptionId $Option -Value $RequiredValue }
    }    
    
    If ($Purge -eq $True) {
        $CurrentSetOptions = (Get-DhcpServerv4OptionValue @Parameters | Where OptionId -in $Options).OptionId
        $ToRemove = (Compare-Object -ReferenceObject $CurrentSetOptions -DifferenceObject $SetOptions | Where SideIndicator -eq '<=').InputObject        
        If ($ToRemove -ne $Null) { $ToRemove | % { Remove-DhcpServerv4OptionValue @Parameters -OptionId $_ } }
    }    
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
        [bool]$DesiredState

    )

    $Parameters = @{}

    If ($Level -eq 'Scope') {  
        $ScopeID = (Get-DhcpServerv4Scope | Where Name -eq $ScopeName).ScopeId.IPAddressToString
        $Parameters.Add('ScopeId',$ScopeID)
    }

    If ($Level -eq 'Reservation') { 
        $Parameters.Add('ReservedIP',$ReservedIP)
    }

    $SetOptions = @()
    $Options = 3,6,15,66,67
    $Options | % { If ($PSBoundParameters.ContainsKey("Option_$_")) { $SetOptions += $_ } }

    Foreach ($Option in $SetOptions) {
        $CurrentValue = (Get-DhcpServerv4OptionValue @Parameters -OptionId $Option -ErrorAction SilentlyContinue).Value
        $RequiredValue = (Get-Variable -Name "Option_$Option").Value
        $IsSet = !([string]::IsNullOrEmpty($CurrentValue))
        If ($IsSet -eq $True -and $RequiredValue -is [array]) {
            $Comparison = Compare-Object -ReferenceObject $RequiredValue -DifferenceObject $CurrentValue
            If ($Comparison -ne $Null) { Return $False }
        }
        Elseif ($RequiredValue -ne $CurrentValue -or $IsSet -eq $False) { Return $False }
    }    
    
    If ($Purge -eq $True) {
        $CurrentSetOptions = (Get-DhcpServerv4OptionValue @Parameters | Where OptionId -in $Options).OptionId
        $ToRemove = (Compare-Object -ReferenceObject $CurrentSetOptions -DifferenceObject $SetOptions | Where SideIndicator -eq '<=').InputObject        
        If ($ToRemove -ne $Null) { Return $False }
    }    

    Return $True
}
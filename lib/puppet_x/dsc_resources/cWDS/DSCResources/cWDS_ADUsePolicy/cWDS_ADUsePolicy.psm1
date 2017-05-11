Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$NewMachineDomainJoin,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$PrestageUsingMAC,

        [Parameter(Mandatory=$False)]
        [ValidateSet("GCOnly", "DCFirst")]
        [string]$DomainSearchOrder,

        [Parameter(Mandatory=$False)]
        [ValidateSet("ServerDomain", "UserDomain", "UserOU", "Custom")]
        [string]$NewMachineOUType,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$PreferredDC,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$PreferredGC,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MachineNamingPolicy,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NewMachineOU,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WDSConfig = WdsUtil /Get-Server /Show:Config

    $ADUsePolicy = $WDSConfig | Select-String -Pattern 'Active Directory Use Policy' -Context 0,10

    $CurrentNewMachineDomainJoin = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'join domain') -split ': ')[1].Trim()
    If ($CurrentNewMachineDomainJoin -ne $NewMachineDomainJoin) { $DesiredState = $False }

    If ($PSBoundParameters.ContainsKey('PreferredDC')) {
        $CurrentPreferredDC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'Preferred DC') -split ': ')[1].Trim()
        If (([string]::IsNullOrEmpty($CurrentPreferredDC))) { $CurrentPreferredDC = 'Unset' }
        If ($CurrentPreferredDC -cne $PreferredDC) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('PreferredGC')) {
        $CurrentPreferredGC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'Preferred GC') -split ': ')[1].Trim()
        If (([string]::IsNullOrEmpty($CurrentPreferredGC))) { $CurrentPreferredGC = 'Unset' }
        If ($CurrentPreferredGC -cne $PreferredGC) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('PrestageUsingMAC')) {
        $CurrentPrestageUsingMAC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'using MAC') -split ': ')[1].Trim()
        If ($CurrentPrestageUsingMAC -ne $PrestageUsingMAC) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('MachineNamingPolicy')) {
        $CurrentMachineNamingPolicy = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'naming policy') -split ': ')[1].Trim()
        If ($CurrentMachineNamingPolicy -cne $MachineNamingPolicy) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('DomainSearchOrder')) {
        $Hash = @{ 'GCOnly' = 'Global Catalog Only' ; 'DCFirst' = 'Domain Controller First' }
        $CurrentDomainSearchOrder = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'search order') -split ': ')[1].Trim()
        If ($CurrentDomainSearchOrder -ne $Hash[$DomainSearchOrder]) { $DesiredState = $False  }
    }

    If ($PSBoundParameters.ContainsKey('NewMachineOUType') -OR $PSBoundParameters.ContainsKey('NewMachineOU')){

        $CurrentNewMachineOUType = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'OU type') -split ': ')[1].Trim()
        $CurrentNewMachineOU = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'OU: ') -split ': ')[1].Trim()

        If ($PSBoundParameters.ContainsKey('NewMachineOUType') -AND ($PSBoundParameters.ContainsKey('NewMachineOU') -eq $False)){
            If ($NewMachineOUType -ne $CurrentNewMachineOUType) { $DesiredState = $False }
        }

        If (($PSBoundParameters.ContainsKey('NewMachineOUType') -eq $False) -AND $PSBoundParameters.ContainsKey('NewMachineOU')){     
            If ($CurrentNewMachineOU -ne $NewMachineOU) { $DesiredState = $False }      
        }

        If ($PSBoundParameters.ContainsKey('NewMachineOUType') -AND $PSBoundParameters.ContainsKey('NewMachineOU')){

            If ($CurrentNewMachineOUType -ne $NewMachineOUType) { $DesiredState = $False }
            Elseif ($CurrentNewMachineOU -ne $NewMachineOU) { $DesiredState = $False }
        }
    }
   
    Return @{  
        NewMachineDomainJoin = $NewMachineDomainJoin
        PrestageUsingMAC = $PrestageUsingMAC
        DomainSearchOrder = $DomainSearchOrder
        NewMachineOUType = $NewMachineOUType
        PreferredDC = $PreferredDC
        PreferredGC = $PreferredGC
        MachineNamingPolicy = $MachineNamingPolicy
        NewMachineOU = $NewMachineOU
        DesiredState       = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$NewMachineDomainJoin,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$PrestageUsingMAC,

        [Parameter(Mandatory=$False)]
        [ValidateSet("GCOnly", "DCFirst")]
        [string]$DomainSearchOrder,

        [Parameter(Mandatory=$False)]
        [ValidateSet("ServerDomain", "UserDomain", "UserOU", "Custom")]
        [string]$NewMachineOUType,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$PreferredDC,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$PreferredGC,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MachineNamingPolicy,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NewMachineOU,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = WdsUtil /Get-Server /Show:Config

    $ADUsePolicy = $WDSConfig | Select-String -Pattern 'Active Directory Use Policy' -Context 0,10

    $CurrentNewMachineDomainJoin = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'join domain') -split ': ')[1].Trim()
    If ($CurrentNewMachineDomainJoin -ne $NewMachineDomainJoin) { WdsUtil /Set-Server /Server:Localhost /NewMachineDomainJoin:$NewMachineDomainJoin }

    If ($PSBoundParameters.ContainsKey('PreferredDC')) {
        $CurrentPreferredDC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'Preferred DC') -split ': ')[1].Trim()
        If (([string]::IsNullOrEmpty($CurrentPreferredDC))) { $CurrentPreferredDC = 'Unset' }

        If ($CurrentPreferredDC -cne $PreferredDC) {
            If ($PreferredDC -eq 'Unset') { WdsUtil /Set-Server /Server:Localhost /PreferredDC: }
            Else { WdsUtil /Set-Server /Server:Localhost /PreferredDC:$PreferredDC }
        }
    }

    If ($PSBoundParameters.ContainsKey('PreferredGC')) {
        $CurrentPreferredGC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'Preferred GC') -split ': ')[1].Trim()
        If (([string]::IsNullOrEmpty($CurrentPreferredGC))) { $CurrentPreferredGC = 'Unset' }

        If ($CurrentPreferredGC -cne $PreferredGC) {
            If ($PreferredGC -eq 'Unset') { WdsUtil /Set-Server /Server:Localhost /PreferredGC: }
            Else { WdsUtil /Set-Server /Server:Localhost /PreferredGC:$PreferredGC }
        }
    }

    If ($PSBoundParameters.ContainsKey('PrestageUsingMAC')) {
        $CurrentPrestageUsingMAC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'using MAC') -split ': ')[1].Trim()
        If ($CurrentPrestageUsingMAC -ne $PrestageUsingMAC) { WdsUtil /Set-Server /Server:Localhost /PrestageUsingMAC:$PrestageUsingMAC }
    }

    If ($PSBoundParameters.ContainsKey('MachineNamingPolicy')) {
        $CurrentMachineNamingPolicy = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'naming policy') -split ': ')[1].Trim()
        If ($CurrentMachineNamingPolicy -cne $MachineNamingPolicy) { WdsUtil /Set-Server /Server:Localhost /NewMachineNamingPolicy:$MachineNamingPolicy }
    }

    If ($PSBoundParameters.ContainsKey('DomainSearchOrder')) {
        $Hash = @{ 'GCOnly' = 'Global Catalog Only' ; 'DCFirst' = 'Domain Controller First' }
        $CurrentDomainSearchOrder = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'search order') -split ': ')[1].Trim()
        If ($CurrentDomainSearchOrder -ne $Hash[$DomainSearchOrder]) { WdsUtil /Set-Server /Server:Localhost /DomainSearchOrder:$DomainSearchOrder  }
    }

    If ($PSBoundParameters.ContainsKey('NewMachineOUType') -OR $PSBoundParameters.ContainsKey('NewMachineOU')){

        $CurrentNewMachineOUType = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'OU type') -split ': ')[1].Trim()
        $CurrentNewMachineOU = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'OU: ') -split ': ')[1].Trim()

        If ($PSBoundParameters.ContainsKey('NewMachineOUType') -AND ($PSBoundParameters.ContainsKey('NewMachineOU') -eq $False)){
            If ($NewMachineOUType -ne $CurrentNewMachineOUType) {
                If ($NewMachineOUType -eq 'Custom') {
                    If ([string]::IsNullOrEmpty($CurrentNewMachineOU) -eq $True) { Throw 'A new machine OU needs to be supplied.' }
                    Else { WdsUtil /Set-Server /Server:Localhost /NewMachineOU /Type:Custom /OU:"$CurrentNewMachineOU" }
                }
                Else { WdsUtil /Set-Server /Server:Localhost /NewMachineOU /Type:$NewMachineOUType }
            }
        }

        If (($PSBoundParameters.ContainsKey('NewMachineOUType') -eq $False) -AND $PSBoundParameters.ContainsKey('NewMachineOU')){           
          
            If ($CurrentNewMachineOUType -ne 'Custom') { Throw 'The new machine OU type must be set to custom before a new machine OU can be specified.' }
            Elseif ($CurrentNewMachineOU -ne $NewMachineOU) { WdsUtil /Set-Server /Server:Localhost /NewMachineOU /OU:"$NewMachineOU" }      

        }

        If ($PSBoundParameters.ContainsKey('NewMachineOUType') -AND $PSBoundParameters.ContainsKey('NewMachineOU')){

            If ($NewMachineOUType -ne 'Custom') { Throw 'The new machine OU type must be set to custom before a new machine OU can be specified.' }
            Elseif ($CurrentNewMachineOUType -ne $NewMachineOUType) { WdsUtil /Set-Server /Server:Localhost /NewMachineOU /Type:Custom /OU:"$NewMachineOU" }
            Elseif ($CurrentNewMachineOU -ne $NewMachineOU) { WdsUtil /Set-Server /Server:Localhost /NewMachineOU /OU:"$NewMachineOU" }
        }
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$NewMachineDomainJoin,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$PrestageUsingMAC,

        [Parameter(Mandatory=$False)]
        [ValidateSet("GCOnly", "DCFirst")]
        [string]$DomainSearchOrder,

        [Parameter(Mandatory=$False)]
        [ValidateSet("ServerDomain", "UserDomain", "UserOU", "Custom")]
        [string]$NewMachineOUType,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$PreferredDC,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$PreferredGC,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MachineNamingPolicy,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NewMachineOU,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = WdsUtil /Get-Server /Show:Config

    $ADUsePolicy = $WDSConfig | Select-String -Pattern 'Active Directory Use Policy' -Context 0,10

    $CurrentNewMachineDomainJoin = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'join domain') -split ': ')[1].Trim()
    If ($CurrentNewMachineDomainJoin -ne $NewMachineDomainJoin) { Return $False }

    If ($PSBoundParameters.ContainsKey('PreferredDC')) {
        $CurrentPreferredDC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'Preferred DC') -split ': ')[1].Trim()
        If (([string]::IsNullOrEmpty($CurrentPreferredDC))) { $CurrentPreferredDC = 'Unset' }
        If ($CurrentPreferredDC -cne $PreferredDC) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('PreferredGC')) {
        $CurrentPreferredGC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'Preferred GC') -split ': ')[1].Trim()
        If (([string]::IsNullOrEmpty($CurrentPreferredGC))) { $CurrentPreferredGC = 'Unset' }
        If ($CurrentPreferredGC -cne $PreferredGC) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('PrestageUsingMAC')) {
        $CurrentPrestageUsingMAC = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'using MAC') -split ': ')[1].Trim()
        If ($CurrentPrestageUsingMAC -ne $PrestageUsingMAC) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('MachineNamingPolicy')) {
        $CurrentMachineNamingPolicy = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'naming policy') -split ': ')[1].Trim()
        If ($CurrentMachineNamingPolicy -cne $MachineNamingPolicy) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('DomainSearchOrder')) {
        $Hash = @{ 'GCOnly' = 'Global Catalog Only' ; 'DCFirst' = 'Domain Controller First' }
        $CurrentDomainSearchOrder = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'search order') -split ': ')[1].Trim()
        If ($CurrentDomainSearchOrder -ne $Hash[$DomainSearchOrder]) { Return $False  }
    }

    If ($PSBoundParameters.ContainsKey('NewMachineOUType') -OR $PSBoundParameters.ContainsKey('NewMachineOU')){

        $CurrentNewMachineOUType = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'OU type') -split ': ')[1].Trim().Replace(' ','')
        $CurrentNewMachineOU = (($ADUsePolicy.Context.PostContext | Select-String -Pattern 'OU: ') -split ': ')[1].Trim()

        If ($PSBoundParameters.ContainsKey('NewMachineOUType') -AND ($PSBoundParameters.ContainsKey('NewMachineOU') -eq $False)){
            If ($NewMachineOUType -ne $CurrentNewMachineOUType) { Return $False }
        }

        If (($PSBoundParameters.ContainsKey('NewMachineOUType') -eq $False) -AND $PSBoundParameters.ContainsKey('NewMachineOU')){           
            If ($CurrentNewMachineOU -ne $NewMachineOU) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('NewMachineOUType') -AND $PSBoundParameters.ContainsKey('NewMachineOU')){

            If ($CurrentNewMachineOUType -ne $NewMachineOUType) { Return $False }
            Elseif ($CurrentNewMachineOU -ne $NewMachineOU) { Return $False }
        }
    }
    Return $True
}
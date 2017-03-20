Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Dhcp", "Range")]
        [string]$IPv4Source,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv4RangeStart,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv4RangeEnd,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv6RangeStart,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv6RangeEnd,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $IPSettings = $WdsConfig | Select-String -Pattern 'WDS Transport Server Policy' -Context 0,10

    $IPv4Settings = $IPSettings.Context.PostContext | Select-String -Pattern 'IPv4 source' -Context 0,2
    $CurrentIPv4Source = ($IPv4Settings.Line -split ': ')[1].Trim()
    If ($CurrentIPv4Source -ne $IPv4Source) { $DesiredState = $False }

    If ($PSBoundParameters.ContainsKey('IPv4RangeStart')){
        $CurrentRangeStart = (($IPv4Settings.Context.PostContext | Select-String -Pattern 'Start address') -split ': ')[1].Trim()
        If ($CurrentRangeStart -ne $IPv4RangeStart) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('IPv4RangeEnd')){
        $CurrentRangeEnd = (($IPv4Settings.Context.PostContext | Select-String -Pattern 'End address') -split ': ')[1].Trim()
        If ($CurrentRangeEnd -ne $IPv4RangeEnd) { $DesiredState = $False }
    }

    If (($PSBoundParameters.ContainsKey('IPv6RangeStart')) -OR ($PSBoundParameters.ContainsKey('IPv6RangeEnd'))) { $IPv6Settings = $IPSettings.Context.PostContext | Select-String -Pattern 'IPv6 source' -Context 0,2 }

    If ($PSBoundParameters.ContainsKey('IPv6RangeStart')){
        $CurrentRangeStart = (($IPv6Settings.Context.PostContext | Select-String -Pattern 'Start address') -split ': ')[1].Trim()
        If ($CurrentRangeStart -ne $IPv6RangeStart) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('IPv6RangeEnd')){
        $CurrentRangeEnd = (($IPv6Settings.Context.PostContext | Select-String -Pattern 'End address') -split ': ')[1].Trim()
        If ($CurrentRangeEnd -ne $IPv6RangeEnd) { $DesiredState = $False }
    }

    Return @{
        IPv4Source     = $IPv4Source
        IPv4RangeStart = $IPv4RangeStart
        IPv4RangeEnd   = $IPv4RangeEnd
        IPv6RangeStart = $IPv6RangeStart
        IPv6RangeEnd   = $IPv6RangeEnd
        DesiredState   = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Dhcp", "Range")]
        [string]$IPv4Source,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv4RangeStart,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv4RangeEnd,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv6RangeStart,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv6RangeEnd,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ((($PSBoundParameters.ContainsKey('IPv4RangeStart') -eq $False) -OR ` 
         ($PSBoundParameters.ContainsKey('IPv4RangeEnd') -eq $False)) -AND `
         ($IPv4Source -eq 'Range')) { Throw 'If the IPv4 source is set to range the IPv4Range parameters must also be used.' }

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $IPSettings = $WdsConfig | Select-String -Pattern 'WDS Transport Server Policy' -Context 0,10

    $IPv4Settings = $IPSettings.Context.PostContext | Select-String -Pattern 'IPv4 source' -Context 0,2
    $CurrentIPv4Source = ($IPv4Settings.Line -split ': ')[1].Trim()
    If ($CurrentIPv4Source -ne $IPv4Source) {
        If ($IPv4Source -eq 'Range') { 
            $Attempt = WdsUtil /Set-Server /Server:Localhost /Transport /ObtainIpv4From:Range /Start:$IPv4RangeStart /End:$IPv4RangeEnd
            If ($Attempt | Select-String 'Error Code') { Throw ((($Attempt | Select-String 'Error Description').Line -split 'Description: ')[1]) }
        }
        Elseif ($IPv4Source -eq 'Dhcp') { WdsUtil /Set-Server /Server:Localhost /Transport /ObtainIpv4From:Dhcp }
    }

    If ($PSBoundParameters.ContainsKey('IPv4RangeStart')){
        If ($IPv4Source -ne 'Range') { Throw 'The IPv4Range parameters can only be used if if the IPv4Source parameter is set to range.' }
        Elseif ($PSBoundParameters.ContainsKey('IPv4RangeEnd') -eq $False) { Throw 'The IPv4RangeStart parameter must be used in combination with the IPv4RangeEnd parameter.' }
        $CurrentRangeStart = (($IPv4Settings.Context.PostContext | Select-String -Pattern 'Start address') -split ': ')[1].Trim()
        If ($CurrentRangeStart -ne $IPv4RangeStart) {
            $Attempt = WdsUtil /Set-Server /Server:Localhost /Transport /ObtainIpv4From:Range /Start:$IPv4RangeStart /End:$IPv4RangeEnd 
            If ($Attempt | Select-String 'Error Code') { Throw ((($Attempt | Select-String 'Error Description').Line -split 'Description: ')[1]) }
        }
    }

    If ($PSBoundParameters.ContainsKey('IPv4RangeEnd')){
        If ($IPv4Source -ne 'Range') { Throw 'The IPv4Range parameters can only be used if if the IPv4Source parameter is set to range.' }
        Elseif ($PSBoundParameters.ContainsKey('IPv4RangeStart') -eq $False) { Throw 'The IPv4RangeEnd parameter must be used in combination with the IPv4RangeStart parameter.' }
        $CurrentRangeEnd = (($IPv4Settings.Context.PostContext | Select-String -Pattern 'End address') -split ': ')[1].Trim()
        If ($CurrentRangeEnd -ne $IPv4RangeEnd) { 
            $Attempt = WdsUtil /Set-Server /Server:Localhost /Transport /ObtainIpv4From:Range /Start:$IPv4RangeStart /End:$IPv4RangeEnd 
            If ($Attempt | Select-String 'Error Code') { Throw ((($Attempt | Select-String 'Error Description').Line -split 'Description: ')[1]) }
        }
    }

    If (($PSBoundParameters.ContainsKey('IPv6RangeStart')) -OR ($PSBoundParameters.ContainsKey('IPv6RangeEnd'))) { $IPv6Settings = $IPSettings.Context.PostContext | Select-String -Pattern 'IPv6 source' -Context 0,2 }

    If ($PSBoundParameters.ContainsKey('IPv6RangeStart')){
        If ($PSBoundParameters.ContainsKey('IPv6RangeEnd') -eq $False) { Throw 'The IPv6RangeStart parameter must be used in combination with the IPv6RangeEnd parameter.' }
        $CurrentRangeStart = (($IPv6Settings.Context.PostContext | Select-String -Pattern 'Start address') -split ': ')[1].Trim()
        If ($CurrentRangeStart -ne $IPv6RangeStart) {
            $Attempt = WdsUtil /Set-Server /Server:Localhost /Transport /ObtainIpv6From:Range /Start:$IPv6RangeStart /End:$IPv6RangeEnd 
            If ($Attempt | Select-String 'Error Code') { Throw ((($Attempt | Select-String 'Error Description').Line -split 'Description: ')[1]) }
        }
    }

    If ($PSBoundParameters.ContainsKey('IPv6RangeEnd')){
        If ($PSBoundParameters.ContainsKey('IPv6RangeStart') -eq $False) { Throw 'The IPv6RangeEnd parameter must be used in combination with the IPv6RangeStart parameter.' }
        $CurrentRangeEnd = (($IPv6Settings.Context.PostContext | Select-String -Pattern 'End address') -split ': ')[1].Trim()
        If ($CurrentRangeEnd -ne $IPv6RangeEnd) {
            $Attempt = WdsUtil /Set-Server /Server:Localhost /Transport /ObtainIpv6From:Range /Start:$IPv6RangeStart /End:$IPv6RangeEnd 
            If ($Attempt | Select-String 'Error Code') { Throw ((($Attempt | Select-String 'Error Description').Line -split 'Description: ')[1]) }
        }
    }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Dhcp", "Range")]
        [string]$IPv4Source,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv4RangeStart,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv4RangeEnd,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv6RangeStart,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IPv6RangeEnd,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $IPSettings = $WdsConfig | Select-String -Pattern 'WDS Transport Server Policy' -Context 0,10

    $IPv4Settings = $IPSettings.Context.PostContext | Select-String -Pattern 'IPv4 source' -Context 0,2
    $CurrentIPv4Source = ($IPv4Settings.Line -split ': ')[1].Trim()
    If ($CurrentIPv4Source -ne $IPv4Source) { Return $False }

    If ($PSBoundParameters.ContainsKey('IPv4RangeStart')){
        $CurrentRangeStart = (($IPv4Settings.Context.PostContext | Select-String -Pattern 'Start address') -split ': ')[1].Trim()
        If ($CurrentRangeStart -ne $IPv4RangeStart) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('IPv4RangeEnd')){
        $CurrentRangeEnd = (($IPv4Settings.Context.PostContext | Select-String -Pattern 'End address') -split ': ')[1].Trim()
        If ($CurrentRangeEnd -ne $IPv4RangeEnd) { Return $False }
    }

    If (($PSBoundParameters.ContainsKey('IPv6RangeStart')) -OR ($PSBoundParameters.ContainsKey('IPv6RangeEnd'))) { $IPv6Settings = $IPSettings.Context.PostContext | Select-String -Pattern 'IPv6 source' -Context 0,2 }

    If ($PSBoundParameters.ContainsKey('IPv6RangeStart')){
        $CurrentRangeStart = (($IPv6Settings.Context.PostContext | Select-String -Pattern 'Start address') -split ': ')[1].Trim()
        If ($CurrentRangeStart -ne $IPv6RangeStart) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('IPv6RangeEnd')){
        $CurrentRangeEnd = (($IPv6Settings.Context.PostContext | Select-String -Pattern 'End address') -split ': ')[1].Trim()
        If ($CurrentRangeEnd -ne $IPv6RangeEnd) { Return $False }
    }

    Return $True 

}
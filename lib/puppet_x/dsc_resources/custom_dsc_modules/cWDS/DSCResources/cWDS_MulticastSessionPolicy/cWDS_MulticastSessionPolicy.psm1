Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("None", "AutoDisconnect", "Multistream")]
        [string]$Policy,

        [Parameter(Mandatory=$False)]
        [uint32]$AutoDC_Threshold,

        [Parameter(Mandatory=$False)]
        [ValidateSet(2,3)]       
        [uint32]$StreamCount,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]       
        [string]$Fallback,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $MulticastPolicy = $WdsConfig | Select-String -Pattern 'Multicast session policy' -Context 0,4

    $CurrentPolicy = (($MulticastPolicy.Context.PostContext | Select-String -Pattern 'handling policy') -split ': ')[1].Trim()
    If ($CurrentPolicy.Replace(' ','') -ne $Policy) { $DesiredState = $False }

    If ($PSBoundParameters.ContainsKey('AutoDC_Threshold')) {
        $CurrentThreshold = [uint32]((($MulticastPolicy.Context.PostContext | Select-String -Pattern 'threshold') -split ': ')[1] -split ' ')[0]
        If ($CurrentThreshold -ne $AutoDC_Threshold) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('StreamCount')) {
        $CurrentStreamCount = [uint32]((($MulticastPolicy.Context.PostContext | Select-String -Pattern 'stream count') -split ': ')[1] -split ' ')[0]
        If ($CurrentStreamCount -ne $StreamCount) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('Fallback')) {
        $CurrentFallback = (($MulticastPolicy.Context.PostContext | Select-String -Pattern 'Fallback') -split ': ')[1].Trim()
        If ($CurrentFallback -ne $Fallback) { $DesiredState = $False }
    }

    Return @{
        Policy           = $Policy
        AutoDC_Threshold = $AutoDC_Threshold
        StreamCount      = $StreamCount
        Fallback         = $Fallback
        DesiredState     = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("None", "AutoDisconnect", "Multistream")]
        [string]$Policy,

        [Parameter(Mandatory=$False)]
        [uint32]$AutoDC_Threshold,

        [Parameter(Mandatory=$False)]
        [ValidateSet(2,3)]       
        [uint32]$StreamCount,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]       
        [string]$Fallback,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $MulticastPolicy = $WdsConfig | Select-String -Pattern 'Multicast session policy' -Context 0,4

    $CurrentPolicy = (($MulticastPolicy.Context.PostContext | Select-String -Pattern 'handling policy') -split ': ')[1].Trim()
    If ($CurrentPolicy.Replace(' ','') -ne $Policy) { WdsUtil /Set-Server /Server:Localhost /Transport /MulticastSessionPolicy /Policy:$Policy }

    If ($PSBoundParameters.ContainsKey('AutoDC_Threshold')) {
        $CurrentThreshold = [uint32]((($MulticastPolicy.Context.PostContext | Select-String -Pattern 'threshold') -split ': ')[1] -split ' ')[0]
        If ($CurrentThreshold -ne $AutoDC_Threshold) { WdsUtil /Set-Server /Server:Localhost /Transport /MulticastSessionPolicy /Threshold:$AutoDC_Threshold }
    }

    If ($PSBoundParameters.ContainsKey('StreamCount')) {
        $CurrentStreamCount = [uint32]((($MulticastPolicy.Context.PostContext | Select-String -Pattern 'stream count') -split ': ')[1] -split ' ')[0]
        If ($CurrentStreamCount -ne $StreamCount) { WdsUtil /Set-Server /Server:Localhost /Transport /MulticastSessionPolicy /StreamCount:$StreamCount }
    }

    If ($PSBoundParameters.ContainsKey('Fallback')) {
        $CurrentFallback = (($MulticastPolicy.Context.PostContext | Select-String -Pattern 'Fallback') -split ': ')[1].Trim()
        If ($CurrentFallback -ne $Fallback) { WdsUtil /Set-Server /Server:Localhost /Transport /MulticastSessionPolicy /Fallback:$Fallback }
    }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("None", "AutoDisconnect", "Multistream")]
        [string]$Policy,

        [Parameter(Mandatory=$False)]
        [uint32]$AutoDC_Threshold,

        [Parameter(Mandatory=$False)]
        [ValidateSet(2,3)]       
        [uint32]$StreamCount,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]       
        [string]$Fallback,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $MulticastPolicy = $WdsConfig | Select-String -Pattern 'Multicast session policy' -Context 0,4

    $CurrentPolicy = (($MulticastPolicy.Context.PostContext | Select-String -Pattern 'handling policy') -split ': ')[1].Trim()
    If ($CurrentPolicy.Replace(' ','') -ne $Policy) { Return $False }

    If ($PSBoundParameters.ContainsKey('AutoDC_Threshold')) {
        $CurrentThreshold = [uint32]((($MulticastPolicy.Context.PostContext | Select-String -Pattern 'threshold') -split ': ')[1] -split ' ')[0]
        If ($CurrentThreshold -ne $AutoDC_Threshold) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('StreamCount')) {
        $CurrentStreamCount = [uint32]((($MulticastPolicy.Context.PostContext | Select-String -Pattern 'stream count') -split ': ')[1] -split ' ')[0]
        If ($CurrentStreamCount -ne $StreamCount) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('Fallback')) {
        $CurrentFallback = (($MulticastPolicy.Context.PostContext | Select-String -Pattern 'Fallback') -split ': ')[1].Trim()
        If ($CurrentFallback -ne $Fallback) { Return $False }
    }

    Return $True 

}
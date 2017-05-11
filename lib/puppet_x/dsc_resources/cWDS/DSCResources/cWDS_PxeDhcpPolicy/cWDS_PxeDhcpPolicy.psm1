Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$UseDhcpPorts,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$DhcpOption60,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$RogueDetection,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RpcPort,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $CurrentSettings = (WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'DHCP Configuration' -Context 0,7

    $CurrentUseDhcpPorts = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Use DHCP ports') -split ': ')[1].Trim()
    If ($CurrentUseDhcpPorts -ne $UseDhcpPorts) { $DesiredState = $False }

    If ($PSBoundParameters.ContainsKey('RogueDetection')){
        $Hash = @{ 'No' = 'Disabled' ; 'Yes' = 'Enabled' }
        $CurrentRogueDetection = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Rogue detection') -split ': ')[1].Trim()
        If ($CurrentRogueDetection -ne $Hash[$RogueDetection]) {  $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('DhcpOption60')){
        $CurrentDhcpOption60 = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'option 60 configured') -split ': ')[1].Trim()
        If ($CurrentDhcpOption60 -ne $DhcpOption60) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('RpcPort')){
        $CurrentRpcPort = [uint32](($CurrentSettings.Context.PostContext | Select-String -Pattern 'RPC port') -split ': ')[1].Trim()
        If ($CurrentRpcPort -ne $RpcPort) { $DesiredState = $False }
    }

    Return @{
        UseDhcpPorts   = $UseDhcpPorts
        RogueDetection = $RogueDetection
        DhcpOption60   = $DhcpOption60
        RpcPort        = $RpcPort
        DesiredState   = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$UseDhcpPorts,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$DhcpOption60,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$RogueDetection,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RpcPort,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $CurrentSettings = (WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'DHCP Configuration' -Context 0,7

    $CurrentUseDhcpPorts = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Use DHCP ports') -split ': ')[1].Trim()
    If ($CurrentUseDhcpPorts -ne $UseDhcpPorts) { WdsUtil /Set-Server /Server:Localhost /UseDhcpPorts:$UseDhcpPorts }

    If ($PSBoundParameters.ContainsKey('RogueDetection')){
        $Hash = @{ 'No' = 'Disabled' ; 'Yes' = 'Enabled' }
        $CurrentRogueDetection = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Rogue detection') -split ': ')[1].Trim()
        If ($CurrentRogueDetection -ne $Hash[$RogueDetection]) {  WdsUtil /Set-Server /Server:Localhost /RogueDetection:$RogueDetection }
    }

    If ($PSBoundParameters.ContainsKey('DhcpOption60')){
        $CurrentDhcpOption60 = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'option 60 configured') -split ': ')[1].Trim()
        If ($CurrentDhcpOption60 -eq '<Not Applicable>') { Throw 'DHCP option 60 could not be set because the DHCP service is not running on this machine.' }
        Elseif ($CurrentDhcpOption60 -ne $DhcpOption60) { WdsUtil /Set-Server /Server:Localhost /DhcpOption60:$DhcpOption60 }
    }

    If ($PSBoundParameters.ContainsKey('RpcPort')){
        $CurrentRpcPort = [uint32](($CurrentSettings.Context.PostContext | Select-String -Pattern 'RPC port') -split ': ')[1].Trim()
        If ($CurrentRpcPort -ne $RpcPort) { WdsUtil /Set-Server /Server:Localhost /RpcPort:$RpcPort }
    }    
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$UseDhcpPorts,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$DhcpOption60,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$RogueDetection,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RpcPort,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $CurrentSettings = (WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'DHCP Configuration' -Context 0,7

    $CurrentUseDhcpPorts = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Use DHCP ports') -split ': ')[1].Trim()
    If ($CurrentUseDhcpPorts -ne $UseDhcpPorts) { Return $False }

    If ($PSBoundParameters.ContainsKey('RogueDetection')){
        $Hash = @{ 'No' = 'Disabled' ; 'Yes' = 'Enabled' }
        $CurrentRogueDetection = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Rogue detection') -split ': ')[1].Trim()
        If ($CurrentRogueDetection -ne $Hash[$RogueDetection]) {  Return $False }
    }

    If ($PSBoundParameters.ContainsKey('DhcpOption60')){
        $CurrentDhcpOption60 = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'option 60 configured') -split ': ')[1].Trim()
        If ($CurrentDhcpOption60 -ne $DhcpOption60) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('RpcPort')){
        $CurrentRpcPort = [uint32](($CurrentSettings.Context.PostContext | Select-String -Pattern 'RPC port') -split ': ')[1].Trim()
        If ($CurrentRpcPort -ne $RpcPort) { Return $False }
    }

    Return $True 

}
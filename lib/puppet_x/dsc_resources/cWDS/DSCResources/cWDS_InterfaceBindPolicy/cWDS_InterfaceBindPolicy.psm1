Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Include", "Exclude")]
        [string]$Policy,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Interfaces,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $CurrentSettings = WdsUtil /Get-Server /Show:config
    $StartLine = ($CurrentSettings | Select-String -Pattern 'Interface bind policy').LineNumber
    $EndLine = ($CurrentSettings | Select-String -Pattern 'Boot Program Policy').LineNumber - 2
    $CurrentSettings = $CurrentSettings[$StartLine..$EndLine]

    $Hash = @{ 'Include' = 'Only Registered' ; 'Exclude' = 'Exclude Registered' }
    $CurrentPolicy = (($CurrentSettings | Select-String -Pattern 'Policy') -Split ': ')[1].Trim()
    If ($CurrentPolicy -ne $Hash[$Policy]) { $DesiredState = $False  }

    $SetInterfaces = @()
    Foreach ($Interface in $Interfaces){
        If (([string]::IsNullOrEmpty($Interface)) -OR ($Interface -eq 'Unset')) { Continue }
        $Split = $Interface -split ';'
        $SetInterfaces += New-Object PSObject -Property @{
            AddressType = $Split[0].Trim().ToUpper()
            AddressValue = $Split[1].Trim().Replace(':','').Replace('-','')
        }
    }

    $CurrentInterfaceLines = ($CurrentSettings | Select-String -Pattern '=>').Line
    $CurrentInterfaces = @()
    Foreach ($Interface in $CurrentInterfaceLines) {
        If ([string]::IsNullOrEmpty($Interface)) { Continue }
        $Split = $Interface -split ' => '
        $CurrentInterfaces += New-Object PSObject -Property @{
            AddressType = $Split[0].Trim()
            AddressValue = $Split[1].Trim()
        }
    }

    If ($Interfaces -eq 'Unset') { If ($CurrentInterfaces.Count -ne 0) { $DesiredState = $False } }
    Elseif ($CurrentInterfaces.Count -eq 0) { $DesiredState = $False }
    Else {
        $Comparison = Compare-Object -ReferenceObject $SetInterfaces.AddressValue -DifferenceObject $CurrentInterfaces.AddressValue
        If ($Comparison -ne $Null) { $DesiredState = $False }
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
        [ValidateSet("Include", "Exclude")]
        [string]$Policy,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Interfaces,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $CurrentSettings = WdsUtil /Get-Server /Show:config
    $StartLine = ($CurrentSettings | Select-String -Pattern 'Interface bind policy').LineNumber
    $EndLine = ($CurrentSettings | Select-String -Pattern 'Boot Program Policy').LineNumber - 2
    $CurrentSettings = $CurrentSettings[$StartLine..$EndLine]

    $Hash = @{ 'Include' = 'Only Registered' ; 'Exclude' = 'Exclude Registered' }
    $CurrentPolicy = (($CurrentSettings | Select-String -Pattern 'Policy') -Split ': ')[1].Trim()
    If ($CurrentPolicy -ne $Hash[$Policy]) { WdsUtil /Set-Server /Server:Localhost /BindPolicy /Policy:$Policy  }

    $SetInterfaces = @()
    Foreach ($Interface in $Interfaces){
        If (([string]::IsNullOrEmpty($Interface)) -OR ($Interface -eq 'Unset')) { Continue }
        $Split = $Interface -split ';'
        If (($Split[0] -ne 'ip') -AND ($Split[0] -ne 'mac')) { Throw 'AddressType must be set to "IP" or "MAC".' }
        $SetInterfaces += New-Object PSObject -Property @{
            AddressType = $Split[0].Trim().ToUpper()
            AddressValue = $Split[1].Trim().Replace(':','').Replace('-','')
        }
    }

    $CurrentInterfaceLines = ($CurrentSettings | Select-String -Pattern '=>').Line
    $CurrentInterfaces = @()
    Foreach ($Interface in $CurrentInterfaceLines) {
        If ([string]::IsNullOrEmpty($Interface)) { Continue }
        $Split = $Interface -split ' => '
        $CurrentInterfaces += New-Object PSObject -Property @{
            AddressType = $Split[0].Trim()
            AddressValue = $Split[1].Trim()
        }
    }

    If ($Interfaces -eq 'Unset') { Foreach ($Interface in $CurrentInterfaces) { WdsUtil /Set-Server /Server:Localhost /BindPolicy /Remove /AddressType:"$($Interface.AddressType)" /Address:"$($Interface.AddressValue)" } }
    Elseif ($CurrentInterfaces.Count -eq 0) { Foreach ($Interface in $SetInterfaces) { WdsUtil /Set-Server /Server:Localhost /BindPolicy /Add /AddressType:"$($Interface.AddressType)" /Address:"$($Interface.AddressValue)" } }
    Else {
        $Comparison = Compare-Object -ReferenceObject $SetInterfaces.AddressValue -DifferenceObject $CurrentInterfaces.AddressValue

        If ($Comparison -ne $Null) {
            $ToAdd = ($Comparison | Where SideIndicator -eq '<=').InputObject
            $ToRem = ($Comparison | Where SideIndicator -eq '=>').InputObject

            Foreach ($Add in $ToAdd) {
                $Interface = $SetInterfaces | Where AddressValue -eq $Add
                WdsUtil /Set-Server /Server:Localhost /BindPolicy /Add /AddressType:"$($Interface.AddressType)" /Address:"$($Interface.AddressValue)"
            }

            Foreach ($Rem in $ToRem) {
                $Interface = $CurrentInterfaces | Where AddressValue -eq $Rem
                WdsUtil /Set-Server /Server:Localhost /BindPolicy /Remove /AddressType:"$($Interface.AddressType)" /Address:"$($Interface.AddressValue)"
            }
        }
    }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Include", "Exclude")]
        [string]$Policy,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Interfaces,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $CurrentSettings = WdsUtil /Get-Server /Show:config
    $StartLine = ($CurrentSettings | Select-String -Pattern 'Interface bind policy').LineNumber
    $EndLine = ($CurrentSettings | Select-String -Pattern 'Boot Program Policy').LineNumber - 2
    $CurrentSettings = $CurrentSettings[$StartLine..$EndLine]

    $Hash = @{ 'Include' = 'Only Registered' ; 'Exclude' = 'Exclude Registered' }
    $CurrentPolicy = (($CurrentSettings | Select-String -Pattern 'Policy') -Split ': ')[1].Trim()
    If ($CurrentPolicy -ne $Hash[$Policy]) { Return $False  }

    $SetInterfaces = @()
    Foreach ($Interface in $Interfaces){
        If (([string]::IsNullOrEmpty($Interface)) -OR ($Interface -eq 'Unset')) { Continue }
        $Split = $Interface -split ';'
        $SetInterfaces += New-Object PSObject -Property @{
            AddressType = $Split[0].Trim().ToUpper()
            AddressValue = $Split[1].Trim().Replace(':','').Replace('-','')
        }
    }

    $CurrentInterfaceLines = ($CurrentSettings | Select-String -Pattern '=>').Line
    $CurrentInterfaces = @()
    Foreach ($Interface in $CurrentInterfaceLines) {
        If ([string]::IsNullOrEmpty($Interface)) { Continue }
        $Split = $Interface -split ' => '
        $CurrentInterfaces += New-Object PSObject -Property @{
            AddressType = $Split[0].Trim()
            AddressValue = $Split[1].Trim()
        }
    }

    If ($Interfaces -eq 'Unset') { If ($CurrentInterfaces.Count -ne 0) { Return $False } }
    Elseif ($CurrentInterfaces.Count -eq 0) { Return $False }
    Else {
        $Comparison = Compare-Object -ReferenceObject $SetInterfaces.AddressValue -DifferenceObject $CurrentInterfaces.AddressValue
        If ($Comparison -ne $Null) { Return $False }
    }

    Return $True 

}
Function Get-TargetResource {

    Param(

        [Parameter(Mandatory)]
        [ValidateSet("MANUAL", "DOMHIER", "ALL", "NO")]
        [string]$SyncFromFlags,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpy()]
        [string[]]$Sources

    )

    $Modes = @{
        NT5DS = 'DOMHIER'
        NTP = 'MANUAL'
        AllSync = 'ALL'
        NoSync = 'NO'
    }

    $Result = @{ DesiredState = $True }

    $CurrentSyncFromFlags = $Modes[(Get-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters').GetValue('Type').ToString()]
    If ($CurrentSyncFromFlags -ne $SyncFromFlags) { $Result.Add('SetSyncFromFlags',$True) ; $Result.DesiredState = $False }
    Else { $Result.Add('SetSyncFromFlags',$False) }

    If ($CurrentSyncFromFlags -ne 'DOMHIER' -and $CurrentSyncFromFlags -ne 'NO' `
        -and $SyncFromFlags -ne 'DOMHIER' -and $SyncFromFlags -ne 'NO' -and $PSBoundParameters.ContainsKey('Sources')) {
        
        $CurrentSources = @()
        ((Invoke-Expression -Command "w32tm /query /peers") | Select-String "^Peer:").Line | % { 
            $Source = ($_ -split ': ')[1].Trim()
            If (-not ([string]::IsNullOrEmpty($Source))) { $CurrentSources += $Source }
        }
        $Result.Add('CurrentSources',$CurrentSources)
        If (Compare-Object $Sources $CurrentSources) { $Result.Add('SetSources',$True) ; $Result.DesiredState = $False }
        Else { $Result.Add('SetSources',$False) }
    }

    Return $Result
}

Function Set-TargetResource {
    
    Param(

        [ValidateSet("MANUAL", "DOMHIER", "ALL", "NO")]
        [Parameter(Mandatory)]
        [string]$SyncFromFlags,

        [ValidateNotNullOrEmpy()]
        [Parameter(Mandatory=$False)]
        [string[]]$Sources

    )

    $CurrentState = Get-TargetResource @PSBoundParameters

    If ($CurrentState.SetSyncFromFlags) { Invoke-Expression -Command "w32tm /config /syncfromflags:$SyncFromFlags" }
    If ($SyncFromFlags -ne 'DOMHIER' -and $SyncFromFlags -ne 'NO' -and $PSBoundParameters.ContainsKey('Sources')) {
        If ($CurrentState.ContainsKey('SetSources')) { 
            If ($CurrentState.SetSources -eq $True) { Invoke-Expression -Command ('w32tm /config /manualpeerlist:"' + ($Sources -join " ") + '"')  }
        }
        Else {
            $CurrentSources = @()
            ((Invoke-Expression -Command "w32tm /query /peers") | Select-String "^Peer:").Line | % { 
                $Source = ($_ -split ': ')[1].Trim()
                If (-not ([string]::IsNullOrEmpty($Source))) { $CurrentSources += $Source }
            }
            If (Compare-Object $Sources $CurrentSources) { Invoke-Expression -Command ('w32tm /config /manualpeerlist:"' + ($Sources -join " ") + '"') }
        }
    }
}

Function Test-TargetResource {
    
    Param(

        [ValidateSet("MANUAL", "DOMHIER", "ALL", "NO")]
        [Parameter(Mandatory)]
        [string]$SyncFromFlags,

        [ValidateNotNullOrEmpy()]
        [Parameter(Mandatory=$False)]
        [string[]]$Sources

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$Disk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$VolumeState

    )

    If ($Disk.EndsWith(':')) { $Disk = $Disk.Replace(':','') }
    $Info = fsutil.exe 8dot3name query ${Disk}:
    $CurrentRegistryState = ((($Info | Select-String "registry state") -split ": ")[1] -split " ")[0]
    $CurrentVolumeState = ((($Info | Select-String "volume state") -split ": ")[1] -split " ")[0]

    If (($CurrentRegistryState -ne "2") -or ($CurrentVolumeState -ne $VolumeState)) {
        $DesiredState = $False
    } Else {
        $DesiredState = $True
    }

    Return @{
        Disk = $Disk
        DesiredState = $DesiredState
        CurrentVolumeState = $CurrentVolumeState
        CurrentRegistryState = $CurrentRegistryState
    }
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$Disk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$VolumeState

    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    $Disk = $CurrentState.Disk
    If ($CurrentState.CurrentRegistryState -ne "2") { fsutil.exe 8dot3name set 2 }
    If ($CurrentState.CurrentVolumeState -ne $VolumeState) { fsutil.exe 8dot3name set ${Disk}: $VolumeState }

}

Function Test-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$Disk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$VolumeState

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}

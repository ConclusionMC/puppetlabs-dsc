Function Get-TargetResource {

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IpkKey
    )

    $Licensestatus = ((cscript slmgr.vbs /dlv | Select-String 'License Status:') -split ': ')[1]

    Return @{
        Licensestatus = $Licensestatus
        DesiredState = $Licensestatus -eq "Licensed"
    }
}

Function Set-TargetResource {

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IpkKey
    )

    cscript slmgr.vbs /ipk $IpkKey
}

Function Test-TargetResource {

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IpkKey
    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
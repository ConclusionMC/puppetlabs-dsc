Function Get-TargetResource {

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IpkKey
    )

    $Licensestatus = ((cmd /c "cscript $env:SystemRoot\system32\slmgr.vbs /dlv" | Select-String 'License Status:').Line -Split "Status:")[1].Trim()

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

    cmd /c "cscript $env:SystemRoot\system32\slmgr.vbs /ipk $IpkKey"
}

Function Test-TargetResource {

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IpkKey
    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}

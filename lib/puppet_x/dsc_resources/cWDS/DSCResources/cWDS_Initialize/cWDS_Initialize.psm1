Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteInstallDir,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = WdsUtil /Get-Server /Show:Config
    $OperationalMode = (($WDSConfig | Select-String -Pattern 'WDS operational mode') -split ': ')[1].Trim()

    If ($Ensure -eq 'Present') {
        If ($OperationalMode -eq 'Not Configured') { $DesiredState = $False }
        Else { $DesiredState = $True } 
    }

    Elseif ($Ensure -eq 'Absent') {
        If ($OperationalMode -eq 'Not Configured') { $DesiredState = $True }
        Else { $DesiredState = $False } 
    }
    
    Return @{  
        RemoteInstallDir   = $RemoteInstallDir
        Ensure             = $Ensure
        DesiredState       = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteInstallDir,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($Ensure -eq 'Present') { wdsutil /Progress /Initialize-Server /Reminst:"$RemoteInstallDir" ; $global:DSCMachineStatus = 1 }
    Elseif ($Ensure -eq 'Absent') { wdsutil /Progress /Uninitialize-Server }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$RemoteInstallDir,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSConfig = WdsUtil /Get-Server /Show:Config
    $OperationalMode = (($WDSConfig | Select-String -Pattern 'WDS operational mode') -split ': ')[1].Trim()

    If ($Ensure -eq 'Present') {
        If ($OperationalMode -eq 'Not Configured') { Return $False }
        Else { Return $True } 
    }

    Elseif ($Ensure -eq 'Absent') {
        If ($OperationalMode -eq 'Not Configured') {  Return $True }
        Else { Return $False } 
    }
}
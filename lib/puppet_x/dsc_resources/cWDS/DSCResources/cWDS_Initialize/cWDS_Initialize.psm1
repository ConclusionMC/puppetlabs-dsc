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

    $WDSServerFQDN = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
    $WDSConfig = wdsutil /Get-Server /Server:"$WDSServerFQDN" /Show:Config
    $SearchString = "CONFIGURATION INFORMATION FOR SERVER $WDSServerFQDN"

    If ($Ensure -eq 'Present') {
        If ($WDSConfig.ToLower().Contains($SearchString.ToLower())) { $DesiredState = $True }
        Else { $DesiredState = $False } 
    }

    Elseif ($Ensure -eq 'Absent') {
        If ($WDSConfig.ToLower().Contains($SearchString.ToLower())) { $DesiredState = $False }
        Else { $DesiredState = $True } 
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

    $WDSServerFQDN = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
    $WDSConfig = wdsutil /Get-Server /Server:"$WDSServerFQDN" /Show:Config
    $SearchString = "CONFIGURATION INFORMATION FOR SERVER $WDSServerFQDN"

    If ($Ensure -eq 'Present') {
        If ($WDSConfig.ToLower().Contains($SearchString.ToLower())) { Return $True }
        Else { Return $False } 
    }

    Elseif ($Ensure -eq 'Absent') {
        If ($WDSConfig.ToLower().Contains($SearchString.ToLower())) { Return $False }
        Else { Return $True } 
    }
}
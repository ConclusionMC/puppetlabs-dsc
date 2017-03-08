Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSServerFQDN = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
    $WDSConfig = (wdsutil.exe /get-allservers /show:config)
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
        InstallDir   = $InstallDir
        Ensure       = $Ensure
        DesiredState = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($Ensure -eq 'Present') {
        wdsutil.exe /Initialize-Server /reminst:"$InstallDir"
    }

    Elseif ($Ensure -eq 'Absent') {
        wdsutil.exe /uninitialize-Server
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WDSServerFQDN = [System.Net.Dns]::GetHostEntry([string]$env:computername).HostName
    $WDSConfig = (wdsutil.exe /get-allservers /show:config)
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
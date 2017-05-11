Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,

        [Parameter(Mandatory=$True)]
        [ValidateSet("None", "Info", "Warnings", "Errors")]
        [string]$LoggingLvl,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $LoggingPolicy = $WdsConfig | Select-String -Pattern 'Logging policy' -Context 0,2

    $CurrentlyEnabled = (($LoggingPolicy.Context.PostContext | Select-String -Pattern 'Enabled') -split ': ')[1].Trim()
    If ($CurrentlyEnabled -ne $Enabled) { $DesiredState = $False }

    $CurrentLoggingLvl = (($LoggingPolicy.Context.PostContext | Select-String -Pattern 'Logging level') -split ': ')[1].Trim()
    If ($CurrentLoggingLvl -ne $LoggingLvl) { $DesiredState = $False }
   
    Return @{
        Enabled      = $Enabled
        LoggingLvl   = $LoggingLvl
        DesiredState = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,

        [Parameter(Mandatory=$True)]
        [ValidateSet("None", "Info", "Warnings", "Errors")]
        [string]$LoggingLvl,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $LoggingPolicy = $WdsConfig | Select-String -Pattern 'Logging policy' -Context 0,2

    $CurrentlyEnabled = (($LoggingPolicy.Context.PostContext | Select-String -Pattern 'Enabled') -split ': ')[1].Trim()
    If ($CurrentlyEnabled -ne $Enabled) { WdsUtil /Set-Server /Server:Localhost /WdsClientLogging /Enabled:$Enabled }

    $CurrentLoggingLvl = (($LoggingPolicy.Context.PostContext | Select-String -Pattern 'Logging level') -split ': ')[1].Trim()
    If ($CurrentLoggingLvl -ne $LoggingLvl) { WdsUtil /Set-Server /Server:Localhost /WdsClientLogging /LoggingLevel:$LoggingLvl }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,

        [Parameter(Mandatory=$True)]
        [ValidateSet("None", "Info", "Warnings", "Errors")]
        [string]$LoggingLvl,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $LoggingPolicy = $WdsConfig | Select-String -Pattern 'Logging policy' -Context 0,2

    $CurrentlyEnabled = (($LoggingPolicy.Context.PostContext | Select-String -Pattern 'Enabled') -split ': ')[1].Trim()
    If ($CurrentlyEnabled -ne $Enabled) { Return $False }

    $CurrentLoggingLvl = (($LoggingPolicy.Context.PostContext | Select-String -Pattern 'Logging level') -split ': ')[1].Trim()
    If ($CurrentLoggingLvl -ne $LoggingLvl) { Return $False }

    Return $True
}
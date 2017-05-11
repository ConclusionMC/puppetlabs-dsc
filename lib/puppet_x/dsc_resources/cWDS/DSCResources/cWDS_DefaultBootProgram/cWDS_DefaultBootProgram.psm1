Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultx64BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultx86BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultia64BootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredStatue = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BootProgramSettings = $WdsConfig | Select-String -Pattern 'Default boot programs' -Context 0,6

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'x64 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultx64BootProgram) { $DesiredStatue = $False }

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'x86 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultx86BootProgram) { $DesiredStatue = $False }

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'ia64') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultia64BootProgram) { $DesiredStatue = $False }

    Return @{
        Defaultx64BootProgram  = $Defaultx64BootProgram
        Defaultx86BootProgram  = $Defaultx86BootProgram
        Defaultia64BootProgram = $Defaultia64BootProgram
        DesiredState           = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultx64BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultx86BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultia64BootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BootProgramSettings = $WdsConfig | Select-String -Pattern 'Default boot programs' -Context 0,6

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'x64 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultx64BootProgram) { WdsUtil /Set-Server /Server:Localhost /BootProgram:"$Defaultx64BootProgram" /Architecture:x64 }

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'x86 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultx86BootProgram) { WdsUtil /Set-Server /Server:Localhost /BootProgram:"$Defaultx86BootProgram" /Architecture:x86 }

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'ia64') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultia64BootProgram) { WdsUtil /Set-Server /Server:Localhost /BootProgram:"$Defaultia64BootProgram" /Architecture:ia64 }

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultx64BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultx86BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Defaultia64BootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $BootProgramSettings = $WdsConfig | Select-String -Pattern 'Default boot programs' -Context 0,6

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'x64 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultx64BootProgram) { Return $False }

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'x86 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultx86BootProgram) { Return $False }

    $CurrentSetting = (($BootProgramSettings.Context.PostContext | Select-String -Pattern 'ia64') -split '-')[1].Trim()
    If ($CurrentSetting -ne $Defaultia64BootProgram) { Return $False }

    Return $True

}
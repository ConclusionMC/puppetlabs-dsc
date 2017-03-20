Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12x64BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12x86BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12ia64BootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredStatue = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $N12BootProgramSettings = $WdsConfig | Select-String -Pattern 'Default N12 boot programs' -Context 0,6

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'x64 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12x64BootProgram) { $DesiredStatue = $False }

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'x86 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12x86BootProgram) { $DesiredStatue = $False }

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'ia64') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12ia64BootProgram) { $DesiredStatue = $False }

    Return @{
        DefaultN12x64BootProgram  = $DefaultN12x64BootProgram
        DefaultN12x86BootProgram  = $DefaultN12x86BootProgram
        DefaultN12ia64BootProgram = $DefaultN12ia64BootProgram
        DesiredState              = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12x64BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12x86BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12ia64BootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $N12BootProgramSettings = $WdsConfig | Select-String -Pattern 'Default N12 boot programs' -Context 0,6

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'x64 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12x64BootProgram) { WdsUtil /Set-Server /Server:Localhost /N12BootProgram:"$DefaultN12x64BootProgram" /Architecture:x64 }

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'x86 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12x86BootProgram) { WdsUtil /Set-Server /Server:Localhost /N12BootProgram:"$DefaultN12x86BootProgram" /Architecture:x86 }

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'ia64') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12ia64BootProgram) { WdsUtil /Set-Server /Server:Localhost /N12BootProgram:"$DefaultN12ia64BootProgram" /Architecture:ia64 }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12x64BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12x86BootProgram,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultN12ia64BootProgram,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $N12BootProgramSettings = $WdsConfig | Select-String -Pattern 'Default N12 boot programs' -Context 0,6

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'x64 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12x64BootProgram) { Return $False }

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'x86 ') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12x86BootProgram) { Return $False }

    $CurrentSetting = (($N12BootProgramSettings.Context.PostContext | Select-String -Pattern 'ia64') -split '-')[1].Trim()
    If ($CurrentSetting -ne $DefaultN12ia64BootProgram) { Return $False }
    
    Return $True

}
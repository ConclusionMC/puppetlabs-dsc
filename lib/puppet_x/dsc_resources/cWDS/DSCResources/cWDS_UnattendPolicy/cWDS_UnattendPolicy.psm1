Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$Policy,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$CommandlinePrecedence,

        [Parameter(Mandatory=$False)]
        [string]$x86UnattendFile,

        [Parameter(Mandatory=$False)]
        [string]$x64UnattendFile,
        
        [Parameter(Mandatory=$False)]
        [string]$ia64UnattendFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Hash = @{ 'Enabled' = 'yes' ; 'Disabled' = 'no' }
    
    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $UnattendPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'unattend policy:' -Context 0,9
    
    $CurrentPolicy = [string](($UnattendPolicy.Context.PostContext | Select-String -Pattern "enabled:") -split 'enabled: ')[1].Trim()
    $CurrentPrecedence = [string](($UnattendPolicy.Context.PostContext | Select-String -Pattern "precedence:") -split 'precedence: ')[1].Trim()

    If ($CurrentPolicy -ne $Hash[$Policy]) { $DesiredState = $False }
    If ($CurrentPrecedence -ne $CommandlinePrecedence) { $DesiredState = $False }

    If ($PSBoundParameters.ContainsKey('x86UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^x86 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $x86UnattendFile.ToLower()) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('x64UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^x64 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $x64UnattendFile.ToLower()) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('ia64UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^ia64 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $ia64UnattendFile.ToLower()) { $DesiredState = $False }
    }        

    
    Return @{
        Policy                 = $Policy
        CommandlinePrecedence  = $CommandlinePrecedence
        x86UnattendFile        = $x86UnattendFile
        x64UnattendFile        = $x64UnattendFile
        ia64UnattendFile       = $ia64UnattendFile
        DesiredState           = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$Policy,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$CommandlinePrecedence,

        [Parameter(Mandatory=$False)]
        [string]$x86UnattendFile,

        [Parameter(Mandatory=$False)]
        [string]$x64UnattendFile,
        
        [Parameter(Mandatory=$False)]
        [string]$ia64UnattendFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Hash = @{ 'Enabled' = 'yes' ; 'Disabled' = 'no' }
    
    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $UnattendPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'unattend policy:' -Context 0,9
    
    $CurrentPolicy = [string](($UnattendPolicy.Context.PostContext | Select-String -Pattern "enabled:") -split 'enabled: ')[1].Trim()
    $CurrentPrecedence = [string](($UnattendPolicy.Context.PostContext | Select-String -Pattern "precedence:") -split 'precedence: ')[1].Trim()

    If ($CurrentPolicy -ne $Hash[$Policy]) { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /Policy:"$Policy" }
    If ($CurrentPrecedence -ne $CommandlinePrecedence) { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /CommandlinePrecedence:"$CommandlinePrecedence" }

    If ($PSBoundParameters.ContainsKey('x86UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^x86 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $x86UnattendFile.ToLower()) {
            If ($x86UnattendFile.ToLower() -eq 'unset') { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /File:'' /Architecture:x86 }
            Else { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /File:"$x86UnattendFile" /Architecture:x86 }
        }
    }

    If ($PSBoundParameters.ContainsKey('x64UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^x64 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $x64UnattendFile.ToLower()) {
            If ($x64UnattendFile.ToLower() -eq 'unset') { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /File:'' /Architecture:x64 }
            Else { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /File:"$x64UnattendFile" /Architecture:x64 }
        }
    }

    If ($PSBoundParameters.ContainsKey('ia64UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^ia64 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $ia64UnattendFile.ToLower()) {
            If ($ia64UnattendFile.ToLower() -eq 'unset') { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /File:'' /Architecture:ia64 }
            Else { WdsUtil /Set-Server /Server:Localhost /WdsUnattend /File:"$ia64UnattendFile" /Architecture:ia64 }
        }
    }
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet("Enabled", "Disabled")]
        [string]$Policy,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes", "No")]
        [string]$CommandlinePrecedence,

        [Parameter(Mandatory=$False)]
        [string]$x86UnattendFile,

        [Parameter(Mandatory=$False)]
        [string]$x64UnattendFile,
        
        [Parameter(Mandatory=$False)]
        [string]$ia64UnattendFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Hash = @{ 'Enabled' = 'yes' ; 'Disabled' = 'no' }
    
    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $UnattendPolicy = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'unattend policy:' -Context 0,9
    
    $CurrentPolicy = [string](($UnattendPolicy.Context.PostContext | Select-String -Pattern "enabled:") -split 'enabled: ')[1].Trim()
    $CurrentPrecedence = [string](($UnattendPolicy.Context.PostContext | Select-String -Pattern "precedence:") -split 'precedence: ')[1].Trim()

    If ($CurrentPolicy -ne $Hash[$Policy]) { Return $False }
    If ($CurrentPrecedence -ne $CommandlinePrecedence) { Return $False }

    If ($PSBoundParameters.ContainsKey('x86UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^x86 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $x86UnattendFile.ToLower()) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('x64UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^x64 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $x64UnattendFile.ToLower()) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('ia64UnattendFile')) {
        $CurrentUnattendFile = (($UnattendPolicy.Context.PostContext | Select-String -Pattern "^ia64 ") -split ' -').Trim()
        If ($CurrentUnattendFile.Count -lt 2) { $CurrentUnattendFile = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentUnattendFile[1])) { $CurrentUnattendFile = 'unset'  }
        Else { $CurrentUnattendFile = [string]$CurrentUnattendFile[1].Trim() }
        If ($CurrentUnattendFile -ne $ia64UnattendFile.ToLower()) { Return $False }
    }     
        
    Return $True 

}
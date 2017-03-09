Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet("x86", "x64", "Both")]
        [string]$Defaultx64ImageType,

        [Parameter(Mandatory=$False)]
        [string]$Defaultx86BootImage = '',

        [Parameter(Mandatory=$False)]
        [string]$Defaultx64BootImage = '',
        
        [Parameter(Mandatory=$False)]
        [string]$Defaultia64BootImage = '',

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Hash = @{ 'x86' = 'x86 only' ; 'x64' = 'x64 only' ; 'both' = 'both' }

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $DefaultBootImageConfig = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'Boot Image Policy:' -Context 0,8
    $CurrentDefaultx64ImageType = [string](($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "image type for x64 clients:") -split 'clients: ')[1].Trim()

    If ($CurrentDefaultx64ImageType -ne $Hash[$Defaultx64ImageType]) { $DesiredState = $False }

    If (!([string]::IsNullOrEmpty($Defaultx64BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^x64 ") -split ' -').Trim()
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultx64BootImage.ToLower()) { $DesiredState = $False }
    }

    If (!([string]::IsNullOrEmpty($Defaultx86BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^x86 ") -split ' -')
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultx86BootImage.ToLower()) { $DesiredState = $False }
    }

    If (!([string]::IsNullOrEmpty($Defaultia64BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^ia64 ") -split ' -')
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultia64BootImage.ToLower()) { $DesiredState = $False }
    }          

    
    Return @{
        Defaultx64ImageType  = $Defaultx64ImageType
        Defaultx64BootImage  = $Defaultx64BootImage
        Defaultx86BootImage  = $Defaultx86BootImage
        Defaultia64BootImage = $Defaultia64BootImage
        DesiredState         = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet("x86", "x64", "Both")]
        [string]$Defaultx64ImageType,

        [Parameter(Mandatory=$False)]
        [string]$Defaultx86BootImage = '',

        [Parameter(Mandatory=$False)]
        [string]$Defaultx64BootImage = '',
        
        [Parameter(Mandatory=$False)]
        [string]$Defaultia64BootImage = '',

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Hash = @{ 'x86' = 'x86 only' ; 'x64' = 'x64 only' ; 'both' = 'both' }

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $DefaultBootImageConfig = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'Boot Image Policy:' -Context 0,8
    $CurrentDefaultx64ImageType = [string](($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "image type for x64 clients:") -split 'clients: ')[1].Trim()

    If ($CurrentDefaultx64ImageType -ne $Hash[$Defaultx64ImageType]) { WdsUtil /Set-Server /Server:Localhost /DefaultX86X64ImageType:"$Defaultx64ImageType" }

    If (!([string]::IsNullOrEmpty($Defaultx64BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^x64 ") -split ' -').Trim()
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultx64BootImage.ToLower()) { 
            If ($Defaultx64BootImage.ToLower() -eq 'unset') { WdsUtil /Set-Server /Server:Localhost /BootImage:"" /Architecture:x64 }
            Else { WdsUtil /Set-Server /Server:Localhost /BootImage:"$Defaultx64BootImage" /Architecture:x64 }
        }
    }

    If (!([string]::IsNullOrEmpty($Defaultx86BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^x86 ") -split ' -')
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultx86BootImage.ToLower()) { 
            If ($Defaultx86BootImage.ToLower() -eq 'unset') { WdsUtil /Set-Server /Server:Localhost /BootImage:"" /Architecture:x86 }
            Else { WdsUtil /Set-Server /Server:Localhost /BootImage:"$Defaultx86BootImage" /Architecture:x86 }
        }
    }

    If (!([string]::IsNullOrEmpty($Defaultia64BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^ia64 ") -split ' -')
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultia64BootImage.ToLower()) { 
            If ($Defaultia64BootImage.ToLower() -eq 'unset') { WdsUtil /Set-Server /Server:Localhost /BootImage:"" /Architecture:ia64 }
            Else { WdsUtil /Set-Server /Server:Localhost /BootImage:"$Defaultia64BootImage" /Architecture:ia64 }
        }
    }          
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet("x86", "x64", "Both")]
        [string]$Defaultx64ImageType,

        [Parameter(Mandatory=$False)]
        [string]$Defaultx86BootImage = '',

        [Parameter(Mandatory=$False)]
        [string]$Defaultx64BootImage = '',
        
        [Parameter(Mandatory=$False)]
        [string]$Defaultia64BootImage = '',

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Hash = @{ 'x86' = 'x86 only' ; 'x64' = 'x64 only' ; 'both' = 'both' }

    $WDSConfig = Wdsutil /Get-Server /Server:Localhost /Show:Config
    $DefaultBootImageConfig = $WDSConfig.Trim().ToLower() | Select-String -Pattern 'Boot Image Policy:' -Context 0,8
    $CurrentDefaultx64ImageType = [string](($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "image type for x64 clients:") -split 'clients: ')[1].Trim()

    If ($CurrentDefaultx64ImageType -ne $Hash[$Defaultx64ImageType]) { Return $False }

    If (!([string]::IsNullOrEmpty($Defaultx64BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^x64 ") -split ' -').Trim()
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultx64BootImage.ToLower()) { Return $False }
    }

    If (!([string]::IsNullOrEmpty($Defaultx86BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^x86 ") -split ' -')
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultx86BootImage.ToLower()) { Return $False }
    }

    If (!([string]::IsNullOrEmpty($Defaultia64BootImage))) {
        $CurrentBootImage = (($DefaultBootImageConfig.Context.PostContext | Select-String -Pattern "^ia64 ") -split ' -')
        If ($CurrentBootImage.Count -lt 2) { $CurrentBootImage = 'unset' }
        Elseif ([string]::IsNullOrEmpty($CurrentBootImage[1])) { $CurrentBootImage = 'unset'  }
        Else { $CurrentBootImage = [string]$CurrentBootImage[1].Trim() }
        If ($CurrentBootImage -ne $Defaultia64BootImage.ToLower()) { Return $False }
    }          
        
    Return $True 

}
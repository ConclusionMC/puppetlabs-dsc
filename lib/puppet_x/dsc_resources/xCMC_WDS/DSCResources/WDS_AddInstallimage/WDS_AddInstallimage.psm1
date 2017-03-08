Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    Try { Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue }
    Catch { 
        Return @{
            WimFile = $WimFile
            ImageGroup = $ImageGroup
            DesiredState = $False
        }
    }

    $Images = Get-WindowsImage -ImagePath $WimFile

    Foreach ($Image in $Images) { 
        $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $Image.ImageName
        If ($Test -eq $Null) { $DesiredState = $False }
    }
    
    Return @{
            WimFile = $WimFile
            ImageGroup = $ImageGroup
            DesiredState = $DesiredState
    }    
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue
    If ($Test -eq $Null) { New-WdsInstallImageGroup -Name $ImageGroup }

    $Images = Get-WindowsImage -ImagePath $WimFile

    Foreach ($Image in $Images) { 
        $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $Image.ImageName
        If ($Test -eq $Null) { Import-WdsInstallImage -Path $WimFile -ImageGroup $ImageGroup -ImageName $Image.ImageName -SkipVerify }
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Try { $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue }
    Catch { Return $False }

    $Images = Get-WindowsImage -ImagePath $WimFile

    Foreach ($Image in $Images) { 
        $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $Image.ImageName
        If ($Test -eq $Null) { Return $False }
    }

    Return $True
}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue
    
    If ($Test -eq $Null) { $DesiredState = $False }
    Else {
        $Images = Get-WindowsImage -ImagePath $WimFile
        
        Foreach ($Image in $Images) { 
            $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $Image.ImageName
            If ($Test -eq $Null) { $DesiredState = $False }
        }
    }
        
    Return @{
            WimFile      = $WimFile
            ImageGroup   = $ImageGroup
            SkipVerify   = $SkipVerify
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
        If ($Test -eq $Null) {
            If ($SkipVerify) { Import-WdsInstallImage -Path $WimFile -ImageGroup $ImageGroup -ImageName $Image.ImageName -SkipVerify }
            Else { Import-WdsInstallImage -Path $WimFile -ImageGroup $ImageGroup -ImageName $Image.ImageName }             
        }
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

    $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue
    If ($Test -eq $Null) { Return $False }

    $Images = Get-WindowsImage -ImagePath $WimFile

    Foreach ($Image in $Images) { 
        $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $Image.ImageName
        If ($Test -eq $Null) { Return $False }
    }

    Return $True
}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [string]$NewImageName,

        [Parameter(Mandatory=$False)]
        [string]$NewFileName,

        [Parameter(Mandatory=$False)]
        [string]$NewDescription,

        [Parameter(Mandatory=$False)]
        [string]$SecuritySDDL,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Test = (Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue) -ne $Null
    If (!($Test)) { $DesiredState = $False }
    Else {
        $Images = Get-WindowsImage -ImagePath $WimFile
        $i = 1
        Foreach ($Image in $Images) { 
    
            If ($PSBoundParameters.ContainsKey('NewImageName')) { 
                If ($i -eq 1) { $ImageName = $NewImageName } 
                Else { $ImageName = "${NewImageName}-$i" }
            }
            Else { $ImageName = $Image.ImageName }
    
            $Test = (Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName) -ne $Null

            If (!($Test)) { $DesiredState = $False }
            Else {

                $ImportedImage = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName

                If ($PSBoundParameters.ContainsKey('SecuritySDDL')) { 
                    If ($ImportedImage.Security -cne $SecuritySDDL) { $DesiredState = $False } 
                }
    
                If ($PSBoundParameters.ContainsKey('NewDescription')) { 
                    If ($ImportedImage.Description -cne $NewDescription) { $DesiredState = $False } 
                }
            }

            $i++
        }
    }
        
    Return @{
            WimFile        = $WimFile
            ImageGroup     = $ImageGroup
            NewImageName   = $NewImageName
            NewFileName    = $NewFileName
            NewDescription = $NewDescription
            SkipVerify     = $SkipVerify
            DesiredState   = $DesiredState
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
        [string]$NewImageName,

        [Parameter(Mandatory=$False)]
        [string]$NewFileName,

        [Parameter(Mandatory=$False)]
        [string]$NewDescription,

        [Parameter(Mandatory=$False)]
        [string]$SecuritySDDL,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = (Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue) -ne $Null
    If (!($Test)) { New-WdsInstallImageGroup -Name $ImageGroup }

    $Images = Get-WindowsImage -ImagePath $WimFile

    $i = 1
    Foreach ($Image in $Images) { 

        $Parameters = @{ 'Path' = $WimFile ; 'ImageGroup' = $ImageGroup ; 'ImageName' = $Image.ImageName }
    
        If ($PSBoundParameters.ContainsKey('NewImageName')) { 
            If ($i -eq 1) { $ImageName = $NewImageName } 
            Else { $ImageName = "${NewImageName}-$i" }
            $Parameters.Add('NewImageName',$ImageName)
        }
        Else { $ImageName = $Image.ImageName }
    
        $Test = (Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName) -ne $Null

        If (!($Test)) {
        
            If ($PSBoundParameters.ContainsKey('NewFilename')) { 
                If ($i -eq 1) { $FileName = "$NewFilename.wim" } 
                Else { $FileName = "${NewFilename}-$i.wim" }
                $Parameters.Add('NewFileName',$FileName)
            }

            If ($PSBoundParameters.ContainsKey('NewDescription')) { 
                $Parameters.Add('NewDescription',$NewDescription)
            }

            $Parameters.Add('SkipVerify',$SkipVerify)

            Import-WdsInstallImage @Parameters

        }

        $ImportedImage = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName

        If ($PSBoundParameters.ContainsKey('SecuritySDDL')) { 
            If ($ImportedImage.Security -cne $SecuritySDDL) { Set-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName -UserFilter $SecuritySDDL } 
        }
    
        If ($PSBoundParameters.ContainsKey('NewDescription')) { 
            If ($ImportedImage.Description -cne $NewDescription) { Set-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName -NewDescription $NewDescription } 
        }

        $i++
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
        [string]$NewImageName,

        [Parameter(Mandatory=$False)]
        [string]$NewFileName,

        [Parameter(Mandatory=$False)]
        [string]$NewDescription,

        [Parameter(Mandatory=$False)]
        [string]$SecuritySDDL,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = (Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue) -ne $Null
    If (!($Test)) { Return $False }

    $Images = Get-WindowsImage -ImagePath $WimFile

    $i = 1
    Foreach ($Image in $Images) { 
    
        If ($PSBoundParameters.ContainsKey('NewImageName')) { 
            If ($i -eq 1) { $ImageName = $NewImageName } 
            Else { $ImageName = "$($NewImageName)-$i" }
        }
        Else { $ImageName = $Image.ImageName }
    
        $Test = (Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName) -ne $Null

        If (!($Test)) { Return $False }
        Else {

            $ImportedImage = Get-WdsInstallImage -ImageGroup $ImageGroup -ImageName $ImageName

            If ($PSBoundParameters.ContainsKey('SecuritySDDL')) { 
                If ($ImportedImage.Security -cne $SecuritySDDL) { Return $False } 
            }
    
            If ($PSBoundParameters.ContainsKey('NewDescription')) { 
                If ($ImportedImage.Description -cne $NewDescription) { Return $False } 
            }
        }

        $i++
    }

    Return $True
}
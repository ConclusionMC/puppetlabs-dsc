Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Template,

        [Parameter(Mandatory=$True)]
        [ValidateSet("x86", "amd64")]
        [string]$Architecture,

        [Parameter(Mandatory=$True)]
        [bool]$CheckContent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Username,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Domain,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Join_Domain,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain_User,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainUser_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainUser_Domain,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Administrator_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallImage,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallImageFile,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLabel,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ProductKey,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FirstLogonCommands,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    
    $RemoteInstallDir = (((WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'RemoteInstall location') -Split ': ')[1]

    If (!(Test-Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile")) { $DesiredState = $False }
    Elseif ($CheckContent -eq $True) {

        $Content = Get-Content -Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile"
        $ArchitectureLines = ($Content | Select-String -Pattern "processorArchitecture=") | % { $_.LineNumber - 1 }
        $UserNameLines = ($Content | Select-String -Pattern "<UserName>") | % { $_.LineNumber - 1 }
        $DomainLines = ($Content | Select-String -Pattern "<Domain>") | % { $_.LineNumber - 1 }
        $JoinDomainLines = ($Content | Select-String -Pattern "<JoinDomain>") | % { $_.LineNumber - 1 }
        $PasswordLines = ($Content | Select-String -Pattern "<Password>") | % { $_.LineNumber - 1 }

        If ($PSBoundParameters.ContainsKey('WDS_Username') -OR $PSBoundParameters.ContainsKey('WDS_Password') -OR $PSBoundParameters.ContainsKey('WDS_Domain')) {
            $WDS_Start = ($Content | Select-String -Pattern '<WindowsDeploymentServices>').LineNumber - 1
            $WDS_End = ($Content | Select-String -Pattern '</WindowsDeploymentServices>').LineNumber - 1
        }
    
        If ($PSBoundParameters.ContainsKey('Join_Domain') -OR $PSBoundParameters.ContainsKey('Domain_User') -OR $PSBoundParameters.ContainsKey('DomainUser_Password') -OR $PSBoundParameters.ContainsKey('DomainUser_Domain')) {
            $Domain_Start = ($Content | Select-String -Pattern '<Identification>') | % { $_.LineNumber - 1 }
            $Domain_End = ($Content | Select-String -Pattern '</Identification>') | % { $_.LineNumber - 1 }
        }

        If ($PSBoundParameters.ContainsKey('Administrator_Password')) {
            $AdminPwd_Start = ($Content | Select-String -Pattern '<AdministratorPassword>').LineNumber - 1
            $AdminPwd_End = ($Content | Select-String -Pattern '</AdministratorPassword>').LineNumber - 1
        }

        Foreach ($Line in $ArchitectureLines) {
            $Set_Architecture = (($Content[$Line] -split 'processorArchitecture="')[1] -split '"')[0].Trim()
            If ($Set_Architecture -ne $Architecture) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('WDS_Username')) {
            $WDS_UserLine = $UserNameLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_User = (($Content[$WDS_UserLine] -split '<UserName>')[1] -split '</UserName>')[0].Trim()
            If ($Set_WDS_User -ne $WDS_Username) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('WDS_Domain')) {
            $WDS_DomainLine = $DomainLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_Domain = (($Content[$WDS_DomainLine] -split '<Domain>')[1] -split '</Domain>')[0].Trim()
            If ($Set_WDS_Domain -ne $WDS_Domain) { $DesiredState = $False }
        }
    
        If ($PSBoundParameters.ContainsKey('WDS_Password')) {
            $WDS_PasswordLine = $PasswordLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_Pwd = (($Content[$WDS_PasswordLine] -split '<Password>')[1] -split '</Password>')[0].Trim()
            If ($Set_WDS_Pwd -ne $WDS_Password) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('Join_Domain')) {
            $JoinDomainLine = $JoinDomainLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_JoinDomain = (($Content[$JoinDomainLine] -split '<JoinDomain>')[1] -split '</JoinDomain>')[0].Trim()
            If ($Set_JoinDomain -ne $Join_Domain) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('Domain_User')) {
            $Domain_UserLine = $UserNameLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_Domain_User = (($Content[$Domain_UserLine] -split '<UserName>')[1] -split '</UserName>')[0].Trim()
            If ($Set_Domain_User -ne $Domain_User) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('DomainUser_Password')) {
            $Domain_PasswordLine = $PasswordLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_Domain_Pwd = (($Content[$Domain_PasswordLine] -split '<Password>')[1] -split '</Password>')[0].Trim()
            If ($Set_Domain_Pwd -ne $DomainUser_Password) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('DomainUser_Domain')) {
            $DomainUser_DomainLine = $DomainLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_DomainUser_Domain = (($Content[$DomainUser_DomainLine] -split '<Domain>')[1] -split '</Domain>')[0].Trim()
            If ($Set_DomainUser_Domain -ne $DomainUser_Domain) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('Administrator_Password')) {
            $Administrator_PasswordLine = (($Content | Select-String -Pattern '<Value>') | ? { (($_.LineNumber - 1) -gt $AdminPwd_Start) -AND (($_.LineNumber - 1) -lt $AdminPwd_End) }).LineNumber - 1
            $Set_Pwd = (($Content[$Administrator_PasswordLine] -split '<Value>')[1] -split '</Value>')[0].Trim()
            If ($Set_Pwd -ne $Administrator_Password) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('InstallImage')) {
            $Image_NameLine = ($Content | Select-String -Pattern '<ImageName>').LineNumber - 1
            $Set_ImageName = (($Content[$Image_NameLine] -split '<ImageName>')[1] -split '</ImageName>')[0].Trim()
            If ($Set_ImageName -ne $InstallImage) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('ImageGroup')) {
            $Image_GroupLine = ($Content | Select-String -Pattern '<ImageGroup>').LineNumber - 1
            $Set_ImageGroup = (($Content[$Image_GroupLine] -split '<ImageGroup>')[1] -split '</ImageGroup>')[0].Trim()
            If ($Set_ImageGroup -ne $ImageGroup) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('InstallImageFile')) {
            $Image_FileLine = ($Content | Select-String -Pattern '<FileName>').LineNumber - 1
            $Set_ImageFile = (($Content[$Image_FileLine] -split '<FileName>')[1] -split '</FileName>')[0].Trim()
            If ($Set_ImageFile -ne $InstallImageFile) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('DriveLabel')) {
            $Drive_LabelLine = ($Content | Select-String -Pattern '<Label>').LineNumber - 1
            $Set_DriveLabel = (($Content[$Drive_LabelLine] -split '<Label>')[1] -split '</Label>')[0].Trim()
            If ($Set_DriveLabel -ne $DriveLabel) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('ProductKey')) {
            $ProductKeyLine = ($Content | Select-String -Pattern '<ProductKey>').LineNumber - 1
            $Set_ProductKey = (($Content[$ProductKeyLine] -split '<ProductKey>')[1] -split '</ProductKey>')[0].Trim()
            If ($Set_ProductKey -ne $ProductKey) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('FirstLogonCommands')) {
            $TotalLines = $Content.Count
            $Commands_Start = ($Content | Select-String -Pattern '<FirstLogonCommands>').LineNumber - 1
            $Commands_End = ($Content | Select-String -Pattern '</FirstLogonCommands>').LineNumber - 1
            $Before = $Content[0..($Commands_Start - 1)]
            $After = $Content[($Commands_End + 1)..($TotalLines - 1)]
            $Current = $Content[$Commands_Start..$Commands_End]

            $ToSet = $FirstLogonCommands | % {
                $Split = $_ -split ';' 
                New-Object PsObject -Property @{
                    Order = [int]$Split[0]
                    Desc = $Split[1]
                    ReqInput = $Split[2]
                    Command = $Split[3]
                }
            }

            $Required = @()
            $Required += '            <FirstLogonCommands>'
            Foreach ($Command in $ToSet) {
                $Required += '                <SynchronousCommand wcm:action="add">'
                $Required += "                    <CommandLine>$($Command.Command)</CommandLine>"
                $Required += "                    <Description>$($Command.Desc)</Description>"
                $Required += "                    <Order>$($Command.Order)</Order>"
                $Required += "                    <RequiresUserInput>$($Command.ReqInput)</RequiresUserInput>"
                $Required += "                </SynchronousCommand>"
            }
            $Required += "            </FirstLogonCommands>"
            $Test = Compare-Object -ReferenceObject $Required -DifferenceObject $Current -CaseSensitive

            If($Test -ne $Null) { $DesiredState = $False }
        }
    }
    
    Return @{  
        UnattendFile           = $UnattendFile
        Template               = $Template
        Architecture           = $Architecture
        WDS_Username           = $WDS_Username
        WDS_Domain             = $WDS_Domain
        WDS_Password           = $WDS_Password
        Join_Domain            = $Join_Domain
        Domain_User            = $Domain_User
        Domain_Password        = $Domain_Password
        Administrator_Password = $Administrator_Password
        InstallImage           = $InstallImage
        ImageGroup             = $ImageGroup
        InstallImageFile       = $InstallImageFile
        DriveLabel             = $DriveLabel
        ProductKey             = $ProductKey
        FirstLogonCommands     = $FirstLogonCommands
        DesiredState           = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Template,

        [Parameter(Mandatory=$True)]
        [ValidateSet("x86", "amd64")]
        [string]$Architecture,

        [Parameter(Mandatory=$True)]
        [bool]$CheckContent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Username,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Domain,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Join_Domain,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain_User,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainUser_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainUser_Domain,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Administrator_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallImage,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallImageFile,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLabel,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ProductKey,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FirstLogonCommands,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $RemoteInstallDir = (((WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'RemoteInstall location') -Split ': ')[1]

    If (!(Test-Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile")) { Copy-Item -Path $Template -Destination "$RemoteInstallDir\WdsClientUnattend\$UnattendFile" ; $NewFile = $True }
    Else { $NewFile = $False }

    If ( ($CheckContent -eq $True) -OR ($NewFile -eq $True)  ) {

        $Update = $False

        $Content = Get-Content -Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile"
        $ArchitectureLines = ($Content | Select-String -Pattern "processorArchitecture=") | % { $_.LineNumber - 1 }
        $UserNameLines = ($Content | Select-String -Pattern "<UserName>") | % { $_.LineNumber - 1 }
        $DomainLines = ($Content | Select-String -Pattern "<Domain>") | % { $_.LineNumber - 1 }
        $JoinDomainLines = ($Content | Select-String -Pattern "<JoinDomain>") | % { $_.LineNumber - 1 }
        $PasswordLines = ($Content | Select-String -Pattern "<Password>") | % { $_.LineNumber - 1 }

        If ($PSBoundParameters.ContainsKey('WDS_Username') -OR $PSBoundParameters.ContainsKey('WDS_Password') -OR $PSBoundParameters.ContainsKey('WDS_Domain')) {
            $WDS_Start = ($Content | Select-String -Pattern '<WindowsDeploymentServices>').LineNumber - 1
            $WDS_End = ($Content | Select-String -Pattern '</WindowsDeploymentServices>').LineNumber - 1
        }
    
        If ($PSBoundParameters.ContainsKey('Join_Domain') -OR $PSBoundParameters.ContainsKey('Domain_User') -OR $PSBoundParameters.ContainsKey('DomainUser_Password') -OR $PSBoundParameters.ContainsKey('DomainUser_Domain')) {
            $Domain_Start = ($Content | Select-String -Pattern '<Identification>') | % { $_.LineNumber - 1 }
            $Domain_End = ($Content | Select-String -Pattern '</Identification>') | % { $_.LineNumber - 1 }
        }

        If ($PSBoundParameters.ContainsKey('Administrator_Password')) {
            $AdminPwd_Start = ($Content | Select-String -Pattern '<AdministratorPassword>').LineNumber - 1
            $AdminPwd_End = ($Content | Select-String -Pattern '</AdministratorPassword>').LineNumber - 1
        }

        Foreach ($Line in $ArchitectureLines) {
            $Set_Architecture = (($Content[$Line] -split 'processorArchitecture="')[1] -split '"')[0].Trim()
            If ($Set_Architecture -ne $Architecture) { $Content[$Line] = $Content[$Line].Replace($Set_Architecture,$Architecture) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('WDS_Username')) {
            $WDS_UserLine = $UserNameLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_User = (($Content[$WDS_UserLine] -split '<UserName>')[1] -split '</UserName>')[0].Trim()
            If ($Set_WDS_User -ne $WDS_Username) { $Content[$WDS_UserLine] = $Content[$WDS_UserLine].Replace($Set_WDS_User,$WDS_Username) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('WDS_Domain')) {
            $WDS_DomainLine = $DomainLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_Domain = (($Content[$WDS_DomainLine] -split '<Domain>')[1] -split '</Domain>')[0].Trim()
            If ($Set_WDS_Domain -ne $WDS_Domain) { $Content[$WDS_DomainLine] = $Content[$WDS_DomainLine].Replace($Set_WDS_Domain,$WDS_Domain) ; $Update = $True }
        }
    
        If ($PSBoundParameters.ContainsKey('WDS_Password')) {
            $WDS_PasswordLine = $PasswordLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_Pwd = (($Content[$WDS_PasswordLine] -split '<Password>')[1] -split '</Password>')[0].Trim()
            If ($Set_WDS_Pwd -ne $WDS_Password) { $Content[$WDS_PasswordLine] = $Content[$WDS_PasswordLine].Replace($Set_WDS_Pwd,$WDS_Password) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('Join_Domain')) {
            $JoinDomainLine = $JoinDomainLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_JoinDomain = (($Content[$JoinDomainLine] -split '<JoinDomain>')[1] -split '</JoinDomain>')[0].Trim()
            If ($Set_JoinDomain -ne $Join_Domain) { $Content[$JoinDomainLine] = $Content[$JoinDomainLine].Replace($Set_JoinDomain,$Join_Domain) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('Domain_User')) {
            $Domain_UserLine = $UserNameLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_Domain_User = (($Content[$Domain_UserLine] -split '<UserName>')[1] -split '</UserName>')[0].Trim()
            If ($Set_Domain_User -ne $Domain_User) { $Content[$Domain_UserLine] = $Content[$Domain_UserLine].Replace($Set_Domain_User,$Domain_User) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('DomainUser_Password')) {
            $Domain_PasswordLine = $PasswordLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_Domain_Pwd = (($Content[$Domain_PasswordLine] -split '<Password>')[1] -split '</Password>')[0].Trim()
            If ($Set_Domain_Pwd -ne $DomainUser_Password) { $Content[$Domain_PasswordLine] = $Content[$Domain_PasswordLine].Replace($Set_Domain_Pwd,$DomainUser_Password) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('DomainUser_Domain')) {
            $DomainUser_DomainLine = $DomainLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_DomainUser_Domain = (($Content[$DomainUser_DomainLine] -split '<Domain>')[1] -split '</Domain>')[0].Trim()
            If ($Set_DomainUser_Domain -ne $DomainUser_Domain) { $Content[$DomainUser_DomainLine] = $Content[$DomainUser_DomainLine].Replace($Set_DomainUser_Domain,$DomainUser_Domain) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('Administrator_Password')) {
            $Administrator_PasswordLine = (($Content | Select-String -Pattern '<Value>') | ? { (($_.LineNumber - 1) -gt $AdminPwd_Start) -AND (($_.LineNumber - 1) -lt $AdminPwd_End) }).LineNumber - 1
            $Set_Pwd = (($Content[$Administrator_PasswordLine] -split '<Value>')[1] -split '</Value>')[0].Trim()
            If ($Set_Pwd -ne $Administrator_Password) { $Content[$Administrator_PasswordLine] = $Content[$Administrator_PasswordLine].Replace($Set_Pwd,$Administrator_Password) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('InstallImage')) {
            $Image_NameLine = ($Content | Select-String -Pattern '<ImageName>').LineNumber - 1
            $Set_ImageName = (($Content[$Image_NameLine] -split '<ImageName>')[1] -split '</ImageName>')[0].Trim()
            If ($Set_ImageName -ne $InstallImage) { $Content[$Image_NameLine] = $Content[$Image_NameLine].Replace($Set_ImageName,$InstallImage) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('ImageGroup')) {
            $Image_GroupLine = ($Content | Select-String -Pattern '<ImageGroup>').LineNumber - 1
            $Set_ImageGroup = (($Content[$Image_GroupLine] -split '<ImageGroup>')[1] -split '</ImageGroup>')[0].Trim()
            If ($Set_ImageGroup -ne $ImageGroup) { $Content[$Image_GroupLine] = $Content[$Image_GroupLine].Replace($Set_ImageGroup,$ImageGroup) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('InstallImageFile')) {
            $Image_FileLine = ($Content | Select-String -Pattern '<FileName>').LineNumber - 1
            $Set_ImageFile = (($Content[$Image_FileLine] -split '<FileName>')[1] -split '</FileName>')[0].Trim()
            If ($Set_ImageFile -ne $InstallImageFile) { $Content[$Image_FileLine] = $Content[$Image_FileLine].Replace($Set_ImageFile,$InstallImageFile) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('DriveLabel')) {
            $Drive_LabelLine = ($Content | Select-String -Pattern '<Label>').LineNumber - 1
            $Set_DriveLabel = (($Content[$Drive_LabelLine] -split '<Label>')[1] -split '</Label>')[0].Trim()
            If ($Set_DriveLabel -ne $DriveLabel) { $Content[$Drive_LabelLine] = $Content[$Drive_LabelLine].Replace($Set_DriveLabel,$DriveLabel) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('ProductKey')) {
            $ProductKeyLine = ($Content | Select-String -Pattern '<ProductKey>').LineNumber - 1
            $Set_ProductKey = (($Content[$ProductKeyLine] -split '<ProductKey>')[1] -split '</ProductKey>')[0].Trim()
            If ($Set_ProductKey -ne $ProductKey) { $Content[$ProductKeyLine] = $Content[$ProductKeyLine].Replace($Set_ProductKey,$ProductKey) ; $Update = $True }
        }

        If ($PSBoundParameters.ContainsKey('FirstLogonCommands')) {
            $TotalLines = $Content.Count
            $Commands_Start = ($Content | Select-String -Pattern '<FirstLogonCommands>').LineNumber - 1
            $Commands_End = ($Content | Select-String -Pattern '</FirstLogonCommands>').LineNumber - 1
            $Before = $Content[0..($Commands_Start - 1)]
            $After = $Content[($Commands_End + 1)..($TotalLines - 1)]
            $Current = $Content[$Commands_Start..$Commands_End]

            $ToSet = $FirstLogonCommands | % {
                $Split = $_ -split ';' 
                New-Object PsObject -Property @{
                    Order = [int]$Split[0]
                    Desc = $Split[1]
                    ReqInput = $Split[2]
                    Command = $Split[3]
                }
            }

            $Required = @()
            $Required += '            <FirstLogonCommands>'
            Foreach ($Command in $ToSet) {
                $Required += '                <SynchronousCommand wcm:action="add">'
                $Required += "                    <CommandLine>$($Command.Command)</CommandLine>"
                $Required += "                    <Description>$($Command.Desc)</Description>"
                $Required += "                    <Order>$($Command.Order)</Order>"
                $Required += "                    <RequiresUserInput>$($Command.ReqInput)</RequiresUserInput>"
                $Required += "                </SynchronousCommand>"
            }
            $Required += "            </FirstLogonCommands>"
            $Test = Compare-Object -ReferenceObject $Required -DifferenceObject $Current -CaseSensitive

            If($Test -ne $Null) { $Content = $Before + $Required + $After ; $Update = $True }
        }

        If ($Update) { $Content | Set-Content -Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile" }

    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Template,

        [Parameter(Mandatory=$True)]
        [ValidateSet("x86", "amd64")]
        [string]$Architecture,

        [Parameter(Mandatory=$True)]
        [bool]$CheckContent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Username,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Domain,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WDS_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Join_Domain,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain_User,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainUser_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainUser_Domain,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Administrator_Password,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallImage,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallImageFile,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLabel,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ProductKey,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FirstLogonCommands,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $RemoteInstallDir = (((WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'RemoteInstall location') -Split ': ')[1]

    If (!(Test-Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile")) { Return $False }

    If ($CheckContent -eq $True) {

        $Content = Get-Content -Path "$RemoteInstallDir\WdsClientUnattend\$UnattendFile"
        $ArchitectureLines = ($Content | Select-String -Pattern "processorArchitecture=") | % { $_.LineNumber - 1 }
        $UserNameLines = ($Content | Select-String -Pattern "<UserName>") | % { $_.LineNumber - 1 }
        $DomainLines = ($Content | Select-String -Pattern "<Domain>") | % { $_.LineNumber - 1 }
        $JoinDomainLines = ($Content | Select-String -Pattern "<JoinDomain>") | % { $_.LineNumber - 1 }
        $PasswordLines = ($Content | Select-String -Pattern "<Password>") | % { $_.LineNumber - 1 }

        If ($PSBoundParameters.ContainsKey('WDS_Username') -OR $PSBoundParameters.ContainsKey('WDS_Password') -OR $PSBoundParameters.ContainsKey('WDS_Domain')) {
            $WDS_Start = ($Content | Select-String -Pattern '<WindowsDeploymentServices>').LineNumber - 1
            $WDS_End = ($Content | Select-String -Pattern '</WindowsDeploymentServices>').LineNumber - 1
        }
    
        If ($PSBoundParameters.ContainsKey('Join_Domain') -OR $PSBoundParameters.ContainsKey('Domain_User') -OR $PSBoundParameters.ContainsKey('DomainUser_Password') -OR $PSBoundParameters.ContainsKey('DomainUser_Domain')) {
            $Domain_Start = ($Content | Select-String -Pattern '<Identification>') | % { $_.LineNumber - 1 }
            $Domain_End = ($Content | Select-String -Pattern '</Identification>') | % { $_.LineNumber - 1 }
        }

        If ($PSBoundParameters.ContainsKey('Administrator_Password')) {
            $AdminPwd_Start = ($Content | Select-String -Pattern '<AdministratorPassword>').LineNumber - 1
            $AdminPwd_End = ($Content | Select-String -Pattern '</AdministratorPassword>').LineNumber - 1
        }

        Foreach ($Line in $ArchitectureLines) {
            $Set_Architecture = (($Content[$Line] -split 'processorArchitecture="')[1] -split '"')[0].Trim()
            If ($Set_Architecture -ne $Architecture) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('WDS_Username')) {
            $WDS_UserLine = $UserNameLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_User = (($Content[$WDS_UserLine] -split '<UserName>')[1] -split '</UserName>')[0].Trim()
            If ($Set_WDS_User -ne $WDS_Username) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('WDS_Domain')) {
            $WDS_DomainLine = $DomainLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_Domain = (($Content[$WDS_DomainLine] -split '<Domain>')[1] -split '</Domain>')[0].Trim()
            If ($Set_WDS_Domain -ne $WDS_Domain) { Return $False }
        }
    
        If ($PSBoundParameters.ContainsKey('WDS_Password')) {
            $WDS_PasswordLine = $PasswordLines | ? { ($_ -gt $WDS_Start) -AND ($_ -lt $WDS_End) }
            $Set_WDS_Pwd = (($Content[$WDS_PasswordLine] -split '<Password>')[1] -split '</Password>')[0].Trim()
            If ($Set_WDS_Pwd -ne $WDS_Password) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('Join_Domain')) {
            $JoinDomainLine = $JoinDomainLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_JoinDomain = (($Content[$JoinDomainLine] -split '<JoinDomain>')[1] -split '</JoinDomain>')[0].Trim()
            If ($Set_JoinDomain -ne $Join_Domain) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('Domain_User')) {
            $Domain_UserLine = $UserNameLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_Domain_User = (($Content[$Domain_UserLine] -split '<UserName>')[1] -split '</UserName>')[0].Trim()
            If ($Set_Domain_User -ne $Domain_User) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('DomainUser_Password')) {
            $Domain_PasswordLine = $PasswordLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_Domain_Pwd = (($Content[$Domain_PasswordLine] -split '<Password>')[1] -split '</Password>')[0].Trim()
            If ($Set_Domain_Pwd -ne $DomainUser_Password) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('DomainUser_Domain')) {
            $DomainUser_DomainLine = $DomainLines | ? { ($_ -gt $Domain_Start) -AND ($_ -lt $Domain_End) }
            $Set_DomainUser_Domain = (($Content[$DomainUser_DomainLine] -split '<Domain>')[1] -split '</Domain>')[0].Trim()
            If ($Set_DomainUser_Domain -ne $DomainUser_Domain) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('Administrator_Password')) {
            $Administrator_PasswordLine = (($Content | Select-String -Pattern '<Value>') | ? { (($_.LineNumber - 1) -gt $AdminPwd_Start) -AND (($_.LineNumber - 1) -lt $AdminPwd_End) }).LineNumber - 1
            $Set_Pwd = (($Content[$Administrator_PasswordLine] -split '<Value>')[1] -split '</Value>')[0].Trim()
            If ($Set_Pwd -ne $Administrator_Password) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('InstallImage')) {
            $Image_NameLine = ($Content | Select-String -Pattern '<ImageName>').LineNumber - 1
            $Set_ImageName = (($Content[$Image_NameLine] -split '<ImageName>')[1] -split '</ImageName>')[0].Trim()
            If ($Set_ImageName -ne $InstallImage) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('ImageGroup')) {
            $Image_GroupLine = ($Content | Select-String -Pattern '<ImageGroup>').LineNumber - 1
            $Set_ImageGroup = (($Content[$Image_GroupLine] -split '<ImageGroup>')[1] -split '</ImageGroup>')[0].Trim()
            If ($Set_ImageGroup -ne $ImageGroup) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('InstallImageFile')) {
            $Image_FileLine = ($Content | Select-String -Pattern '<FileName>').LineNumber - 1
            $Set_ImageFile = (($Content[$Image_FileLine] -split '<FileName>')[1] -split '</FileName>')[0].Trim()
            If ($Set_ImageFile -ne $InstallImageFile) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('DriveLabel')) {
            $Drive_LabelLine = ($Content | Select-String -Pattern '<Label>').LineNumber - 1
            $Set_DriveLabel = (($Content[$Drive_LabelLine] -split '<Label>')[1] -split '</Label>')[0].Trim()
            If ($Set_DriveLabel -ne $DriveLabel) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('ProductKey')) {
            $ProductKeyLine = ($Content | Select-String -Pattern '<ProductKey>').LineNumber - 1
            $Set_ProductKey = (($Content[$ProductKeyLine] -split '<ProductKey>')[1] -split '</ProductKey>')[0].Trim()
            If ($Set_ProductKey -ne $ProductKey) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('FirstLogonCommands')) {
            $TotalLines = $Content.Count
            $Commands_Start = ($Content | Select-String -Pattern '<FirstLogonCommands>').LineNumber - 1
            $Commands_End = ($Content | Select-String -Pattern '</FirstLogonCommands>').LineNumber - 1
            $Before = $Content[0..($Commands_Start - 1)]
            $After = $Content[($Commands_End + 1)..($TotalLines - 1)]
            $Current = $Content[$Commands_Start..$Commands_End]

            $ToSet = $FirstLogonCommands | % {
                $Split = $_ -split ';' 
                New-Object PsObject -Property @{
                    Order = [int]$Split[0]
                    Desc = $Split[1]
                    ReqInput = $Split[2]
                    Command = $Split[3]
                }
            }

            $Required = @()
            $Required += '            <FirstLogonCommands>'
            Foreach ($Command in $ToSet) {
                $Required += '                <SynchronousCommand wcm:action="add">'
                $Required += "                    <CommandLine>$($Command.Command)</CommandLine>"
                $Required += "                    <Description>$($Command.Desc)</Description>"
                $Required += "                    <Order>$($Command.Order)</Order>"
                $Required += "                    <RequiresUserInput>$($Command.ReqInput)</RequiresUserInput>"
                $Required += "                </SynchronousCommand>"
            }
            $Required += "            </FirstLogonCommands>"
            $Test = Compare-Object -ReferenceObject $Required -DifferenceObject $Current -CaseSensitive

            If($Test -ne $Null) { Return $False }
        }
    }
    Return $True
}
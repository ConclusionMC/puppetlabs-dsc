Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageFileName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -FileName $ImageFileName
    If ($Test -eq $Null) { Throw 'Image could not be found.' }

    If ($Test.UnattendFilePresent -eq $False) { $DesiredState = $False }
    Else {
        $RemoteInstallDir = (((WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'RemoteInstall location') -Split ': ')[1]
        $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $SourceMD5 = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes("$RemoteInstallDir\WdsClientUnattend\$UnattendFile")))
        $DestinationMD5 = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes("$RemoteInstallDir\Images\$ImageGroup\$($ImageFileName -replace '.wim','')\Unattend\ImageUnattend.xml")))

        If ($SourceMD5 -ne $DestinationMD5) { $DesiredState = $False }    
    }
  
    Return @{
        ImageFileName = $ImageFileName
        ImageGroup = $ImageGroup
        RemoteInstallDir = $RemoteInstallDir
        UnattendFile = $UnattendFile  
        DesiredState = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageFileName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -FileName $ImageFileName
    If ($Test -eq $Null) { Throw 'Image could not be found.' }
    $RemoteInstallDir = (((WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'RemoteInstall location') -Split ': ')[1]

    If ($Test.UnattendFilePresent -eq $False) {
       $Test | Set-WdsInstallImage -UnattendFile "$RemoteInstallDir\WdsClientUnattend\$UnattendFile"
    }
    Else {
        $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $SourceMD5 = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes("$RemoteInstallDir\WdsClientUnattend\$UnattendFile")))
        $DestinationMD5 = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes("$RemoteInstallDir\Images\$ImageGroup\$($ImageFileName -replace '.wim','')\Unattend\ImageUnattend.xml")))

        If ($SourceMD5 -ne $DestinationMD5) {
            $Test | Set-WdsInstallImage -UnattendFile "$RemoteInstallDir\WdsClientUnattend\$UnattendFile" -OverwriteUnattend
        }    
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageFileName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsInstallImage -ImageGroup $ImageGroup -FileName $ImageFileName
    If ($Test -eq $Null) { Throw 'Image could not be found.' }

    If ($Test.UnattendFilePresent -eq $False) { Return $False }
    Else {
        $RemoteInstallDir = (((WdsUtil /Get-Server /Show:Config) | Select-String -Pattern 'RemoteInstall location') -Split ': ')[1]
        $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $SourceMD5 = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes("$RemoteInstallDir\WdsClientUnattend\$UnattendFile")))
        $DestinationMD5 = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes("$RemoteInstallDir\Images\$ImageGroup\$($ImageFileName -replace '.wim','')\Unattend\ImageUnattend.xml")))

        If ($SourceMD5 -ne $DestinationMD5) { Return $False }    
    }

    Return $True

}
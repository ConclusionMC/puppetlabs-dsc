Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GPOName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupGUID,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkDir,

        [Parameter(Mandatory=$False)]
        [bool]$CreateGPO = $True,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    If ((Test-Path -Path "$WorkDir\Detected_Changes") -eq $False) { $DesiredState = $False }

    $BackupGUID = $BackupGUID.Replace('{','').Replace('}','')

    $GPO = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue

    If ($GPO -eq $Null) { $DesiredState = $False }
    Else {

        If (Test-Path -Path "$WorkDir\$GPOName.xml") {
            $CurrentStatus = Import-Clixml -Path "$WorkDir\$GPOName.xml" 
        } Else {
            $CurrentStatus = New-Object -TypeName PsObject -Property @{
                GPOCreationDate = $GPO.CreationTime
                ModificationTime = $GPO.ModificationTime
                GPOID = $GPO.Id
                Imported = $False
                ImportedGUID = $Null   
                ImportedAt = $Null 
            }
        }

        If ($CurrentStatus.Imported -eq $False) { $DesiredState = $False }
        Elseif (($CurrentStatus.ModificationTime -ne $GPO.ModificationTime) -OR ($CurrentStatus.ImportedGUID -ne $BackupGUID)) { $DesiredState = $False }

    }
    
    Return @{
        GPOName       = $GPOName
        BackupGUID    = $BackupGUID
        BackupPath    = $BackupPath
        WorkDir       = $WorkDir
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GPOName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupGUID,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkDir,

        [Parameter(Mandatory=$False)]
        [bool]$CreateGPO = $True,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ((Test-Path -Path "$WorkDir\Detected_Changes") -eq $False) { New-Item -Path "$WorkDir\Detected_Changes" -ItemType Directory -Force }

    $BackupGUID = $BackupGUID.Replace('{','').Replace('}','')

    $GPO = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue

    If (($CreateGPO -eq $True) -AND ($GPO -eq $Null)) { $GPO = New-GPO -Name $GPOName }
    Elseif ($GPO -eq $Null) { Throw 'GPO does not exist and the CreateGPO parameter was set to false.' }

    If (Test-Path -Path "$WorkDir\$GPOName.xml") {
        $CurrentStatus = Import-Clixml -Path "$WorkDir\$GPOName.xml" 
    } Else {
        $CurrentStatus = New-Object -TypeName PsObject -Property @{
            GPOCreationDate = $GPO.CreationTime
            ModificationTime = $GPO.ModificationTime
            GPOID = $GPO.Id
            Imported = $False
            ImportedGUID = $Null   
            ImportedAt = $Null 
        }
    }

    If ($CurrentStatus.Imported -eq $False) {

        Import-GPO -BackupId $BackupGUID -Path $BackupPath -TargetGuid $GPO.Id
        $ModificationTime = (Get-GPO -Name $GPOName).ModificationTime
        $CurrentStatus.Imported = $True
        $CurrentStatus.ModificationTime = $ModificationTime
        $CurrentStatus.ImportedGUID = $BackupGUID
        $CurrentStatus.ImportedAt = $ModificationTime
        $CurrentStatus | Export-Clixml -Path "$WorkDir\$GPOName.xml"

    }
    Elseif (($CurrentStatus.ModificationTime -ne $GPO.ModificationTime) -OR ($CurrentStatus.ImportedGUID -ne $BackupGUID)) {

        If ($CurrentStatus.ModificationTime -ne $GPO.ModificationTime) {
            $Dir = (Get-Date).ToString('ddMMyyy_HHmmss')
            New-Item -Path "$WorkDir\Detected_Changes\$Dir" -ItemType Directory
            Backup-Gpo -Name $GPOName -Path "$WorkDir\Detected_Changes\$Dir" 
        }

        Import-GPO -BackupId $BackupGUID -Path $BackupPath -TargetGuid $GPO.Id
        $ModificationTime = (Get-GPO -Name $GPOName).ModificationTime
        $CurrentStatus.ModificationTime = $ModificationTime
        $CurrentStatus.ImportedGUID = $BackupGUID
        $CurrentStatus.ImportedAt = $ModificationTime
        $CurrentStatus | Export-Clixml -Path "$WorkDir\$GPOName.xml"
    }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GPOName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupGUID,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BackupPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WorkDir,

        [Parameter(Mandatory=$False)]
        [bool]$CreateGPO = $True,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ((Test-Path -Path "$WorkDir\Detected_Changes") -eq $False) { Return $False }

    $BackupGUID = $BackupGUID.Replace('{','').Replace('}','')

    $GPO = Get-GPO -Name $GPOName -ErrorAction SilentlyContinue

    If ($GPO -eq $Null) { Return $False }

    If (Test-Path -Path "$WorkDir\$GPOName.xml") {
        $CurrentStatus = Import-Clixml -Path "$WorkDir\$GPOName.xml" 
    } Else {
        $CurrentStatus = New-Object -TypeName PsObject -Property @{
            GPOCreationDate = $GPO.CreationTime
            ModificationTime = $GPO.ModificationTime
            GPOID = $GPO.Id
            Imported = $False
            ImportedGUID = $Null   
            ImportedAt = $Null 
        }
    }

    If ($CurrentStatus.Imported -eq $False) { Return $False }
    Elseif (($CurrentStatus.ModificationTime -ne $GPO.ModificationTime) -OR ($CurrentStatus.ImportedGUID -ne $BackupGUID)) { Return $False }

    Return $True
}
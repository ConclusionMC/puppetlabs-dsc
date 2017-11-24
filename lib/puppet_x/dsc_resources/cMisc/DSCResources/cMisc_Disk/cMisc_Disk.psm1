Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$Number,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLetter,

        [Parameter(Mandatory=$True)]
        [ValidateSet("GPT","MBR")]
        [string]$PartitionStyle,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$FileSystem,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Label

    )
    
    Try { $Disk = Get-Disk -Number $Number -ErrorAction Stop }
    Catch { Throw "A disk with number $Number could not be found." }

    $Online = $Disk.OperationalStatus -eq "Online"

    $Partition = $Disk | Get-Partition | Where Type -ne 'Reserved'
    $Partitioned = $Partition -ne $Null
    
    If ($Partitioned -eq $False -and $Disk.PartitionStyle -ne $PartitionStyle) { $SetPartitionStyle = $True }
    Else { $SetPartitionStyle = $False }

    If ($Partitioned) { $CorrectDriveLetter = $Partition.DriveLetter -eq $DriveLetter }
    Else { $CorrectDriveLetter = $True }

    $Volume = $Partition | Get-Volume
    $Volumed = $Volume -ne $Null    
    
    If ($Volumed) { $CorrectLabel = $Volume.FileSystemLabel -eq $Label }
    Else { $CorrectLabel = $True }

    If ($Online -eq $False -or $Partitioned -eq $False -or $CorrectDriveLetter -eq $False -or $Volumed -eq $False -or $CorrectLabel -eq $False ) {
        $DesiredState = $False
    }
    Else { $DesiredState = $True }

    Return @{
        Disk = $Disk
        Online = $Online
        Partitioned = $Partitioned
        SetPartitionStyle = $SetPartitionStyle
        CorrectDriveLetter = $CorrectDriveLetter
        Volumed = $Volumed
        CorrectLabel = $CorrectLabel
        DesiredState = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$Number,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLetter,

        [Parameter(Mandatory=$True)]
        [ValidateSet("GPT","MBR")]
        [string]$PartitionStyle,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$FileSystem,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Label

    )

    $CS = Get-TargetResource @PSBoundParameters

    If ($CS.Online -eq $False) { Write-Verbose "Bringing disk online" ; $CS.Disk | Set-Disk -IsOffline:$False }
    Write-Verbose "Making sure disk is initialized" ; $CS.Disk | Initialize-Disk -PartitionStyle $PartitionStyle -ErrorAction SilentlyContinue
    If ($CS.SetPartitionStyle -eq $True) { Write-Verbose "Setting partitionstyle" ; $CS.Disk | Set-Disk -PartitionStyle $PartitionStyle }
    If ($CS.Partitioned -eq $False) { Write-Verbose "Partitioning" ; $CS.Disk | New-Partition -UseMaximumSize -DriveLetter $DriveLetter }
    If ($CS.CorrectDriveLetter  -eq $False) { Write-Verbose "Setting driveletter" ; $CS.Disk | Get-Partition | Where Type -ne 'Reserved' | Set-Partition -NewDriveLetter $DriveLetter }
    If ($CS.Volumed -eq $False) { Write-Verbose "Creating volume" ; $CS.Disk | Get-Partition | Where Type -ne 'Reserved' | Format-Volume -FileSystem $FileSystem -NewFileSystemLabel $Label -Confirm:$False  }
    If ($CS.CorrectLabel -eq $False) { Write-Verbose "Setting file system label" ; $CS.Disk | Get-Partition | Where Type -ne 'Reserved' | Get-Volume | Set-Volume -NewFileSystemLabel $Label }
}

Function Test-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$Number,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriveLetter,

        [Parameter(Mandatory=$True)]
        [ValidateSet("GPT","MBR")]
        [string]$PartitionStyle,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$FileSystem,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Label

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
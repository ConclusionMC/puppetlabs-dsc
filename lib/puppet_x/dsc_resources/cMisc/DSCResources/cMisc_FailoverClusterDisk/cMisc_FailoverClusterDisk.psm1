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
        [string]$Label,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name

    )

    Try { $Disk = Get-Disk -Number $Number -ErrorAction Stop }
    Catch { Throw "A disk with number $Number could not be found." }
    $ClusterDisks = Get-WmiObject -Namespace "root\mscluster" -Class MSCluster_Resource -Filter "Type like 'Physical Disk'"
    $ClusterDisk = $ClusterDisks | ? { $_.PrivateProperties.DiskSignature -eq $Disk.Signature } 
    If ($ClusterDisk -ne $Null) { 
        If ($ClusterDisk.OwnerNode -eq $env:COMPUTERNAME) {
            If ($ClusterDisk.Name -ne $Name) { Return @{ DesiredState = $False } }
            Return @{ DesiredState = Check-Disk -Number $Number -DriveLetter $DriveLetter -PartitionStyle $PartitionStyle -FileSystem $FileSystem -Label $Label -ReturnBoolean }
        }
        Else { Return @{ DesiredState = $True } }
    } Else { Return @{ DesiredState = $False } }
    Return @{ DesiredState = $True }
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
        [string]$Label,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name

    )

    $Disk = Get-Disk -Number $Number -ErrorAction Stop
    $ClusterDisk = Get-WmiObject -Namespace "root\mscluster" -Class MSCluster_Resource -Filter "Type like 'Physical Disk'" | ? { $_.PrivateProperties.DiskSignature -eq $Disk.Signature } 

    If ($ClusterDisk -ne $Null) {
        If ($ClusterDisk.OwnerNode -eq $env:COMPUTERNAME) {
            If ($ClusterDisk.Name -ne $Name) { $ClusterDisk.Rename($Name) }
            Check-Disk -Number $Number -DriveLetter $DriveLetter -PartitionStyle $PartitionStyle -FileSystem $FileSystem -Label $Label
        }
    } Else {
        Check-Disk -Number $Number -DriveLetter $DriveLetter -PartitionStyle $PartitionStyle -FileSystem $FileSystem -Label $Label
        Get-ClusterAvailableDisk | Where Number -eq $Number | Add-ClusterDisk
        $ClusterDisk = Get-WmiObject -Namespace "root\mscluster" -Class MSCluster_Resource -Filter "Type like 'Physical Disk'" | ? { $_.PrivateProperties.DiskSignature -eq $Disk.Signature } 
        If ($ClusterDisk.Name -ne $Name) { $ClusterDisk.Rename($Name) }
    }
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
        [string]$Label,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}

Function Check-Disk {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [Uint32]$Number,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$DriveLetter,

        [Parameter(Mandatory=$True)]
        [ValidateSet("MBR", "GPT")]
        [String]$PartitionStyle,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$FileSystem,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$Label,

        [Parameter(Mandatory=$False)]
        [Switch]$ReturnBoolean = $False
    )    

    $Disk = Get-Disk -Number $Number
    If ($Disk.OperationalStatus -eq "Offline") { If ($ReturnBoolean) { Return $False } Else { $Disk | Set-Disk -IsOffline:$False } }
    If (-not $ReturnBoolean) { $Disk | Initialize-Disk -ErrorAction SilentlyContinue }

    $Partition = $Disk | Get-Partition | Where Type -ne 'Reserved'
    If ($Disk.PartitionStyle -ne $PartitionStyle -and $Partition.Count -eq 0) { If ($ReturnBoolean) { Return $False } Else { $Disk | Set-Disk -PartitionStyle $PartitionStyle } }
    If ($Partition.Count -eq 0) { 
        If ($ReturnBoolean) { Return $False } 
        Else {
            $Disk | New-Partition -UseMaximumSize -DriveLetter $DriveLetter | Format-Volume -FileSystem $FileSystem -NewFileSystemLabel $Label -Confirm:$False
            $Partition = $Disk | Get-Partition | Where Type -ne 'Reserved' 
        }
    }
    If ($Partition.DriveLetter -ne $DriveLetter) { If ($ReturnBoolean) { Return $False } Else { $Partition | Set-Partition -NewDriveLetter $DriveLetter } }
    $Volume = $Partition | Get-Volume
    If ($Volume -eq $Null) { If ($ReturnBoolean) { Return $False } Else { $Partition | Format-Volume -FileSystem $FileSystem -NewFileSystemLabel $Label -Confirm:$False } }
    If ($Volume.FileSystemLabel -ne $Label) { If ($ReturnBoolean) { Return $False } Else { $Volume | Set-Volume -NewFileSystemLabel $Label } }

    If ($ReturnBoolean) { Return $True }
}
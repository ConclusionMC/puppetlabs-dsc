Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InfFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("x64", "x86", "ia64")]
        [string]$Architecture,

        [Parameter(Mandatory=$False)]
        [bool]$Upgrade,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = ((WdsUtil /Get-DriverGroup /DriverGroup:$DriverGroup) | Select-String -Pattern 'group was not found.') -eq $Null
    If ($Test -eq $False) { $DesiredState = $False }
    Else{
        $InstalledPackageInfo = WdsUtil /Get-AllDriverPackages /Show:All /FilterType:DriverGroupName /Operator:Equal /Value:"$DriverGroup" /FilterType:PackageName /Operator:Equal /Value:"$PackageName" /FilterType:PackageArchitecture /Operator:Equal /Value:"$Architecture"
        $Test = ($InstalledPackageInfo | Select-String -Pattern 'packages: 0') -eq $Null
        If ($Test -eq $False) { $DesiredState = $False }
    }

    Return @{
        PackageName   = $PackageName
        InfFile       = $InfFile
        DriverGroup   = $DriverGroup
        Architecture  = $Architecture
        Upgrade       = $Upgrade
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InfFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("x64", "x86", "ia64")]
        [string]$Architecture,

        [Parameter(Mandatory=$False)]
        [bool]$Upgrade,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = ((WdsUtil /Get-DriverGroup /DriverGroup:$DriverGroup) | Select-String -Pattern 'group was not found.') -eq $Null
    If (!($Test)) { Throw 'Specified driver group was not found.' }

    $InstalledPackageInfo = WdsUtil /Get-AllDriverPackages /Show:All /FilterType:DriverGroupName /Operator:Equal /Value:"$DriverGroup" /FilterType:PackageName /Operator:Equal /Value:"$PackageName" /FilterType:PackageArchitecture /Operator:Equal /Value:"$Architecture"
    $Test = ($InstalledPackageInfo | Select-String -Pattern 'packages: 0') -eq $Null

    If ($Test -eq $False) { Import-WdsDriverPackage -Path $InfFile -GroupName $DriverGroup -Architecture $Architecture -DisplayName $PackageName }

    If ($Upgrade -eq $True) {
        $InstalledPackageInfo = WdsUtil /Get-AllDriverPackages /Show:All /FilterType:DriverGroupName /Operator:Equal /Value:"$DriverGroup" /FilterType:PackageName /Operator:Equal /Value:"$PackageName" /FilterType:PackageArchitecture /Operator:Equal /Value:"$Architecture"
        $InfVersion = ((Get-Content $InfFile | Select-String 'DriverVer=') -Split ',')[1].Trim()
        $InstalledVersion = (($InstalledPackageInfo | Select-String -Pattern "^Version") -split ': ')[1].Trim()
        If ($InstalledVersion -ne $InfVersion) { 
            $Id = (($InstalledPackageInfo | Select-String -Pattern "^Id: ") -split ': ')[1].Trim()
            WdsUtil /Remove-DriverPackage /PackageId:"$Id"
            Import-WdsDriverPackage -Path $InfFile -GroupName $DriverGroup -Architecture $Architecture -DisplayName $PackageName
        }
    }    
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PackageName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$InfFile,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("x64", "x86", "ia64")]
        [string]$Architecture,

        [Parameter(Mandatory=$False)]
        [bool]$Upgrade,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = ((WdsUtil /Get-DriverGroup /DriverGroup:$DriverGroup) | Select-String -Pattern 'group was not found.') -eq $Null
    If (!($Test)) { Throw 'Specified driver group was not found.' }

    $InstalledPackageInfo = WdsUtil /Get-AllDriverPackages /Show:All /FilterType:DriverGroupName /Operator:Equal /Value:"$DriverGroup" /FilterType:PackageName /Operator:Equal /Value:"$PackageName" /FilterType:PackageArchitecture /Operator:Equal /Value:"$Architecture"
    $Test = ($InstalledPackageInfo | Select-String -Pattern 'packages: 0') -eq $Null

    If ($Test -eq $False) { Return $False }

    If ($Upgrade -eq $True) {
        $InstalledPackageInfo = WdsUtil /Get-AllDriverPackages /Show:All /FilterType:DriverGroupName /Operator:Equal /Value:"$DriverGroup" /FilterType:PackageName /Operator:Equal /Value:"$PackageName" /FilterType:PackageArchitecture /Operator:Equal /Value:"$Architecture"
        $InfVersion = ((Get-Content $InfFile | Select-String 'DriverVer=') -Split ',')[1].Trim()
        $InstalledVersion = (($InstalledPackageInfo | Select-String -Pattern "^Version") -split ': ')[1].Trim()
        If ($InstalledVersion -ne $InfVersion) { Return $False }
    }

    Return $True
}
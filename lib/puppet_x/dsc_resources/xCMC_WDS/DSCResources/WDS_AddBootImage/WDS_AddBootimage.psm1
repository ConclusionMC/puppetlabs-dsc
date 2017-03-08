Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    
    $ImportFile = Get-Item $WimFile
    $Test = Get-WdsBootImage | Where Name -eq $ImportFile.BaseName
    If ($Test -eq $Null) { $DesiredState = $False }

    Return @{
        WimFile = $WimFile
        DesiredState = $DesiredState
    }

}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Import-WdsBootImage -Path $WimFile
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
            
    $ImportFile = Get-Item $WimFile
    $Test = Get-WdsBootImage | Where Name -eq $ImportFile.BaseName
    If ($Test -eq $Null) { Return $False }

    Return $True

}
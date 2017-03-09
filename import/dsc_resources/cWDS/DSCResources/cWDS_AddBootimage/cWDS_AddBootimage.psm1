Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [string]$NewImageName,
        
        [Parameter(Mandatory=$False)]
        [string]$NewFileName,

        [Parameter(Mandatory=$False)]
        [string]$NewDescription,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsBootImage -ImageName $NewImageName
    If ($Test -eq $Null) { $DesiredState = $False }
    Else { $DesiredState = $True }


    Return @{
            WimFile        = $WimFile
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
        [string]$NewImageName,
        
        [Parameter(Mandatory=$False)]
        [string]$NewFileName,

        [Parameter(Mandatory=$False)]
        [string]$NewDescription,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Parameters = @{ 'Path' = $WimFile ; 'NewImageName' = $NewImageName ; 'SkipVerify' = $SkipVerify }
    If(!([string]::IsNullOrEmpty($NewFileName))) { $Parameters.Add('NewFileName',$NewFileName) }
    If(!([string]::IsNullOrEmpty($NewDescription))) { $Parameters.Add('NewDescription',$NewDescription) }

    Import-WdsBootImage @Parameters

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$WimFile,

        [Parameter(Mandatory=$True)]
        [string]$NewImageName,
        
        [Parameter(Mandatory=$False)]
        [string]$NewFileName,

        [Parameter(Mandatory=$False)]
        [string]$NewDescription,

        [Parameter(Mandatory=$False)]
        [bool]$SkipVerify = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsBootImage -ImageName $NewImageName
    If ($Test -eq $Null) { Return $False }
    Else { Return $True }

}
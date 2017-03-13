Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [string]$SecuritySDDL,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue

    If ($Ensure -eq 'Present') {
        If ($Test -eq $Null) { $DesiredState = $False }
        Elseif (!([string]::IsNullOrEmpty($SecuritySDDL))) { If ($Test.Security.ToString() -cne $SecuritySDDL) { $DesiredState = $False } }
        Else { $DesiredState = $True }
    }
    Elseif ($Ensure -eq 'Absent') {
        If ($Test -ne $Null) { $DesiredState = $False }
        Else { $DesiredState = $True }
    }
    
        
    Return @{
            ImageGroup   = $ImageGroup
            SecuritySDDL = $SecuritySDDL
            Ensure       = $Ensure
            DesiredState = $DesiredState
    }    
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [string]$SecuritySDDL,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue
    $Parameters = @{ 'Name' = $ImageGroup }
    if (!([string]::IsNullOrEmpty($SecuritySDDL))) { $Parameters.Add('SecurityDescriptorSDDL',$SecuritySDDL) }

    If ($Ensure -eq 'Present') {
        If ($Test -eq $Null) { New-WdsInstallImageGroup @Parameters }
        Elseif (!([string]::IsNullOrEmpty($SecuritySDDL))) { 
            If ($Test.Security.ToString() -cne $SecuritySDDL) { WdsUtil /Set-ImageGroup /ImageGroup:"$ImageGroup" /Server:Localhost /Security:"$SecuritySDDL" } 
        }
    }
    Elseif ($Ensure -eq 'Absent') {
        If ($Test -ne $Null) { Remove-WdsInstallImageGroup -Name $ImageGroup }
    }    
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ImageGroup,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [string]$SecuritySDDL,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsInstallImageGroup -Name $ImageGroup -ErrorAction SilentlyContinue
    
    If ($Ensure -eq 'Present') {
        If ($Test -eq $Null) { Return $False }
        Elseif (!([string]::IsNullOrEmpty($SecuritySDDL))) { If ($Test.Security.ToString() -cne $SecuritySDDL) { Return $False } }
        Else { Return $True }
    }
    Elseif ($Ensure -eq 'Absent') {
        If ($Test -ne $Null) { Return $False }
        Else { Return $True }
    }

}
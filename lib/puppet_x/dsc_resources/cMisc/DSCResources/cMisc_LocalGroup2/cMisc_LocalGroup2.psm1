Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [string[]]$Members,

        [Parameter(Mandatory=$False)]
        [bool]$Create = $False,

        [Parameter(Mandatory=$False)]
        [bool]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Members = $Members | % { If ($PSItem -match "\\") { $Split = $PSItem -split '\\' ; "WinNT://$($Split[0])/$($Split[1])" } Else { "WinNT://$env:COMPUTERNAME/$PSItem" } }
    $ADSI = [ADSI]("WinNT://$env:COMPUTERNAME")    
    $ADSIGroup = Try { $ADSI.Children.Find($Group,'group') ; $Exists = $True } Catch { $Exists = $False }
    $CurrentMembers = If ($Exists) { $ADSIGroup.PSBase.Invoke('members') | % { $PSItem.GetType().InvokeMember("AdsPath","GetProperty",$Null,$PSItem,$Null) } } Else { $Null }
    If ($Exists -and $Group -eq 'Administrators') { $CurrentMembers = $CurrentMembers | ? { -not $PSItem.EndsWith('/Administrator')} }
    If ($CurrentMembers -ne $Null) { $Comparison = @(Compare-Object -ReferenceObject $Members -DifferenceObject $CurrentMembers) }
    Else { $Comparison = "NoMembers" }
    Return @{
        RequiredMembers = $Members
        CurrentMembers = $CurrentMembers
        Group = $ADSIGroup
        Exists = $Exists
        Comparison = $Comparison
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [string[]]$Members,

        [Parameter(Mandatory=$False)]
        [bool]$Create = $False,

        [Parameter(Mandatory=$False)]
        [bool]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $CurrentState = Get-TargetResource @PSBoundParameters

    If     ($Create -and -not $CurrentState.Exists) { ([ADSI]"WinNT://$env:COMPUTERNAME").Create("Group","Test").SetInfo() ; $CurrentState.Group = [ADSI]("WinNT://$env:COMPUTERNAME").Children.Find($Group,'group') }
    If     ($CurrentState.Comparison -eq "NoMembers" -and $Ensure -eq "Present") { $CurrentState.RequiredMembers | % { $CurrentState.Group.Add($PSItem) } }
    Elseif ($Ensure -eq "Present") {
        $CurrentState.Comparison | Where SideIndicator -eq "<=" | Select -ExpandProperty InputObject | % { $CurrentState.Group.Add($PSItem) }
        If ($Purge) { $CurrentState.Comparison | Where SideIndicator -eq "=>" | Select -ExpandProperty InputObject | % { $CurrentState.Group.Remove($PSItem) } }
    }
    Else { $CurrentState.CurrentMembers | % { If ($PSItem -in @($CurrentState.RequiredMembers)) { $CurrentState.Group.Remove($PSItem) } } }

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Group,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [string[]]$Members,

        [Parameter(Mandatory=$False)]
        [bool]$Create = $False,

        [Parameter(Mandatory=$False)]
        [bool]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )    

    Write-Verbose "Nieuw2"
    $CurrentState = Get-TargetResource @PSBoundParameters
    
    If     ($Create -and -not $CurrentState.Exists) { Return $False }
    Elseif ($CurrentState.Comparison -eq "NoMembers" -and $Ensure -eq "Present") { Return $False }
    Elseif ($CurrentState.Comparison -eq "NoMembers" -and $Ensure -eq "Absent") { Return $True }
    Elseif ($Ensure -eq "Present") {
        If (@($CurrentState.Comparison | Where SideIndicator -eq "<=").Count -gt 0) { Return $False }
        Elseif (@($CurrentState.Comparison | Where SideIndicator -eq "=>").Count -gt 0 -and $Purge) { Return $False }
        Else { Return $True }
    }
    Else {
        If (@($CurrentState.Comparison | Where SideIndicator -eq "<=").Count -lt $CurrentState.RequiredMembers.Count) { Return $False }
        Else { Return $True }
    }
}
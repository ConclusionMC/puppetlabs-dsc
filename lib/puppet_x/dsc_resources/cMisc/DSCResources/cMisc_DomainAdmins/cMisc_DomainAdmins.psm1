Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [bool]$Purge,

        [Parameter(Mandatory=$False)]
        [string[]]$Admins = @()

    )

    $Group = Get-ADGroup -Identity 'Domain Admins'
    $Members = $Group | Get-ADGroupMember
    If ($Members.Count -ne 0) { $Comparison = Compare-Object -ReferenceObject $Members.SamAccountName -DifferenceObject $Admins }
    Else { $Comparison = Compare-Object -ReferenceObject @() -DifferenceObject $Admins }
    
    If (@($Comparison).Count -gt 0) {
        $ToAdd = ($Comparison | Where SideIndicator -eq '=>').InputObject
        If ($Purge -eq $True) { $ToRemove = ($Comparison | Where SideIndicator -eq '<=').InputObject }
    }

    If ($ToAdd.Count -gt 0 -or $ToRemove.Count -gt 0) { $DesiredState = $False }
    Else { $DesiredState = $True }

    Return @{
        Group = $Group
        ToAdd = $ToAdd
        ToRemove = $ToRemove
        DesiredState = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [bool]$Purge,

        [Parameter(Mandatory=$False)]
        [string[]]$Admins = @()
        
    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    If ($CurrentState.ToAdd.Count -gt 0) { $CurrentState.Group | Add-ADGroupMember -Members $CurrentState.ToAdd }
    If ($CurrentState.ToRemove.Count -gt 0) { $CurrentState.Group | Remove-ADGroupMember -Members $CurrentState.ToRemove -Confirm:$False }

}

Function Test-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [bool]$Purge,

        [Parameter(Mandatory=$False)]
        [string[]]$Admins = @()

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
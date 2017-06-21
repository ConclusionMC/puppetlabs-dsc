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

    $CurrentGroups = (Invoke-Expression -Command "net localgroup" | Select-String "^\*").Line.Replace('*','').Trim()
    $Exists = $CurrentGroups.Contains($Group)

    If ($Ensure -eq 'Present') {
        If ($Exists -eq $False -and $Create -eq $False) { Throw "Group $Group could not be found and is not configured to be created." }
        Elseif ($Exists -eq $False -and $Create -eq $True) { $CreateGroup = $True ; $MembersToAdd = $Members }
        Else {        
            $CreateGroup = $False
            If ($PSBoundParameters.ContainsKey('Members')) {
                $CurrentGroup = Invoke-Expression -Command "net localgroup $Group"
                $CurrentMembers = ($CurrentGroup[($CurrentGroup | Select-String -Pattern '---').LineNumber..($CurrentGroup.Count - 2)]).Trim().Where{ $_ -notmatch 'the command' }
                If ((Get-WindowsFeature -Name 'AD-Domain-Services' -Verbose:$False).InstallState -eq 'Installed') {
                    $Members = $Members.Replace("$env:USERDOMAIN\",'')
                    $CurrentMembers = $CurrentMembers.Replace("$env:USERDOMAIN\",'')
                }
            
                If ($CurrentMembers.Count -eq 0) { $MembersToAdd = $Members }
                Else {
                    $Comparison = Compare-Object -ReferenceObject $CurrentMembers -DifferenceObject $Members
                    $MembersToAdd = ($Comparison | Where SideIndicator -eq '=>').InputObject
                    If ($Purge -eq $True) { $MembersToRemove = ($Comparison | Where SideIndicator -eq '<=').InputObject }
                }
            }
        }

        If ($CreateGroup -eq $False -and $MembersToAdd.Count -eq 0 -and $MembersToRemove.Count -eq 0) { $DesiredState = $True }
        Else { $DesiredState = $False }
        $Result  = @{ CreateGroup = $CreateGroup ; MembersToAdd = $MembersToAdd ; MembersToRemove = $MembersToRemove ; DesiredState = $DesiredState }
    }

    If ($Ensure -eq 'Absent') {
        If ($Exists -eq $True) { $Result  = @{ DesiredState = $False } }
        Else { $Result  = @{ DesiredState = $True } }
    }

    Return $Result

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

    If ($Ensure -eq 'Present') {
        If ($CurrentState.CreateGroup -eq $True) { net localgroup $Group /add  }
        If ($CurrentState.MembersToAdd.Count -gt 0) { 
            Foreach ($Member in $CurrentState.MembersToAdd) {
                Write-Verbose "Adding $Member to $Group"
                net localgroup $Group $Member /add ; Start-Sleep -Milliseconds 100 
            } 
        }
        If ($CurrentState.MembersToRemove.Count -gt 0) { 
            Foreach ($Member in $CurrentState.MembersToRemove) {
                Write-Verbose "Removing $Member from $Group" 
                net localgroup $Group $Member /delete ; Start-Sleep -Milliseconds 100 
            } 
        }
    }

    If ($Ensure -eq 'Absent') {
        Net localgroup $Group /delete
    }

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

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
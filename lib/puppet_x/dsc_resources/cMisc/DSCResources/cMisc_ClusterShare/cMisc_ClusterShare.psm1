Function Get-TargetResource {

    Param (

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [string[]]$FullAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ChangeAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ReadAccess = @()

    )

    If ((Get-PSCallStack).Command[1] -eq 'Test-TargetResource') { $TestResouce = $True }
    Else { $TestResouce = $False }

    $Shares = @(Get-SmbShare | Where Path -eq $Path)
    
    $Result = @{
        DesiredState = $True
        Shares = $Shares
        Actions = @()
    }

    #CreateDir
    $Exists = Test-Path $Path
    If (-not $Exists) {
        If ($TestResouce) { Return @{ DesiredState = $False } }
        Else { $Result.Actions += "CreateDir" }
    }

    #RemoveExtraShares
    If ($Shares.Count -gt 1) {
        If ($TestResouce) { Return @{ DesiredState = $False } }
        Else { $Result.Actions += "RemoveExtraShares" }
    }

    #CreateShare
    $Share = $Shares | Where Name -eq $Name
    If ($Share -eq $Null) {
        If ($TestResouce) { Return @{ DesiredState = $False } }
        Else { $Result.Actions += "CreateShare" }
    }
    
    #ConfigureAccess
    If ($Share -ne $Null) {
        $CorrectPermissions = Set-Permissions -Share $Share -FullAccess $FullAccess -ChangeAccess $ChangeAccess -ReadAccess $ReadAccess -ReturnBoolean
        If ($CorrectPermissions -eq $False) { 
            If ($TestResouce) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "ConfigureAccess" }
        }
    }

    If ($Result.Actions.Count -gt 0) { $Result.DesiredState = $False }
    If ($TestResouce) { Return @{ DesiredState = $True } }
    Return $Result
}

Function Set-TargetResource {

    Param (

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [string[]]$FullAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ChangeAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ReadAccess = @()

    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    $Actions = $CurrentState.Actions
    $Shares = $CurrentState.Shares

    Write-Host "List of actions to perform:"
    $Actions | % { Write-Host $_ }

    If ($Actions -contains 'CreateDir') { 
        Write-Host "Creating directory to share"
        Create-DirTree -Path $Path 
    }
    If ($Actions -contains 'RemoveExtraShares') { 
        Write-Host "Removing extra shares that "
        $Shares | Where Name -ne $Name | Remove-SmbShare -Force 
    }
    If ($Actions -contains 'CreateShare') { Create-SMBShare @PSBoundParameters }
    If ($Actions -contains 'ConfigureAccess') {
        If ($Actions -contains 'CreateShare') { $Share = Get-SmbShare | Where Path -eq $Path | Where Name -eq $Name }
        Else { $Share = $Shares | Where Name -eq $Name }
        Set-Permissions -Share $Share -FullAccess $FullAccess -ChangeAccess $ChangeAccess -ReadAccess $ReadAccess
    }
}

Function Test-TargetResource {

    Param (

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [string[]]$FullAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ChangeAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ReadAccess = @()

    )
    
    $DiskAvailable = Test-Path ($SplitPath = $Path -split '\\')[0]
    If (-not $DiskAvailable) { Return $True }
    Else { Return (Get-TargetResource @PSBoundParameters).DesiredState }

}

Function Create-SMBShare {

    Param (

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [string[]]$FullAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ChangeAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ReadAccess = @()

    )

    $Params = @{
        Path = $Path
        Name = $Name
    }
    If ($FullAccess.Count -gt 0) { $Params.Add('FullAccess',$FullAccess) }
    If ($ChangeAccess.Count -gt 0) { $Params.Add('ChangeAccess',$ChangeAccess) }
    If ($ReadAccess.Count -gt 0) { $Params.Add('ReadAccess',$ReadAccess) }
    
    Write-Host "Creating SMB share $Path | $Name"
    New-SmbShare @Params

}

Function Create-DirTree {

    Param (
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $SplitPath = $Path -split '\\'
    $CurrentPath = $SplitPath[0]
    $Depth = $SplitPath.Count
    Foreach ($Dir in $SplitPath[1..($Depth - 1)]) {
        $CurrentPath = "${CurrentPath}\${Dir}"
        $Exists = Test-Path $CurrentPath
        If (-not $Exists) { Write-Host "Creating $CurrentPath" ; New-Item -Path $CurrentPath -ItemType Directory }
    }
}

Function Set-Permissions {

    Param (

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [CimInstance]$Share,

        [Parameter(Mandatory=$False)]
        [string[]]$FullAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ChangeAccess = @(),

        [Parameter(Mandatory=$False)]
        [string[]]$ReadAccess = @(),

        [Parameter(Mandatory=$False)]
        [switch]$ReturnBoolean = $False

    )
    
    $Permissions = $Share | Get-SmbShareAccess | Where AccessControlType -eq 'Allow'

    $RequiredPermissions = [ordered]@{
            Read = @($ReadAccess)
            Change = @($ChangeAccess)
            Full = @($FullAccess)
    }

    $Changed = $False
    Foreach ($Permission in $RequiredPermissions.GetEnumerator()) {
        $CurrentPermissions = $Permissions | Where AccessRight -eq $Permission.Key
        
        If (($CurrentPermissions -ne $Null) -and ($Permission.Value.Count -eq 0)) {
            If ($ReturnBoolean) { Return $False }
            Else { $Changed = $True }
            $CurrentPermissions | % { Write-Host "Removing rights to $Path for $($_.AccountName)" ; Revoke-SmbShareAccess -Name $Name -AccountName $_.AccountName -Force | Out-Null }
        }

        Elseif (($CurrentPermissions -eq $Null) -and ($Permission.Value.Count -gt 0)) {
            If ($ReturnBoolean) { Return $False }
            Else { $Changed = $True }
            $Permission.Value | % { Write-Host "Granting $($Permission.Key) rights to $Path for $($_)" ; Grant-SmbShareAccess -Name $Name -AccountName $_ -AccessRight $Permission.Key -Force | Out-Null }
        }

        Elseif (($CurrentPermissions -ne $Null) -and ($Permission.Value.Count -gt 0)) {
            $Comparison = Compare-Object -ReferenceObject $CurrentPermissions.AccountName -DifferenceObject $Permission.Value
            If ($Comparison -ne $Null) {
                If ($ReturnBoolean) { Return $False }
                Else { $Changed = $True }
                    ($Comparison | Where SideIndicator -eq '<=').InputObject | % { 
                    Write-Host "Removing rights to $Path for $($_)" ; Revoke-SmbShareAccess -Name $Name -AccountName $_ -Force | Out-Null 
                } 
                    ($Comparison | Where SideIndicator -eq '=>').InputObject | % { 
                    "Granting $($Permission.Key) rights to $Path for $($_)" ; Grant-SmbShareAccess -Name $Name -AccountName $_ -AccessRight $Permission.Key -Force | Out-Null 
                }
            }
        }

        If ($Changed) { $Permissions = $Share | Get-SmbShareAccess | Where AccessControlType -eq 'Allow' }
    }

    If ($ReturnBoolean) { Return $True }
}
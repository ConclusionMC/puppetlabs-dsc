Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalUser,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$RequirePassword,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $UserInfo = Net User $LocalUser
    $CurrentRequirePassword = [string](($UserInfo | Select-String -Pattern "^Password required") -split 'required ')[1].Trim()

    If ( $CurrentRequirePassword -eq $RequirePassword ) { $DesiredState = $True }
    Else { $DesiredState = $False }

    Return @{  
        LocalUser       = $LocalUser
        RequirePassword = $RequirePassword
        DesiredState    = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalUser,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$RequirePassword,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Net User $LocalUser /Passwordreq:$RequirePassword

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$LocalUser,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$RequirePassword,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $UserInfo = Net User $LocalUser
    $CurrentRequirePassword = [string](($UserInfo | Select-String -Pattern "^Password required") -split 'required ')[1].Trim()

    If ( $CurrentRequirePassword -eq $RequirePassword ) { Return $True }
    Else { Return $False }
}
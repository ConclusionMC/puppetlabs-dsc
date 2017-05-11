Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("x64", "x86", "ia64")]
        [string]$Architecture,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootProgram,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootImage,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferralServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter(Mandatory=$False)]
        [ValidateSet("JoinOnly", "Full")]
        [string]$JoinRights,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$JoinDomain,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $PendingDevicePolicy = $WdsConfig | Select-String -Pattern 'Pending Device Policy' -Context 0,31
    $CurrentSettings = $PendingDevicePolicy.Context.PostContext | Select-String -Pattern "Defaults for $Architecture" -Context 0,7

    If ($PSBoundParameters.ContainsKey('BootProgram')) {
        $CurrentBootProgram = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'boot program path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentBootProgram)) { $CurrentBootProgram = 'Unset' }
        If ($CurrentBootProgram -ne $BootProgram) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('UnattendFile')) {
        $CurrentUnattendFile = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'unattend file path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentUnattendFile)) { $CurrentUnattendFile = 'Unset' }
        If ($CurrentUnattendFile -ne $UnattendFile) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('BootImage')) {
        $CurrentBootImage = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'boot image path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentBootImage)) { $CurrentBootImage = 'Unset' }
        If ($CurrentBootImage -ne $BootImage) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('ReferralServer')) {
        $CurrentReferralServer = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'referral server') -split ': ')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentReferralServer)) { $CurrentReferralServer = 'Unset' }
        If ($CurrentReferralServer -ne $ReferralServer) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('User')) {
        $CurrentUser = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'User') -split ': ')[1].Trim()
        $CurrentJoinRights = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Join rights') -split ': ')[1].Trim()
        If (($CurrentUser -ne $User) -OR ($CurrentJoinRights -ne $JoinRights)) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('JoinDomain')) {
        $CurrentJoinDomain = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Join domain') -split ': ')[1].Trim()
        If ($CurrentJoinDomain -ne $JoinDomain) { $DesiredState = $False }
    }
        
    Return @{
        Architecture   = $Architecture
        BootProgram    = $BootProgram
        UnattendFile   = $UnattendFile
        BootImage      = $BootImage
        ReferralServer = $ReferralServer
        User           = $User
        JoinRights     = $JoinRights
        JoinDomain     = $JoinDomain
        DesiredState   = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("x64", "x86", "ia64")]
        [string]$Architecture,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootProgram,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootImage,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferralServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter(Mandatory=$False)]
        [ValidateSet("JoinOnly", "Full")]
        [string]$JoinRights,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$JoinDomain,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $PendingDevicePolicy = $WdsConfig | Select-String -Pattern 'Pending Device Policy' -Context 0,31
    $CurrentSettings = $PendingDevicePolicy.Context.PostContext | Select-String -Pattern "Defaults for $Architecture" -Context 0,7

    If ($PSBoundParameters.ContainsKey('BootProgram')) {
        $CurrentBootProgram = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'boot program path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentBootProgram)) { $CurrentBootProgram = 'Unset' }
        If ($CurrentBootProgram -ne $BootProgram) {
            If ($BootProgram -eq 'Unset') { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /BootProgram: }
            Else { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /BootProgram:$BootProgram }
        }
    }

    If ($PSBoundParameters.ContainsKey('UnattendFile')) {
        $CurrentUnattendFile = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'unattend file path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentUnattendFile)) { $CurrentUnattendFile = 'Unset' }
        If ($CurrentUnattendFile -ne $UnattendFile) {
            If ($UnattendFile -eq 'Unset') { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /WdsClientUnattend: }
            Else { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /WdsClientUnattend:$UnattendFile }
        }
    }

    If ($PSBoundParameters.ContainsKey('BootImage')) {
        $CurrentBootImage = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'boot image path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentBootImage)) { $CurrentBootImage = 'Unset' }
        If ($CurrentBootImage -ne $BootImage) {
            If ($BootImage -eq 'Unset') { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /BootImage: }
            Else { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /BootImage:$BootImage }
        }
    }

    If ($PSBoundParameters.ContainsKey('ReferralServer')) {
        $CurrentReferralServer = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'referral server') -split ': ')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentReferralServer)) { $CurrentReferralServer = 'Unset' }
        If ($CurrentReferralServer -ne $ReferralServer) {
            If ($ReferralServer -eq 'Unset') { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /ReferralServer: }
            Else { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /ReferralServer:$ReferralServer }
        }
    }

    If ($PSBoundParameters.ContainsKey('User')) {
        If ($PSBoundParameters.ContainsKey('JoinRights')) {
            $CurrentUser = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'User') -split ': ')[1].Trim()
            $CurrentJoinRights = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Join rights') -split ': ')[1].Trim()
            If (($CurrentUser -ne $User) -OR ($CurrentJoinRights -ne $JoinRights)) { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /User:"$User" /JoinRights:$JoinRights }
        }
        Else { Throw 'The user parameter needs to used in combination with the joinrights parameter.' }
    }

    If ($PSBoundParameters.ContainsKey('JoinRights')) {
        If ($PSBoundParameters.ContainsKey('User') -eq $False) { Throw 'The joinrights parameter needs to used in combination with the user parameter.' }
    }

    If ($PSBoundParameters.ContainsKey('JoinDomain')) {
        $CurrentJoinDomain = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Join domain') -split ': ')[1].Trim()
        If ($CurrentJoinDomain -ne $JoinDomain) { WdsUtil /Set-Server /Server:Localhost /AutoAddSettings /Architecture:$Architecture /JoinDomain:$JoinDomain }
    }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("x64", "x86", "ia64")]
        [string]$Architecture,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootProgram,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$UnattendFile,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootImage,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$ReferralServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter(Mandatory=$False)]
        [ValidateSet("JoinOnly", "Full")]
        [string]$JoinRights,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$JoinDomain,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $PendingDevicePolicy = $WdsConfig | Select-String -Pattern 'Pending Device Policy' -Context 0,31
    $CurrentSettings = $PendingDevicePolicy.Context.PostContext | Select-String -Pattern "Defaults for $Architecture" -Context 0,7

    If ($PSBoundParameters.ContainsKey('BootProgram')) {
        $CurrentBootProgram = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'boot program path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentBootProgram)) { $CurrentBootProgram = 'Unset' }
        If ($CurrentBootProgram -ne $BootProgram) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('UnattendFile')) {
        $CurrentUnattendFile = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'unattend file path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentUnattendFile)) { $CurrentUnattendFile = 'Unset' }
        If ($CurrentUnattendFile -ne $UnattendFile) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('BootImage')) {
        $CurrentBootImage = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'boot image path') -split 'path:')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentBootImage)) { $CurrentBootImage = 'Unset' }
        If ($CurrentBootImage -ne $BootImage) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('ReferralServer')) {
        $CurrentReferralServer = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'referral server') -split ': ')[1].Trim()
        If ([string]::IsNullOrEmpty($CurrentReferralServer)) { $CurrentReferralServer = 'Unset' }
        If ($CurrentReferralServer -ne $ReferralServer) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('User')) {
        $CurrentUser = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'User') -split ': ')[1].Trim()
        $CurrentJoinRights = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Join rights') -split ': ')[1].Trim()
        If (($CurrentUser -ne $User) -OR ($CurrentJoinRights.Replace(' ','') -ne $JoinRights)) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('JoinDomain')) {
        $CurrentJoinDomain = (($CurrentSettings.Context.PostContext | Select-String -Pattern 'Join domain') -split ': ')[1].Trim()
        If ($CurrentJoinDomain -ne $JoinDomain) { Return $False }
    }

    Return $True
}
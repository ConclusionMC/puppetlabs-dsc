Function Get-TargetResource {

    Param(      

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$GUIDs,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    $GUIDs = $GUIDs.Replace('{','').Replace('}','')

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $StartLine = ($WdsConfig | Select-String -Pattern 'Banned GUIDS list').LineNumber
    $EndLine = ($WdsConfig | Select-String -Pattern 'Boot Image Policy').LineNumber - 2

    If ($StartLine -eq $EndLine) { $CurrentGUIDS = 'Unset' }
    Else {
        $CurrentGUIDs = $WdsConfig[$StartLine..($EndLine - 1)].Trim().Replace('{','').Replace('}','')
        $Comparison = Compare-Object -ReferenceObject $GUIDs -DifferenceObject $CurrentGUIDs
    }

    If (($GUIDs -eq 'Unset') -AND ($CurrentGUIDS -ne 'Unset')) { $DesiredState = $False }
    Elseif (($GUIDs -ne 'Unset') -AND ($CurrentGUIDS -eq 'Unset')) { $DesiredState = $False }
    Elseif ($Comparison -ne $Null) { $DesiredState = $False }

    Return @{
        GUIDs         = $GUIDs
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(  
     
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,   

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$GUIDs,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $GUIDs = $GUIDs.Replace('{','').Replace('}','')

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $StartLine = ($WdsConfig | Select-String -Pattern 'Banned GUIDS list').LineNumber
    $EndLine = ($WdsConfig | Select-String -Pattern 'Boot Image Policy').LineNumber - 2

    If ($StartLine -eq $EndLine) { $CurrentGUIDS = 'Unset' }
    Else {
        $CurrentGUIDs = $WdsConfig[$StartLine..($EndLine - 1)].Trim().Replace('{','').Replace('}','')
        $Comparison = Compare-Object -ReferenceObject $GUIDs -DifferenceObject $CurrentGUIDs
    }

    If (($GUIDs -eq 'Unset') -AND ($CurrentGUIDS -ne 'Unset')) { Foreach ($GUID in $CurrentGUIDs) { WdsUtil /Set-Server /Server:Localhost /BannedGuidPolicy /Remove /Guid:$GUID } }
    Elseif (($GUIDs -ne 'Unset') -AND ($CurrentGUIDS -eq 'Unset')) { Foreach ($GUID in $GUIDs) { WdsUtil /Set-Server /Server:Localhost /BannedGuidPolicy /Add /Guid:$GUID } }
    Elseif ($Comparison -ne $Null) {
        $ToAdd = ($Comparison | Where SideIndicator -eq '<=').InputObject
        $ToRem = ($Comparison | Where SideIndicator -eq '=>').InputObject

        Foreach ($GUID in $ToRem) { WdsUtil /Set-Server /Server:Localhost /BannedGuidPolicy /Remove /Guid:$GUID }
        Foreach ($GUID in $ToAdd) { WdsUtil /Set-Server /Server:Localhost /BannedGuidPolicy /Add /Guid:$GUID }
    }
}

Function Test-TargetResource {

    Param(    
    
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,  

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$GUIDs,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $GUIDs = $GUIDs.Replace('{','').Replace('}','')
    
    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $StartLine = ($WdsConfig | Select-String -Pattern 'Banned GUIDS list').LineNumber
    $EndLine = ($WdsConfig | Select-String -Pattern 'Boot Image Policy').LineNumber - 2

    If ($StartLine -eq $EndLine) { $CurrentGUIDS = 'Unset' }
    Else {
        $CurrentGUIDs = $WdsConfig[$StartLine..($EndLine - 1)].Trim().Replace('{','').Replace('}','')
        $Comparison = Compare-Object -ReferenceObject $GUIDs -DifferenceObject $CurrentGUIDs
    }

    If (($GUIDs -eq 'Unset') -AND ($CurrentGUIDS -ne 'Unset')) { Return $False }
    Elseif (($GUIDs -ne 'Unset') -AND ($CurrentGUIDS -eq 'Unset')) { Return $False }
    Elseif ($Comparison -ne $Null) { Return $False }

    Return $True 

}
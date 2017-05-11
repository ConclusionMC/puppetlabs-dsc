Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceID,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootImage,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$JoinDomain,

        [Parameter(Mandatory=$False)]
        [ValidateSet("OptIn","OptOut","NoPrompt","Abort")]
        [string]$PxePromptPolicy,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WdsClientUnattend,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    
    $Test = Get-WdsClient -DeviceName $DeviceName

    If ($Ensure -eq 'Present') {
        If ($Test -eq $Null) { Return $False }
    
        If ($Test.DeviceID -ne $DeviceID.Replace(':','-')) { $DesiredState = $False }

        If ($PSBoundParameters.ContainsKey('JoinDomain')) {            
            If ($Test.JoinDomain -ne $JoinDomain) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('WdsClientUnattend')) { 
            If ($Test.WdsClientUnattend -ne $WdsClientUnattend) { $DesiredState = $False  }
        }

        If ($PSBoundParameters.ContainsKey('BootImage')) { 
            If ($Test.BootImagePath -ne $BootImage) { $DesiredState = $False }
        }

        If ($PSBoundParameters.ContainsKey('PxePromptPolicy')) { 
            If ($Test.PxePromptPolicy -ne $PxePromptPolicy) { $DesiredState = $False }
        }
 
    }
    Elseif ($Ensure -eq 'Absent') { If ($Test -ne $Null) { $DesiredState = $False } }
   
    Return @{
        DeviceName        = $DeviceName
        DeviceID          = $DeviceID
        BootImage         = $BootImage
        JoinDomain        = $JoinDomain
        PxePromptPolicy   = $PxePromptPolicy
        WdsClientUnattend = $WdsClientUnattend
        DesiredState      = $DesiredState
        Ensure            = $Ensure
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceID,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootImage,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$JoinDomain,

        [Parameter(Mandatory=$False)]
        [ValidateSet("OptIn","OptOut","NoPrompt","Abort")]
        [string]$PxePromptPolicy,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WdsClientUnattend,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsClient -DeviceName $DeviceName

    If ($Ensure -eq 'Present') {
        If ($Test -eq $Null) { 
            New-WdsClient -DeviceName $DeviceName -DeviceID ($DeviceID.Replace(':','-'))
            $Test = Get-WdsClient -DeviceName $DeviceName
        }
    
        If ($Test.DeviceID -ne $DeviceID.Replace(':','-')) { Set-WdsClient -DeviceName $DeviceName -DeviceID $DeviceID }

        If ($PSBoundParameters.ContainsKey('JoinDomain')) {            
            If ($Test.JoinDomain -ne $JoinDomain) { Set-WdsClient -DeviceName $DeviceName -JoinDomain $JoinDomain }
        }

        If ($PSBoundParameters.ContainsKey('WdsClientUnattend')) { 
            If ($Test.WdsClientUnattend -ne $WdsClientUnattend) { Set-WdsClient -DeviceName $DeviceName -WdsClientUnattend $WdsClientUnattend  }
        }

        If ($PSBoundParameters.ContainsKey('BootImage')) { 
            If ($Test.BootImagePath -ne $BootImage) { Set-WdsClient -DeviceName $DeviceName -BootImagePath $BootImage }
        }

        If ($PSBoundParameters.ContainsKey('PxePromptPolicy')) { 
            If ($Test.PxePromptPolicy -ne $PxePromptPolicy) { Set-WdsClient -DeviceName $DeviceName -PxePromptPolicy $PxePromptPolicy }
        }
 
    }
    Elseif ($Ensure -eq 'Absent') { Remove-WdsClient -DeviceName $DeviceName }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceID,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$BootImage,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$JoinDomain,

        [Parameter(Mandatory=$False)]
        [ValidateSet("OptIn","OptOut","NoPrompt","Abort")]
        [string]$PxePromptPolicy,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$WdsClientUnattend,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Test = Get-WdsClient -DeviceName $DeviceName

    If ($Ensure -eq 'Present') {
        If ($Test -eq $Null) { Return $False }
    
        If ($Test.DeviceID -ne $DeviceID.Replace(':','-')) { Return $False }

        If ($PSBoundParameters.ContainsKey('JoinDomain')) {            
            If ($Test.JoinDomain -ne $JoinDomain) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('WdsClientUnattend')) { 
            If ($Test.WdsClientUnattend -ne $WdsClientUnattend) { Return $False  }
        }

        If ($PSBoundParameters.ContainsKey('BootImage')) { 
            If ($Test.BootImagePath -ne $BootImage) { Return $False }
        }

        If ($PSBoundParameters.ContainsKey('PxePromptPolicy')) { 
            If ($Test.PxePromptPolicy -ne $PxePromptPolicy) { Return $False }
        }
 
    }
    Elseif ($Ensure -eq 'Absent') { If ($Test -ne $Null) { Return $False } }
    
    Return $True
}
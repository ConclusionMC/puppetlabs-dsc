Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$NewName,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Try  { 
        $Interface = Get-NetIPInterface -InterfaceAlias $CurrentName -ErrorAction Stop
        If ($Interface -ne $Null) { Return @{ DesiredState = $False } }
    }
    Catch { 
        Try { 
            $Interface = Get-NetIPInterface -InterfaceAlias $NewName -ErrorAction Stop 
            If ($Interface -ne $Null) { Return @{ DesiredState = $True } }
        }
        Catch { Throw "No interface with alias $CurrentName or $NewName could be found." }
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$NewName,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Rename-NetAdapter -Name $CurrentName -NewName $newName
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$CurrentName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$NewName,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
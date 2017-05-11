Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OU,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$BlockInheritance,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $InheritanceBlocked = (Get-GPInheritance -Target $OU).GpoInheritanceBlocked

    If (($BlockInheritance -eq 'Yes') -AND ($InheritanceBlocked -eq $False)) { $DesiredState = $False }
    Elseif (($BlockInheritance -eq 'No') -AND ($InheritanceBlocked -eq $True)) { $DesiredState = $False }

    Return @{
        OU = $OU
        BlockInheritance = $BlockInheritance
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OU,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$BlockInheritance,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Set-GPInheritance -Target $OU -IsBlocked $BlockInheritance

}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OU,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes","No")]
        [string]$BlockInheritance,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $InheritanceBlocked = (Get-GPInheritance -Target $OU).GpoInheritanceBlocked

    If (($BlockInheritance -eq 'Yes') -AND ($InheritanceBlocked -eq $False)) { Return $False }
    Elseif (($BlockInheritance -eq 'No') -AND ($InheritanceBlocked -eq $True)) { Return $False }

    Return $True
}
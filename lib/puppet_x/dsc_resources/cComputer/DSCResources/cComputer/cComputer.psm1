Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Computername,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Return @{  
        Computername    = $Computername
        DesiredState    = ($Computername -eq $env:COMPUTERNAME)
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Computername,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Rename-Computer -NewName $Computername -Restart
    $Glocal:DSCMachineStatus

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Computername,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    Return ($Computername -eq $env:COMPUTERNAME)

}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure

    )

    $Environment = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
    $Exists = @($Environment.GetValueNames()) -contains $Name

    If ($Ensure -eq "Present") {
        If ($Exists) {
            If ($Environment.GetValue($Name) -ne $Value) { $DesiredState = $False }
            Else { Write-Verbose "Value is correct" ; $DesiredState = $True }
        }
        Else { $DesiredState = $False }
    }
    Elseif ($Ensure -eq "Absent") {
        If ($Exists) { $DesiredState = $False }
        Else { Write-Verbose "Variable does not exist" ; $DesiredState = $True }
    }

    Return @{
        DesiredState = $DesiredState
        Environment = $Environment
        Exists = $Exists
    }
} 


Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure

    )

    $CurrentState = Get-TargetResource @PSBoundParameters

    If ($Ensure -eq "Present") { 
        If ($CurrentState.Exists) { Write-Verbose "Value is not correct" ; Set-ItemProperty -Path $CurrentState.Environment.PSPath -Name $Name -Value $Value }
        Else { Write-Verbose "Variable does not exist" ; New-ItemProperty -Path $CurrentState.Environment.PSPath -Name $Name -Value $Value }
    }
    Elseif ($Ensure -eq "Absent") { Write-Verbose "Variable exists" ; Remove-ItemProperty -Path $CurrentState.Environment.PSPath -Name $Name }
    
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
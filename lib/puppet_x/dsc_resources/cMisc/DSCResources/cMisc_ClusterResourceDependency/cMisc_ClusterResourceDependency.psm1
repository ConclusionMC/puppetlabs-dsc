Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Dependency

    )

    $Resource = Get-ClusterResource -Name $ResourceName -ErrorAction SilentlyContinue
    If ($Resource -eq $Null) { Throw "Resource $ResourceName could not be found" }
    $ResourceDependency = Get-ClusterResource -Name $Dependency -ErrorAction SilentlyContinue
    If ($ResourceDependency -eq $Null) { Throw "Resource $Dependency could not be found" }

    $CurrentDependencies = [regex]::Matches(($Resource | Get-ClusterResourceDependency).DependencyExpression,"(?<=\[).+?(?=\])").Value
    
    If ($Dependency -in $CurrentDependencies) { $DesiredState = $True }
    Else { $DesiredState = $False }
    Return @{ DesiredState = $DesiredState }

}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Dependency

    )

    $Resource = Get-ClusterResource -Name $ResourceName
    $ResourceDependency = Get-ClusterResource -Name $Dependency
    $Resource | Add-ClusterResourceDependency -Resource $ResourceDependency

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Dependency

    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState

}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,
        
        [Parameter(Mandatory=$False)]
        [ValidateSet("Matched", "All")]
        [string]$Applicability,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Output = WdsUtil /Get-DriverGroup /DriverGroup:"$DriverGroup"
    $Test = ($Output | Select-String -Pattern 'The specified driver group was not found') -eq $Null

    If ($Ensure -eq 'Present') {
        If (!($Test)) { $DesiredState = $False }
        Else{       
            If ($PSBoundParameters.ContainsKey('Enabled')) {
                $CurrentEnabled = (($Output | Select-String -Pattern 'Enabled:') -split ': ')[1].Trim()
                If ($CurrentEnabled -ne $Enabled) { $DesiredState = $False }
            }
            If ($PSBoundParameters.ContainsKey('Applicability')) { 
                $CurrentApplicability = (($Output | Select-String -Pattern 'Applicability:') -split ': ')[1].Trim()
                If ($CurrentApplicability -ne $Applicability) { $DesiredState = $False }
            }
        }
    }

    If ($Ensure -eq 'Absent') {
        If ($Test) { $DesiredState = $False }
    }      
        
    Return @{
            DriverGroup  = $DriverGroup
            Enabled      = $Enabled
            Ensure       = $Ensure
            DesiredState = $DesiredState
    }    
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,
        
        [Parameter(Mandatory=$False)]
        [ValidateSet("Matched", "All")]
        [string]$Applicability,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Output = WdsUtil /Get-DriverGroup /DriverGroup:"$DriverGroup"
    $Test = ($Output | Select-String -Pattern 'The specified driver group was not found') -eq $Null

    If ($Ensure -eq 'Present') {
        If (!($Test)) { 
            WdsUtil /Add-DriverGroup /DriverGroup:"$DriverGroup" 
            If ($PSBoundParameters.ContainsKey('Enabled')) { WdsUtil /Set-DriverGroup /DriverGroup:"$DriverGroup" /Enabled:"$Enabled" }
            If ($PSBoundParameters.ContainsKey('Applicability')) { WdsUtil /Set-DriverGroup /DriverGroup:"$DriverGroup" /Applicability:"$Applicability" } 
        }
        Else {        
            If ($PSBoundParameters.ContainsKey('Enabled')) {
                $CurrentEnabled = (($Output | Select-String -Pattern 'Enabled:') -split ': ')[1].Trim()
                If ($CurrentEnabled -ne $Enabled) { WdsUtil /Set-DriverGroup /DriverGroup:"$DriverGroup" /Enabled:"$Enabled" }
            }
            If ($PSBoundParameters.ContainsKey('Applicability')) { 
                $CurrentApplicability = (($Output | Select-String -Pattern 'Applicability:') -split ': ')[1].Trim()
                If ($CurrentApplicability -ne $Applicability) { WdsUtil /Set-DriverGroup /DriverGroup:"$DriverGroup" /Applicability:"$Applicability" }
            }
        }
    }

    If ($Ensure -eq 'Absent') {
        If ($Test) { WdsUtil /Remove-DriverGroup /DriverGroup:"$DriverGroup" }
    }   
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,

        [Parameter(Mandatory=$False)]
        [ValidateSet("Yes", "No")]
        [string]$Enabled,
        
        [Parameter(Mandatory=$False)]
        [ValidateSet("Matched", "All")]
        [string]$Applicability,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present", "Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Output = WdsUtil /Get-DriverGroup /DriverGroup:"$DriverGroup"
    $Test = ($Output | Select-String -Pattern 'The specified driver group was not found') -eq $Null

    If ($Ensure -eq 'Present') {
        If (!($Test)) { Return $False }
        Else {        
            If ($PSBoundParameters.ContainsKey('Enabled')) {
                $CurrentEnabled = (($Output | Select-String -Pattern 'Enabled:') -split ': ')[1].Trim()
                If ($CurrentEnabled -ne $Enabled) { Return $False }
            }
            If ($PSBoundParameters.ContainsKey('Applicability')) { 
                $CurrentApplicability = (($Output | Select-String -Pattern 'Applicability:') -split ': ')[1].Trim()
                If ($CurrentApplicability -ne $Applicability) { Return $False }
            }
        }
    }

    If ($Ensure -eq 'Absent') {
        If ($Test) { Return $False }
    }  

    Return $True

}
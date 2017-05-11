Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Absent","Present")]
        [string]$Ensure,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Inactive","Active")]
        [string]$State,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartRange,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$EndRange,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$SubnetMask,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$LeaseDuration,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    $Scope = Get-DhcpServerv4Scope | Where Name -eq $ScopeName
    $Exists = $Scope -ne $Null

    If ($Ensure -eq 'Present') {

        If ($Exists -eq $True) { 
       
            $CurrentProperties = @{
                StartRange = $Scope.StartRange.IPAddressToString
                LeaseDuration = $Scope.LeaseDuration.ToString()
                EndRange = $Scope.EndRange.IPAddressToString
                State = $Scope.State
            }

            $Parameters = @{}
            Foreach ($Property in $CurrentProperties.GetEnumerator()) {

                $Actual = $Property.Value
                $Required = (Get-Variable -Name $Property.Key).Value
                If ($Actual -ne $Required) { $DesiredState = $False }
            }
        }
        Else { $DesiredState = $False }

        $ScopeId = $Scope.ScopeId.IPAddressToString
        $Options = 3,6,15,66,67

        If ($PSBoundParameters.Keys -match "Option_*") {

            $SetOptions = @()
            $Options | % { If ($PSBoundParameters.ContainsKey("Option_$_")) { $SetOptions += $_ } }

            Foreach ($Option in $SetOptions) {

                $CurrentValue = (Get-DhcpServerv4OptionValue -ScopeId $ScopeId -OptionId $Option -ErrorAction SilentlyContinue).Value
                $RequiredValue = (Get-Variable -Name "Option_$Option").Value
                $IsSet = !([string]::IsNullOrEmpty($CurrentValue))        
                If (($IsSet -eq $True -AND $RequiredValue -ne $CurrentValue) -OR $IsSet -eq $False) { $DesiredState = $False }
            }
        }

        If ($PurgeOptions -eq $True) {
        
            $CurrentSetOptions = (Get-DhcpServerv4OptionValue -ScopeId $ScopeId | Where OptionId -in $Options).OptionId
            $ToRemove = (Compare-Object -ReferenceObject $CurrentSetOptions -DifferenceObject $SetOptions | Where SideIndicator -eq '<=').InputObject        
            If ($ToRemove -ne $Null) { $DesiredState = $False }
        } 
    }

    Elseif ($Ensure -eq 'Absent' -AND $Exists -eq $True) { $DesiredState = $False }

    Return @{
        ScopeName      = $ScopeName
        State          = $State
        Ensure         = $Ensure
        StartRange     = $StartRange
        EndRange       = $EndRange
        SubnetMask     = $SubnetMask
        LeaseDuration  = $LeaseDuration
        DesiredState   = $DesiredState
    }    
}

Function Set-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Absent","Present")]
        [string]$Ensure,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Inactive","Active")]
        [string]$State,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartRange,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$EndRange,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$SubnetMask,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$LeaseDuration,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Scope = Get-DhcpServerv4Scope | Where Name -eq $ScopeName    

    If ($Ensure -eq 'Present') {
        
        $Exists = $Scope -ne $Null

        If ($Exists -eq $True) { 
       
            $CurrentProperties = @{
                StartRange = $Scope.StartRange.IPAddressToString
                LeaseDuration = $Scope.LeaseDuration.ToString()
                EndRange = $Scope.EndRange.IPAddressToString
                State = $Scope.State
            }

            $Parameters = @{}
            Foreach ($Property in $CurrentProperties.GetEnumerator()) {

                $Actual = $Property.Value
                $Required = (Get-Variable -Name $Property.Key).Value
                If ($Actual -ne $Required) {

                    If ($Property.Key -eq 'StartRange' -OR $Property.Key -eq 'EndRange') {

                        If ($Parameters.ContainsKey('StartRange') -eq $False) { $Parameters.Add('StartRange',$StartRange) }
                        If ($Parameters.ContainsKey('EndRange') -eq $False) { $Parameters.Add('EndRange',$EndRange) }
                    } 
                    Else { $Parameters.Add($Property.Key,$Required) }
                }
            }

            If ($Parameters.Count -gt 0) { 

                $ScopeId = $Scope.ScopeId.IPAddressToString
                Set-DhcpServerv4Scope -ScopeId $ScopeId @Parameters
            }
        }
        Else { Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask -LeaseDuration $LeaseDuration -State $State }        
    }

    Elseif ($Ensure -eq 'Absent') {
        $ScopeId = $Scope.ScopeId.IPAddressToString
        Remove-DhcpServerv4Scope -ScopeId $ScopeId -Force       
    }
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Absent","Present")]
        [string]$Ensure,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Inactive","Active")]
        [string]$State,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartRange,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$EndRange,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$SubnetMask,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$LeaseDuration,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_3,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_6,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_15,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_66,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Option_67,

        [Parameter(Mandatory=$False)]
        [bool]$PurgeOptions = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Scope = Get-DhcpServerv4Scope | Where Name -eq $ScopeName    
    $Exists = $Scope -ne $Null

    If ($Ensure -eq 'Present') {

        If ($Exists -eq $True) { 
       
            $CurrentProperties = @{
                StartRange = $Scope.StartRange.IPAddressToString
                LeaseDuration = $Scope.LeaseDuration.ToString()
                EndRange = $Scope.EndRange.IPAddressToString
                State = $Scope.State
            }

            $Parameters = @{}
            Foreach ($Property in $CurrentProperties.GetEnumerator()) {

                $Actual = $Property.Value
                $Required = (Get-Variable -Name $Property.Key).Value
                If ($Actual -ne $Required) { Return $False }
            }
        }
        Else { Return $False }        
    }

    Elseif ($Ensure -eq 'Absent' -AND $Exists -eq $True) { Return $False }

    Return $True
}
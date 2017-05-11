Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Absent","Present")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    $Reservation = Get-DhcpServerv4Reservation -IPAddress $IPAddress -ErrorAction SilentlyContinue
    $Exists = $Reservation -ne $Null

    If ($Ensure -eq 'Present') {

        If ($Exists -eq $True) {
        
            $CurrentProperties = @{
                   Name = $Reservation.Name
                   ClientId = $Reservation.ClientId
            }
            If ($PSBoundParameters.ContainsKey('Description')) { $CurrentProperties.Add('Description',$Reservation.Description) }
        
            Foreach ($Property in $CurrentProperties.GetEnumerator()) {
            
                $CurrentValue = $Property.Value
                $RequiredValue = (Get-Variable -Name $Property.Key).Value
                If ($CurrentValue -ne $RequiredValue) { $DesiredState = $False }
            }

        }
        Else { $DesiredState = $False }
    }

    Elseif ($Ensure -eq 'Absent' -AND $Exists -eq $True) { $DesiredState = $False }


    Return @{
        IPAddress      = $IPAddress
        ScopeName      = $ScopeName
        Name           = $Name
        ClientId       = $ClientId
        Description    = $Description
        Ensure         = $Ensure
        DesiredState   = $DesiredState
    }    
}

Function Set-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Absent","Present")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($Ensure -eq 'Present') {

        $Reservation = Get-DhcpServerv4Reservation -IPAddress $IPAddress -ErrorAction SilentlyContinue
        $Exists = $Reservation -ne $Null

        If ($Exists -eq $True) {
        
            $CurrentProperties = @{
                   Name = $Reservation.Name
                   ClientId = $Reservation.ClientId
            }
            
            If ($PSBoundParameters.ContainsKey('Description')) { $CurrentProperties.Add('Description',$Reservation.Description) }        
            $Arguments = @{}

            Foreach ($Property in $CurrentProperties.GetEnumerator()) {
            
                $CurrentValue = $Property.Value
                $RequiredValue = (Get-Variable -Name $Property.Key).Value
                If ($CurrentValue -ne $RequiredValue) { $Arguments.Add($Property.Key,$RequiredValue) }
            }

            If ($Arguments.Count -gt 0) { Set-DhcpServerv4Reservation -IPAddress $IPAddress @Arguments }

        }
        Else { 

            $Scope = Get-DhcpServerv4Scope | Where Name -eq $ScopeName
            $ScopeId = $Scope.ScopeId.IPAddressToString

            $Arguments = @{
                ScopeId = $ScopeId
                IPAddress = $IPAddress
                ClientId = $ClientId
                Name = $Name
            }
            If ($PSBoundParameters.ContainsKey('Description')) { $Arguments.Add('Description',$Description) }      

            Add-DhcpServerv4Reservation @Arguments -Type Both 
        }
    }

    Elseif ($Ensure -eq 'Absent') { Remove-DhcpServerv4Reservation -IPAddress $IPAddress }

}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ScopeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Absent","Present")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Reservation = Get-DhcpServerv4Reservation -IPAddress $IPAddress -ErrorAction SilentlyContinue
    $Exists = $Reservation -ne $Null

    If ($Ensure -eq 'Present') {

        If ($Exists -eq $True) {
        
            $CurrentProperties = @{
                   Name = $Reservation.Name
                   ClientId = $Reservation.ClientId
            }
            If ($PSBoundParameters.ContainsKey('Description')) { $CurrentProperties.Add('Description',$Reservation.Description) }
        
            Foreach ($Property in $CurrentProperties.GetEnumerator()) {
            
                $CurrentValue = $Property.Value
                $RequiredValue = (Get-Variable -Name $Property.Key).Value
                If ($CurrentValue -ne $RequiredValue) { Return $False }
            }

        }
        Else { Return $False }
    }

    Elseif ($Ensure -eq 'Absent' -AND $Exists -eq $True) { Return $False }

    Return $True
}
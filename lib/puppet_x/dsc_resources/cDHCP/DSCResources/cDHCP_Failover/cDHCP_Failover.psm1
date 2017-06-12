Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PartnerServer,

        [Parameter(Mandatory=$True)]
        [ValidateSet("HotStandby","LoadBalance")]
        [string]$Mode,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Scopes,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$SharedSecret,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$LoadBalancePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MaxClientLeadTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ReservePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$StateSwitchInterval,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$AutoStateTransition,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )

    $CommonParameters = @( "AutoStateTransition" , "MaxClientLeadTime" , "StateSwitchInterval" , "Mode" )
    $CurrentRelationship = Get-DhcpServerv4Failover -Name $Name -ErrorAction SilentlyContinue
    If ($CurrentRelationship -eq $Null) { $Exists = $False }
    Else { $Exists = $True }
    If ($Exists -eq $False -and $Ensure -eq 'Absent') { Return @{ Exists = $False ; DesiredState = $True } }
    Elseif ($Exists -eq $True -and $Ensure -eq 'Absent') { Return @{ Exists = $True ; DesiredState = $False } }
    Elseif ($Exists -eq $False -and $Ensure -eq 'Present') { Return @{ Exists = $False ; DesiredState = $False ; CommonParameters = $CommonParameters } }
    Else {

        $CurrentFailOverScopes = $CurrentRelationship.ScopeId.IPAddressToString
        $RequiredFailOverScopes = (Get-DhcpServerv4Scope | Where Name -in $Scopes).ScopeId.IPAddressToString
        $InDesiredState = @{}
        $NotInDesiredState = @{}

        Foreach ($Parameter in ($PSBoundParameters.GetEnumerator() | Where Key -in $CommonParameters)) {
            $RequiredValue = $Parameter.Value
            $CurrentValue = If ($CurrentRelationship.($Parameter.Key) -is [TimeSpan]) { $CurrentRelationship.($Parameter.Key).ToString() } Else { $CurrentRelationship.($Parameter.Key) }
            If ($RequiredValue -eq $CurrentValue) { $InDesiredState.Add($Parameter.Key,$RequiredValue) }
            Else { $NotInDesiredState.Add($Parameter.Key,$RequiredValue) }
        }
        If ($Mode -eq 'HotStandby' -and $PSBoundParameters.ContainsKey('ReservePercent')) { 
            If ($CurrentRelationship.ReservePercent -eq $ReservePercent) { $InDesiredState.Add('ReservePercent',$ReservePercent) }
            Else { $NotInDesiredState.Add('ReservePercent',$ReservePercent) } 
        }
        If ($Mode -eq 'LoadBalance' -and $PSBoundParameters.ContainsKey('LoadBalancePercent')) { 
            If ($CurrentRelationship.LoadBalancePercent -eq $LoadBalancePercent) { $InDesiredState.Add('LoadBalancePercent',$LoadBalancePercent) }
            Else { $NotInDesiredState.Add('LoadBalancePercent',$LoadBalancePercent) } 
        }
        If ($CurrentRelationship.EnableAuth -eq $False -and $PSBoundParameters.ContainsKey('SharedSecret')){ $NotInDesiredState.Add('SharedSecret',$SharedSecret) }

        $ScopeComparison = Compare-Object -ReferenceObject $CurrentFailOverScopes -DifferenceObject $RequiredFailOverScopes
        $AddScopes = ($ScopeComparison | Where SideIndicator -eq '=>').InputObject
        $RemoveScopes = ($ScopeComparison | Where SideIndicator -eq '<=').InputObject

        If ($PartnerServer -eq $CurrentRelationship.PartnerServer) { $CorrectPartner = $True }
        Else { $CorrectPartner = $False }

        If ($PSBoundParameters.ContainsKey('SharedSecret') -eq $False -and $CurrentRelationship.EnableAuth -eq $True) { $DisableAuth = $True }
        Else { $DisableAuth = $False }

        If ($NotInDesiredState.Count -gt 0 `
            -or $ScopeComparison.Count -gt 0 `
            -or $CorrectPartner -eq $False `
            -or $DisableAuth -eq $True `            -or $AddScopes -ne $Null `
            -or $RemoveScopes -ne $Null) { $DesiredState = $False }

        Return @{
            RelationShip = $CurrentRelationship
            CommonParameters = $CommonParameters
            CorrectPartner = $CorrectPartner
            DisableAuth = $DisableAuth
            AddScopes = $AddScopes
            RemoveScopes = $RemoveScopes
            Exists = $Exists
            InDesiredState = $InDesiredState
            NotInDesiredState = $NotInDesiredState
            DesiredState = $DesiredState
        }
    }
   
}

Function Set-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PartnerServer,

        [Parameter(Mandatory=$True)]
        [ValidateSet("HotStandby","LoadBalance")]
        [string]$Mode,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Scopes,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$SharedSecret,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$LoadBalancePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MaxClientLeadTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ReservePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$StateSwitchInterval,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$AutoStateTransition,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )
    
    $Result = Get-TargetResource @PSBoundParameters
    If ($Ensure -eq 'Present') {
        If ($Result.Exists -eq $False) {
            Create-NewRelation @PSBoundParameters
        }
        Elseif ($Result.CorrectPartner -eq $False -or $Result.DisableAuth -eq $True) {
            Remove-DhcpServerv4Failover -Name $Name -Force
            Create-NewRelation @PSBoundParameters
        }
        Else {
            $Parameters = @{ Name = $Name }
            $Result.NotInDesiredState.GetEnumerator() | % { $Parameters.Add($_.Key,$_.Value) }
            If ($Result.NotInDesiredState.Count -gt 0) { Set-DhcpServerv4Failover @Parameters -Force }
            If ($Result.AddScopes -ne $Null) { $Result.AddScopes | % { Add-DhcpServerv4FailoverScope -Name $Name -ScopeId $_ } }
            If ($Result.RemoveScopes -ne $Null) { $Result.RemoveScopes | % { Remove-DhcpServerv4FailoverScope -Name $Name -ScopeId $_ } }
        }
    }
    Else { Remove-DhcpServerv4Failover -Name $Name -Force }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PartnerServer,

        [Parameter(Mandatory=$True)]
        [ValidateSet("HotStandby","LoadBalance")]
        [string]$Mode,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Scopes,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$SharedSecret,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$LoadBalancePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MaxClientLeadTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ReservePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$StateSwitchInterval,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$AutoStateTransition,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )
    Return (Get-TargetResource @PSBoundParameters).DesiredState
}

Function Create-NewRelation {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$PartnerServer,

        [Parameter(Mandatory=$True)]
        [ValidateSet("HotStandby","LoadBalance")]
        [string]$Mode,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Scopes,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$SharedSecret,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$LoadBalancePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$MaxClientLeadTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ReservePercent,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$StateSwitchInterval,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Present","Absent")]
        [string]$Ensure,

        [Parameter(Mandatory=$False)]
        [bool]$AutoStateTransition,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState = $True

    )
    $ScopeIds = (Get-DhcpServerv4Scope | Where Name -in $Scopes).ScopeId.IPAddressToString
    $CheckPartnerFailover = Get-DhcpServerv4Failover -ComputerName $PartnerServer -Name $Name -ErrorAction SilentlyContinue
    If ($CheckPartnerFailover -ne $Null) { Remove-DhcpServerv4Failover -ComputerName $PartnerServer -Name $Name -Force }
    Foreach ($Scope in $Scopes) {
        $ExistenceCheck = Get-DhcpServerv4Scope -ComputerName $PartnerServer | Where Name -eq $Scope
        If ($ExistenceCheck -ne $Null) { Remove-DhcpServerv4Scope -ComputerName $PartnerServer -ScopeId ($ExistenceCheck).ScopeId.IPAddressToString -Force}
    }
    $Parameters = @{ Name = $Name ; PartnerServer = $PartnerServer ; ScopeId = $ScopeIds }    
    $PSBoundParameters.GetEnumerator() | Where Key -in $Result.CommonParameters | Where Key -ne 'Mode' | % { $Parameters.Add($_.Key,$_.Value) }
    If ($Mode -eq 'HotStandby') { 
        $Parameters.Add('ServerRole','Active')
        If ($PSBoundParameters.ContainsKey('ReservePercent')) { $Parameters.Add('ReservePercent',$ReservePercent) } 
    }
    Elseif($PSBoundParameters.ContainsKey('LoadBalancePercent')) { $Parameters.Add('LoadBalancePercent',$LoadBalancePercent) }
    If ($PSBoundParameters.ContainsKey('SharedSecret')) { $Parameters.Add('SharedSecret',$SharedSecret) } 
    Add-DhcpServerv4Failover @Parameters -Force
}
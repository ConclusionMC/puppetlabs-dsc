Function Get-TargetResource {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$MacAddress,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IP,

        [Parameter(Mandatory=$False)]
        [ValidateRange(0,24)]
        [int]$PrefixLength,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Gateway,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DnsServers = @(),

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [boolean]$DisableIPv6 = $True     
    )

    $TestResource = (Get-PSCallStack).Command[1] -eq "Test-TargetResource" 

    $MacAddress = $MacAddress.Replace('-','').Replace(':','').Trim()
    $Adapter = Get-NetAdapter | ? { $_.MacAddress.Replace('-','').Replace(':','').Trim() -eq $MacAddress }
    If ($Adapter -eq $Null) { Throw "Could not find adapter with mac address $MacAddress" }
    $IPv6Enabled = ($Adapter | Get-NetAdapterBinding -ComponentID 'ms_tcpip6').Enabled
    $CurrentIPAddress = @($Adapter | Get-NetIPAddress | Where AddressFamily -eq 'IPv4' | Where SkipAsSource -eq $False)
    $CurrentIPConf = $CurrentIPAddress | Get-NetIPConfiguration
    $IPInterface = $Adapter | Get-NetIPInterface | Where AddressFamily -eq 'IPv4' | Where ConnectionState -eq 'Connected'

    $Result = @{
        Adapter = $Adapter
        IPInterface = $IPInterface
        CurrentIP = $CurrentIPAddress.IPAddress
        CurrentGateway = $CurrentIPConf.IPv4DefaultGateway.NextHop
        Actions = @()
        DesiredState = $True
    }

    If ($PSBoundParameters.ContainsKey('Name') -and $Adapter.Name -ne $Name) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetName' } }
    
    If ($IPInterface.Dhcp -eq 'Enabled' -and $PSBoundParameters.ContainsKey('IP')) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('SetIP','SetPrefixLength','SetGateway','DisableDHCP') } }
    Elseif ($IPInterface.Dhcp -eq 'Disabled' -and -not $PSBoundParameters.ContainsKey('IP')) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('EnableDHCP','RemoveGateway') } }
    Elseif ($PSBoundParameters.ContainsKey('IP')) {
        If (-not $PSBoundParameters.ContainsKey('PrefixLength') -or -not $PSBoundParameters.ContainsKey('Gateway')) { Throw "When using the IP parameter the PrefixLength and Gateway parameters must also be provided." }
        If ($CurrentIPAddress.Count -gt 1 -and $IP -notin $CurrentIPAddress.IPAddress) { Throw "Multiple IP addresses found but desired IP address is not among them. This script can not decide which IP address to change."  }
        Elseif ($CurrentIPAddress.Count -gt 1) { $CurrentIPAddress = $CurrentIPAddress | Where IpAddress -eq $IP }
        Else {
            If ($IP -ne $CurrentIPAddress.IPAddress) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('RemoveIP','SetIP') } } 
            If ($PrefixLength -ne $CurrentIPAddress.PrefixLength) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetPrefixLength' } }   
            If ($Gateway -ne $CurrentIPConf.IPv4DefaultGateway.NextHop) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('RemoveGateway','SetGateway') } }  
        }
    }

    If ($DnsServers.Count -eq 0 -and $CurrentIPConf.DNSServer.ServerAddresses -ne $Null) { $Result.Actions += 'RemoveDnsServers' }
    Elseif ($DnsServers.Count -ne 0 -and $CurrentIPConf.DNSServer.ServerAddresses -eq $Null) { $Result.Actions += 'SetDnsServers' }
    Else {
        $Comparison = @(Compare-Object -ReferenceObject $CurrentIPConf.DNSServer.ServerAddresses -DifferenceObject $DnsServers)
        If ($Comparison.Count -gt 0) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('RemoveDnsServers','SetDnsServers') } }
    }

    If ($IPv6Enabled -eq $True -and $DisableIPv6 -eq $True) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'DisableIPv6' } }
    If ($IPv6Enabled -eq $False -and $DisableIPv6 -eq $False) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'EnableIPv6'} }
    
    If ($Result.Actions.Count -gt 0) { $Result.DesiredState = $False }
    Return $Result
}

Function Set-TargetResource {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$MacAddress,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IP,

        [Parameter(Mandatory=$False)]
        [ValidateRange(0,24)]
        [int]$PrefixLength,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Gateway,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DnsServers = @(),

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [boolean]$DisableIPv6 = $True     
    ) 
        
    $CurrentState = Get-TargetResource @PSBoundParameters
    $Adapter = $CurrentState.Adapter
    $Actions = $CurrentState.Actions
    $IPInterface = $CurrentState.IPInterface

    If ($Actions -contains "SetName") { $Adapter | Rename-NetAdapter -NewName $Name }
    If ($Actions -contains "EnableDHCP") { $IPInterface | Set-NetIPInterface -Dhcp Enabled }
    If ($Actions -contains "DisableDHCP") { $IPInterface | Set-NetIPInterface -Dhcp Disabled }
    If ($Actions -contains "RemoveIP") { $IPInterface | Remove-NetIPAddress -IPAddress $CurrentState.CurrentIP -Confirm:$False }
    If ($Actions -contains "SetIP") { $IPInterface | New-NetIPAddress -IPAddress $IP -Confirm:$False }
    If ($Actions -contains "SetPrefixLength") { $IPInterface | Set-NetIPAddress -PrefixLength $PrefixLength }
    If ($Actions -contains "RemoveGateway") { Remove-NetRoute -InterfaceIndex $IPInterface.ifIndex -NextHop $CurrentState.CurrentGateway -Confirm:$False }
    If ($Actions -contains "SetGateway") { New-NetRoute -InterfaceIndex $IPInterface.ifIndex -NextHop $Gateway -DestinationPrefix '0.0.0.0/0' -Confirm:$False }
    If ($Actions -contains "RemoveDnsServers") { $IPInterface | Set-DnsClientServerAddress -ResetServerAddresses }
    If ($Actions -contains "SetDnsServers") { $IPInterface | Set-DnsClientServerAddress -ServerAddresses $DnsServers }
    If ($Actions -contains "EnableIPv6") { $Adapter | Enable-NetAdapterBinding -ComponentID 'ms_tcpip6' }
    If ($Actions -contains "DisableIPv6") { $Adapter | Disable-NetAdapterBinding -ComponentID 'ms_tcpip6' }

}

Function Test-TargetResource {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$MacAddress,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IP,

        [Parameter(Mandatory=$False)]
        [ValidateRange(0,24)]
        [int]$PrefixLength,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Gateway,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DnsServers = @(),

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [boolean]$DisableIPv6 = $True     
    )
    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
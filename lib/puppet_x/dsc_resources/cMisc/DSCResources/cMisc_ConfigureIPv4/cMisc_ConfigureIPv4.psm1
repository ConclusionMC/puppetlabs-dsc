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
        [int]$PrefixLength = 20,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Gateway,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DnsServers,

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

    If ($PSBoundParameters.ContainsKey('Name') -and $Adapter.Name -cne $Name) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetName' } }
    
    If ($IPInterface.Dhcp -eq 'Enabled' -and $PSBoundParameters.ContainsKey('IP')) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('SetIP','SetPrefixLength','DisableDHCP') } }
    Elseif ($IPInterface.Dhcp -eq 'Disabled' -and -not $PSBoundParameters.ContainsKey('IP')) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('EnableDHCP','RemoveGateway') } }
    Elseif ($PSBoundParameters.ContainsKey('IP')) {
        If ($CurrentIPAddress.Count -gt 1 -and $IP -notin $CurrentIPAddress.IPAddress) { Throw "Multiple IP addresses found but desired IP address is not among them. This script can not decide which IP address to change."  }
        Elseif ($CurrentIPAddress.Count -gt 1) { $CurrentIPAddress = $CurrentIPAddress | Where IpAddress -eq $IP }
        Else {
            If ($IP -ne $CurrentIPAddress.IPAddress) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('RemoveIP','SetIP') } } 
            If ($PrefixLength -ne $CurrentIPAddress.PrefixLength) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetPrefixLength' } }  
        }
    }

    If ($PSBoundParameters.ContainsKey('Gateway')) {
        If (-not $PSBoundParameters.ContainsKey('IP')) { Throw "Gateway is set to be configured but no IP address is provided. To configure a gateway, an IP address must also be set." }
        Elseif ($IPInterface.Dhcp -eq 'Enabled') { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('SetGateway') } }
        Elseif ($CurrentIPConf.IPv4DefaultGateway.NextHop -eq $Null) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('SetGateway') } }
        Elseif ($Gateway -ne $CurrentIPConf.IPv4DefaultGateway.NextHop) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('RemoveGateway','SetGateway') } }
    }
    Elseif ($CurrentIPConf.IPv4DefaultGateway.NextHop -ne $Null -and $IPInterface.Dhcp -eq 'Disabled') { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += @('RemoveGateway') } }

    If ($PSBoundParameters.ContainsKey('DnsServers')) {
        If ($CurrentIPConf.DNSServer.ServerAddresses -eq $Null) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetDnsServers' } }
        Elseif ($IPInterface.Dhcp -eq 'Enabled') { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetDnsServers' } }
        Else {
            $Comparison = @(Compare-Object -ReferenceObject $CurrentIPConf.DNSServer.ServerAddresses -DifferenceObject $DnsServers)
            If ($Comparison.Count -gt 0) { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'SetDnsServers' } }
        }
    }
    Elseif ($CurrentIPConf.DNSServer.ServerAddresses -ne $Null -and $IPInterface.Dhcp -eq 'Disabled') { If ($TestResource) { Return @{ DesiredState = $False } } Else { $Result.Actions += 'RemoveDnsServers' } }

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
        [int]$PrefixLength = 20,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Gateway,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DnsServers,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [boolean]$DisableIPv6 = $True     
    )
        
    $CurrentState = Get-TargetResource @PSBoundParameters
    $Adapter = $CurrentState.Adapter
    $Actions = $CurrentState.Actions
    $IPInterface = $CurrentState.IPInterface

    Write-Verbose "List of actions:"
    $Actions | % { Write-Verbose $_ }

    If ($Actions -contains "SetName") { 
        Write-Verbose "Changing adapter name"
        $Adapter = $Adapter | Rename-NetAdapter -NewName $Name -PassThru
        #$Adapter = Get-NetAdapter | ? { $_.MacAddress.Replace('-','').Replace(':','').Trim() -eq $MacAddress }
        $IPInterface = $Adapter | Get-NetIPInterface | Where AddressFamily -eq 'IPv4' | Where ConnectionState -eq 'Connected'
    }
    If ($Actions -contains "EnableDHCP") {  
        Write-Verbose "Enabling DHCP"
        $IPInterface | Set-NetIPInterface -Dhcp Enabled 
    }
    If ($Actions -contains "DisableDHCP") {  
        Write-Verbose "Disabling DHCP"
        $IPInterface | Set-NetIPInterface -Dhcp Disabled 
    }
    If ($Actions -contains "RemoveIP") {  
        Write-Verbose "Removing current IP"
        $IPInterface | Remove-NetIPAddress -IPAddress $CurrentState.CurrentIP -Confirm:$False 
    }
    If ($Actions -contains "SetIP") {  
        Write-Verbose "Setting new IP"
        $IPInterface | New-NetIPAddress -IPAddress $IP -Confirm:$False 
    }
    If ($Actions -contains "SetPrefixLength") {  
        Write-Verbose "Setting subnet mask"
        $IPInterface | Set-NetIPAddress -PrefixLength $PrefixLength 
    }
    If ($Actions -contains "RemoveGateway") {  
        Write-Verbose "Removing old gateway route"
        Remove-NetRoute -InterfaceIndex $IPInterface.ifIndex -NextHop $CurrentState.CurrentGateway -Confirm:$False 
    }
    If ($Actions -contains "SetGateway") {  
        Write-Verbose "Setting new gateway route"
        New-NetRoute -InterfaceIndex $IPInterface.ifIndex -NextHop $Gateway -DestinationPrefix '0.0.0.0/0' -Confirm:$False 
    }
    If ($Actions -contains "RemoveDnsServers") { 
        Write-Verbose "Removing DNS servers"
        $IPInterface | Set-DnsClientServerAddress -ResetServerAddresses 
    }
    If ($Actions -contains "SetDnsServers") { 
        Write-Verbose "Setting new DNS servers"
        $IPInterface | Set-DnsClientServerAddress -ServerAddresses $DnsServers 
    }
    If ($Actions -contains "EnableIPv6") {
        Write-Verbose "Enabling IPv6"
        $Adapter | Enable-NetAdapterBinding -ComponentID 'ms_tcpip6' 
    }
    If ($Actions -contains "DisableIPv6") {  
        Write-Verbose "Disabling IPv6"
        $Adapter | Disable-NetAdapterBinding -ComponentID 'ms_tcpip6' 
    }

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
        [int]$PrefixLength = 20,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Gateway,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DnsServers,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [boolean]$DisableIPv6 = $True     
    )
    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
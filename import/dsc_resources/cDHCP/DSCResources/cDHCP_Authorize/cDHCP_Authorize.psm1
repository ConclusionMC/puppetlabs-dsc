Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateSet('Yes','No')]
        [string]$Authorize,                

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $FQDN = [System.Net.Dns]::GetHostByName(($env:computerName)).HostName
    $Authorized = !((Get-DhcpServerInDc | Where DnsName -eq $FQDN) -eq $Null)

    If ($Authorized -eq $False -AND $Authorize -eq 'Yes') { $DesiredState = $False }
    Elseif ($Authorized -eq $True -AND $Authorize -eq 'No') { $DesiredState = $False }
    Else { $DesiredState = $True }

    Return @{
        Authorize      = $Authorize
        DesiredState   = $DesiredState
    }    
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet('Yes','No')]
        [string]$Authorize,                

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($Authorize -eq 'Yes') { Add-DhcpServerInDC }
    Else { Remove-DhcpServerInDC }

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet('Yes','No')]
        [string]$Authorize,                

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $FQDN = [System.Net.Dns]::GetHostByName(($env:computerName)).HostName
    $Authorized = !((Get-DhcpServerInDc | Where DnsName -eq $FQDN) -eq $Null)

    If ($Authorized -eq $False -AND $Authorize -eq 'Yes') { Return $False }
    Elseif ($Authorized -eq $True -AND $Authorize -eq 'No') { Return $False }
    Else { Return $True }

}
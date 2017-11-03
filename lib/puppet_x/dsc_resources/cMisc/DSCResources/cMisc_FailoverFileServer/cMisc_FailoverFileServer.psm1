Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ShareName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StaticIP,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IgnoreNetwork,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterOU,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk

    )

    If ($ShareName -in (Get-ClusterGroup).Name) { Return $True } Else { Return $False }

}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ShareName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StaticIP,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IgnoreNetwork,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterOU,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk

    )

    $DC = ([ADSI]"LDAP://RootDSE").DnsHostName
    $ClusterName = (Get-Cluster).Name
    Invoke-Command -ComputerName $DC -ScriptBlock {
        $ADOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($Args[1])'"
        $OU = [ADSI]"LDAP://$($ADOU.DistinguishedName)"
        $Computer = Get-ADComputer $Args[0]
        $CurrentAccess = $OU.ObjectSecurity.GetAccessRules($True,$False,[System.Security.Principal.NTAccount]) | ? { 
            $_.IdentityReference -eq $Args[0] -and `
            $_.ActiveDirectoryRights -eq 'CreateChild' -and `
            $_.AccessControlType -eq 'Allow' -and `
            $_.ObjectType -eq 'bf967a86-0de6-11d0-a285-00aa003049e2'
        }
        If ($CurrentAccess -eq $Null) {
            $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule( $Computer.SID, "CreateChild", "Allow", [guid]"bf967a86-0de6-11d0-a285-00aa003049e2" )
            $Ou.ObjectSecurity.AddAccessRule($Rule)
            $OU.CommitChanges()
        }
    
    } -ArgumentList $ClusterName,$ClusterOU

    $Arguments =  @{
        Cluster = $ClusterName
        Storage = $ClusterDisk
        Name = $ShareName
        StaticAddress = $StaticIP
    }
    
    If ($PSBoundParameters.ContainsKey('IgnoreNetwork')) { $Arguments.Add('IgnoreNetwork',$IgnoreNetwork) }
    
    Add-ClusterFileServerRole @Arguments
}

Function Test-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ShareName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StaticIP,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$IgnoreNetwork,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterOU,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk

    )

    Return Get-TargetResource @PSBoundParameters

}
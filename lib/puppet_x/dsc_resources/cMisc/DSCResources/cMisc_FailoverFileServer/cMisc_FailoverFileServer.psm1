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
        [string]$ClusterDisk

    )
    
    $ClusterGroup = Get-ClusterGroup -Name $ShareName -ErrorAction SilentlyContinue
    If ($ClusterGroup -eq $Null) { Return $False }

    $CurrentOwner = $ClusterGroup.OwnerNode.NodeName -eq $env:COMPUTERNAME
    If ($CurrentOwner) {
        If ($ClusterGroup.State -ne 'Online') { Return $False }
        $FileServer = Get-ClusterResource -Name "File Server (\\$ShareName)" -ErrorAction SilentlyContinue
        If ($FileServer -eq $Null) { Return $False }
        $Dependencies = ($FileServer | Get-ClusterResourceDependency).DependencyExpression
        If ($Dependencies -notmatch $ShareName) { Return $False }
        If ($FileServer.State -ne 'Online') { Return $False }
    }
    
    Return $True

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
        [string]$ClusterDisk

    )

    $ClusterName = (Get-Cluster).Name

    $Arguments =  @{
        Cluster = $ClusterName
        Storage = $ClusterDisk
        Name = $ShareName
        StaticAddress = $StaticIP
    }   

    $ClusterGroup = Get-ClusterGroup -Name $ShareName -ErrorAction SilentlyContinue
    If ($ClusterGroup -eq $Null) {

        $DC = ([ADSI]"LDAP://RootDSE").DnsHostName
        Invoke-Command -ComputerName $DC -ScriptBlock {
            $Computer = Get-ADComputer $Args[0]
            $OU = [ADSI]"LDAP://$($Computer.DistinguishedName -replace 'CN=.+?,' , '')"        
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
        } -ArgumentList $ClusterName

        If ($PSBoundParameters.ContainsKey('IgnoreNetwork')) { $Arguments.Add('IgnoreNetwork',$IgnoreNetwork) }
        Add-ClusterFileServerRole @Arguments
        Start-Sleep 8
        Get-ClusterNode -Name $env:COMPUTERNAME | Suspend-ClusterNode
        $ClusterGroup = Get-ClusterGroup -Name $ShareName

    }

    $CurrentOwner = $ClusterGroup.OwnerNode.NodeName -eq $env:COMPUTERNAME
    If ($CurrentOwner) {
        If ($ClusterGroup.State -ne 'Online') { $ClusterGroup | Start-ClusterGroup }
        $FileServer = Get-ClusterResource -Name "File Server (\\$ShareName)" -ErrorAction SilentlyContinue
        If ($FileServer -eq $Null) { Add-ClusterResource -ResourceType 'File Server' -Group $ShareName -Name "File Server (\\$ShareName)" ; $FileServer = Get-ClusterResource -Name "File Server (\\$ShareName)" }
        $Dependencies = ($FileServer | Get-ClusterResourceDependency).DependencyExpression
        If ($Dependencies -notmatch $ShareName) { Get-ClusterResource -Name "File Server (\\$ShareName)" | Add-ClusterResourceDependency -Resource $ShareName -ErrorAction SilentlyContinue }
        If ($FileServer.State -ne 'Online') { $FileServer | Start-ClusterResource -ErrorAction SilentlyContinue }        
    }    
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
        [string]$ClusterDisk

    )

    Return Get-TargetResource @PSBoundParameters

}


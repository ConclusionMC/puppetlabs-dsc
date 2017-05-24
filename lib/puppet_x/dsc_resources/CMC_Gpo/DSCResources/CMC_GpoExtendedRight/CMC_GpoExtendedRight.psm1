Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GpoName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ExtendedRight,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Allow","Deny")]
        [string]$ControlType,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Users,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $GPO = Get-GPO -Name $GpoName
    $Domain = ("DC=" + (($env:USERDNSDOMAIN -split '\.') -join ',DC=')).ToLower()
    $ADGPO = [ADSI]"LDAP://CN={$($GPO.Id.guid)},CN=Policies,CN=System,$Domain"

    Foreach ($User in $Users) {
        $CurrentPermissions = $ADGPO.ObjectSecurity.GetAccessRules($true,$false,[System.Security.Principal.NTAccount]) | Where IdentityReference -eq $User | Where ActiveDirectoryRights -eq 'ExtendedRight' | Where ObjectType -eq $ExtendedRight
        If ($CurrentPermissions -eq $Null) { $DesiredState = $False }
        Elseif ($CurrentPermissions.Count -gt 1) { $DesiredState = $False }
        Elseif ($CurrentPermissions.AccessControlType -ne $ControlType) { $DesiredState = $False }
    }

    Return @{
        GpoName       = $GpoName
        ExtendedRight = $ExtendedRight
        ControlType   = $ControlType
        Users         = $Users
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GpoName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ExtendedRight,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Allow","Deny")]
        [string]$ControlType,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Users,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $GPO = Get-GPO -Name $GpoName
    $DomainX = ("DC=" + (($Domain -split '\.') -join ',DC=')).ToLower()
    $ADGPO = [ADSI]"LDAP://CN={$($GPO.Id.guid)},CN=Policies,CN=System,$DomainX"

    Foreach ($User in $Users) {
        $CurrentPermissions = $ADGPO.ObjectSecurity.GetAccessRules($true,$false,[System.Security.Principal.NTAccount]) | Where IdentityReference -eq $User | Where ActiveDirectoryRights -eq 'ExtendedRight' | Where ObjectType -eq $ExtendedRight
        If ($CurrentPermissions -eq $Null) {
            $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule( [System.Security.Principal.NTAccount]$User,"ExtendedRight",$ControlType,[Guid]$ExtendedRight )
            $ADGPO.ObjectSecurity.AddAccessRule($Rule) | Out-Null  
            $Changed = $True  
        }
        Elseif ($CurrentPermissions.Count -gt 1) { 
            $CurrentPermissions | Where AccessControlType -ne $ControlType | % { $ADGPO.ObjectSecurity.RemoveAccessRule($_) | Out-Null }
            $Changed = $True
        }
        Elseif ($CurrentPermissions.AccessControlType -ne $ControlType) {
            $ADGPO.ObjectSecurity.RemoveAccessRule($CurrentPermissions) | Out-Null
            $Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule( [System.Security.Principal.NTAccount]$User,"ExtendedRight",$ControlType,[Guid]$ExtendedRight )
            $ADGPO.ObjectSecurity.AddAccessRule($Rule) | Out-Null  
            $Changed = $True
        }
    }

    If ($Changed) { $ADGPO.CommitChanges() }
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GpoName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ExtendedRight,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Allow","Deny")]
        [string]$ControlType,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Users,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$Domain,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $GPO = Get-GPO -Name $GpoName
    $Domain = ("DC=" + (($env:USERDNSDOMAIN -split '\.') -join ',DC=')).ToLower()
    $ADGPO = [ADSI]"LDAP://CN={$($GPO.Id.guid)},CN=Policies,CN=System,$Domain"

    Foreach ($User in $Users) {
        $CurrentPermissions = $ADGPO.ObjectSecurity.GetAccessRules($true,$false,[System.Security.Principal.NTAccount]) | Where IdentityReference -eq $User | Where ActiveDirectoryRights -eq 'ExtendedRight' | Where ObjectType -eq $ExtendedRight
        If ($CurrentPermissions -eq $Null) { Return $False }
        Elseif ($CurrentPermissions.Count -gt 1) { Return $False }
        Elseif ($CurrentPermissions.AccessControlType -ne $ControlType) { Return $False }
    }
    Return $True
}
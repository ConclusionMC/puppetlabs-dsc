Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainController,  

        [Parameter(Mandatory=$True)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure,                

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Session = New-PSSession -ComputerName $DomainController -Name 'cDHCP_SecurityGroup'
    $AdminsExist = (Invoke-Command -Session $Session -ScriptBlock { Get-ADGroup -Identity 'DHCP Administrators' } -ErrorAction SilentlyContinue) -ne $Null
    $UsersExist = (Invoke-Command -Session $Session -ScriptBlock { Get-ADGroup -Identity 'DHCP Users' } -ErrorAction SilentlyContinue) -ne $Null
    $Session | Remove-PSSession


    If ($Ensure -eq 'Present') {
        If ($AdminsExist -AND $UsersExist) { $DesiredState = $True }
        Else { $DesiredState = $False }
    }
    Else {
        If ($AdminsExist -OR $UsersExist) { $DesiredState = $False }
        Else { $DesiredState = $True }
    }


    Return @{
        DomainController = $DomainController
        Ensure         = $Ensure
        DesiredState   = $DesiredState
    }    
}

Function Set-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainController,  

        [Parameter(Mandatory=$True)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure,                

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    If ($Ensure -eq 'Present') { Add-DhcpServerSecurityGroup -ComputerName $DomainController }
    Else {
        $Session = New-PSSession -ComputerName $DomainController -Name 'cDHCP_SecurityGroup'
        Invoke-Command -Session $Session -ScriptBlock { Remove-ADGroup -Identity 'DHCP Administrators' } -ErrorAction SilentlyContinue
        Invoke-Command -Session $Session -ScriptBlock { Remove-ADGroup -Identity 'DHCP Users' } -ErrorAction SilentlyContinue
        $Session | Remove-PSSession
    }
}

Function Test-TargetResource {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DomainController,  

        [Parameter(Mandatory=$True)]
        [ValidateSet('Present','Absent')]
        [string]$Ensure,                

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Session = New-PSSession -ComputerName $DomainController -Name 'cDHCP_SecurityGroup'
    $AdminsExist = (Invoke-Command -Session $Session -ScriptBlock { Get-ADGroup -Identity 'DHCP Administrators' } -ErrorAction SilentlyContinue) -ne $Null
    $UsersExist = (Invoke-Command -Session $Session -ScriptBlock { Get-ADGroup -Identity 'DHCP Users' } -ErrorAction SilentlyContinue) -ne $Null
    $Session | Remove-PSSession


    If ($Ensure -eq 'Present') {
        If ($AdminsExist -AND $UsersExist) { Return $True }
        Else { Return $False }
    }
    Else {
        If ($AdminsExist -OR $UsersExist) { Return $False }
        Else { Return $True }
    }
}
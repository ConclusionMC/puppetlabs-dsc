Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GpoName,

        [Parameter(Mandatory=$True)]
        [string[]]$GpoLinks,

        [Parameter(Mandatory=$False)]
        [bool]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $Gpo = Get-GPO -Name $GpoName
    If ($Gpo -eq $Null) { $DesiredState = $False }
    Else {
        If ($GpoLinks -ne "Unset") {
            $LinkObjects = $GpoLinks | % { 
                $Split = $_ -split ';'
                If ($Split[3].Trim() -eq 'Last') { $Order = 'Last' }
                Else { $Order = [int]$Split[3] }
                New-Object -TypeName PsObject -Property @{
                    Target = $Split[0].Trim()
                    LinkEnabled = $Split[1].Trim()
                    Enforced = $Split[2].Trim()
                    Order = $Order
                }
            }   

            Foreach ($Link in $LinkObjects) {

                $AllLinks = (Get-GPInheritance -Target $Link.Target).GpoLinks
                $CurrentLink = $AllLinks | Where DisplayName -eq $GpoName
                If ($Link.Order -eq 'Last') { $Link.Order = $AllLinks.Count }
                If ($CurrentLink -eq $Null) { $DesiredState = $False }
                Else{
                    If ($Link.LinkEnabled -ne 'Unspecified') {
                        If ($Link.LinkEnabled -eq 'Yes' -AND $CurrentLink.Enabled -eq $False) { $DesiredState = $False }
                        Elseif ($Link.LinkEnabled -eq 'No' -AND $CurrentLink.Enabled -eq $True) { $DesiredState = $False }
                    }

                    If ($Link.Enforced -ne 'Unspecified') {
                        If ($Link.Enforced -eq 'Yes' -AND $CurrentLink.Enforced -eq $False) { $DesiredState = $False }
                        Elseif ($Link.Enforced -eq 'No' -AND $CurrentLink.Enforced -eq $True) { $DesiredState = $False }
                    }

                    If ($Link.Order -ne $CurrentLink.Order) { $DesiredState = $False }
                }
            }
        }

        If (($Purge) -OR ($GpoLinks -eq 'Unset')) {
            $AllGpoLinks = (Get-ADOrganizationalUnit -Filter 'Name -Like "*"') | Where LinkedGroupPolicyObjects -Match "{$($Gpo.Id)}"
            If ($GpoLinks -eq 'Unset') { If ($AllGpoLinks -ne $Null) { $DesiredState = $False } }
            Else {
                $Compare = Compare-Object -ReferenceObject $AllGpoLinks.DistinguishedName -DifferenceObject $LinkObjects.Target
                If ($Compare -ne $Null) { $DesiredState = $False }
            }
        }
    }

    Return @{
        GpoName       = $GpoName
        Purge         = $Purge
        GpoLinks      = $GpoLinks
        DesiredState  = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GpoName,

        [Parameter(Mandatory=$True)]
        [string[]]$GpoLinks,

        [Parameter(Mandatory=$False)]
        [bool]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Gpo = Get-GPO -Name $GpoName 

    If ($GpoLinks -ne 'Unset') {
        $LinkObjects = $GpoLinks | % { 
            $Split = $_ -split ';'
            If ($Split[3].Trim() -eq 'Last') { $Order = 'Last' }
            Else { $Order = [int]$Split[3] }
            New-Object -TypeName PsObject -Property @{
                Target = $Split[0].Trim()
                LinkEnabled = $Split[1].Trim()
                Enforced = $Split[2].Trim()
                Order = $Order
            }
        }


        Foreach ($Link in $LinkObjects) {

            $AllLinks = (Get-GPInheritance -Target $Link.Target).GpoLinks
            $CurrentLink = $AllLinks | Where DisplayName -eq $GpoName
            If ($Link.Order -eq 'Last') { $Link.Order = $AllLinks.Count }
            If ($CurrentLink -eq $Null) {
                $Parameters = @{ GUID = $Gpo.Id }        
                $Link | Get-Member -MemberType NoteProperty | % { $Parameters.Add($_.Name,$Link.($_.Name)) }
                New-GPLink @Parameters
            }
            Else{
                If ($Link.LinkEnabled -ne 'Unspecified') {
                    If ($Link.LinkEnabled -eq 'Yes' -AND $CurrentLink.Enabled -eq $False) { Set-GPLink -Guid $Gpo.Id -Target $Link.Target -LinkEnabled Yes }
                    Elseif ($Link.LinkEnabled -eq 'No' -AND $CurrentLink.Enabled -eq $True) { Set-GPLink -Guid $Gpo.Id -Target $Link.Target -LinkEnabled No }
                }

                If ($Link.Enforced -ne 'Unspecified') {
                    If ($Link.Enforced -eq 'Yes' -AND $CurrentLink.Enforced -eq $False) { Set-GPLink -Guid $Gpo.Id -Target $Link.Target -Enforced Yes }
                    Elseif ($Link.Enforced -eq 'No' -AND $CurrentLink.Enforced -eq $True) { Set-GPLink -Guid $Gpo.Id -Target $Link.Target -Enforced No }
                }

                If ($Link.Order -ne $CurrentLink.Order) { Set-GPLink -Guid $Gpo.Id -Target $Link.Target -Order $Link.Order }
            }
        }
    }

    If (($Purge) -OR ($GpoLinks -eq 'Unset')) {
        $AllGpoLinks = (Get-ADOrganizationalUnit -Filter 'Name -Like "*"') | Where LinkedGroupPolicyObjects -Match "{$($Gpo.Id)}"
        If ($GpoLinks -eq 'Unset') { $AllGpoLinks | % { Remove-GPLink -Guid $Gpo.Id -Target $_.DistinguishedName } }
        Else {
            $Compare = Compare-Object -ReferenceObject $AllGpoLinks.DistinguishedName -DifferenceObject $LinkObjects.Target
            If ($Compare -ne $Null) { $Compare | Where SideIndicator -eq '<=' | % { Remove-GPLink -Guid $Gpo.Id -Target $_.InputObject } }
        }
    }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GpoName,

        [Parameter(Mandatory=$True)]
        [string[]]$GpoLinks,

        [Parameter(Mandatory=$False)]
        [bool]$Purge = $False,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $Gpo = Get-GPO -Name $GpoName 

    If ($GpoLinks -ne "Unset") {
        $LinkObjects = $GpoLinks | % { 
            $Split = $_ -split ';'
            If ($Split[3].Trim() -eq 'Last') { $Order = 'Last' }
            Else { $Order = [int]$Split[3] }
            New-Object -TypeName PsObject -Property @{
                Target = $Split[0].Trim()
                LinkEnabled = $Split[1].Trim()
                Enforced = $Split[2].Trim()
                Order = $Order
            }
        }
    

        Foreach ($Link in $LinkObjects) { 
            If ($Link.LinkEnabled -notmatch "Yes|No|Unspecified") { Throw "The 'LinkEnabled' parameter must be set to either yes, no or unspecified." } 
            If ($Link.Enforced -notmatch "Yes|No|Unspecified") { Throw "The 'Enforced' parameter must be set to either yes, no or unspecified." } 
            If (($Link.Order -isnot [int]) -AND $Link.Order -ne 'Last') { Throw "The 'Order' parameter must be an integer or 'Last'." }
        }

        Foreach ($Link in $LinkObjects) {

            $AllLinks = (Get-GPInheritance -Target $Link.Target).GpoLinks
            $CurrentLink = $AllLinks | Where GpoId -eq $Gpo.Id
            If ($Link.Order -eq 'Last') { $Link.Order = $AllLinks.Count }
            If ($CurrentLink -eq $Null) { Return $False }
            Else{
                If ($Link.LinkEnabled -ne 'Unspecified') {
                    If ($Link.LinkEnabled -eq 'Yes' -AND $CurrentLink.Enabled -eq $False) { Return $False }
                    Elseif ($Link.LinkEnabled -eq 'No' -AND $CurrentLink.Enabled -eq $True) { Return $False }
                }

                If ($Link.Enforced -ne 'Unspecified') {
                    If ($Link.Enforced -eq 'Yes' -AND $CurrentLink.Enforced -eq $False) { Return $False }
                    Elseif ($Link.Enforced -eq 'No' -AND $CurrentLink.Enforced -eq $True) { Return $False }
                }

                If ($Link.Order -ne $CurrentLink.Order) { Return $False }
            }
        }
    }

    If (($Purge) -OR ($GpoLinks -eq 'Unset')) {
        $AllGpoLinks = (Get-ADOrganizationalUnit -Filter 'Name -Like "*"') | Where LinkedGroupPolicyObjects -Match "{$($Gpo.Id)}"
        If ($GpoLinks -eq 'Unset') { If ($AllGpoLinks -ne $Null) { Return $False } }
        Else {
            $Compare = Compare-Object -ReferenceObject $AllGpoLinks.DistinguishedName -DifferenceObject $LinkObjects.Target
            If ($Compare -ne $Null) { Return $False }
        }
    }

    Return $True
}
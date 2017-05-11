Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Filters,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True
    
    $FilterInfo = WdsUtil /Get-DriverGroup /DriverGroup:"$DriverGroup" /Show:Filters
    $LineCount = $FilterInfo.Count
    $LineNumbers = [array]($FilterInfo | Select-String -Pattern 'Filter Type').LineNumber
    $FilterCount = $LineNumbers.Count

    If (($Filters -eq 'Unset') -AND ($LineNumbers -ne $Null)) {
        Return @{
            DriverGroup  = $DriverGroup
            SetFilters   = $SetFilters
            DesiredState = $False
        }   
    }    
    Elseif (($Filters -eq 'Unset') -AND ($LineNumbers -eq $Null)) {
        Return @{
            DriverGroup  = $DriverGroup
            SetFilters   = $SetFilters
            DesiredState = $True
        }    
    }

    $CurrentFilters = @()
    Foreach ($LineNumber in $LineNumbers){
        $Index = $LineNumbers.IndexOf($LineNumber)
        If ($Index -eq ($FilterCount - 1)) { $EndLine = $LineCount }
        Else { $EndLine = $LineNumbers[$Index + 1] }

        $Filter = $FilterInfo[($LineNumber - 1)..($EndLine - 1)]    

        $CurrentFilters += New-Object -TypeName psobject -Property @{
            Type = [string](($Filter | Select-String -Pattern 'Filter Type') -split 'Type: ')[1].Trim().Replace(' ','')
            Policy = [string](($Filter | Select-String -Pattern 'Filter Policy') -split 'policy = ')[1].Trim()
            Values = [array]($Filter | Select-String -Pattern "Value").Line | % { ($_ -split '] = ')[1] }
        }  
    }
    
    $SetFilters = @()
    Foreach ($Filter in $Filters) {
        $Split = $Filter -split ';'
        $Count = $Split.Count
        $SetFilters += New-Object -TypeName psobject -Property @{
            Type = [string]$Split[0].Replace(' ','').Trim()
            Policy = [string]$Split[1].Trim()
            Values = [array]$Split[2..($Count - 1)]
        }      
    }

    Foreach ($Filter in $SetFilters) {
        $Check = $CurrentFilters | Where Type -eq $Filter.Type
        If ($Check -ne $Null) {
            If ($Filter.Policy -ne $Check.Policy) { $DesiredState = $False }
            $CompareValues = Compare-Object -ReferenceObject $Filter.Values -DifferenceObject $Check.Values
            If ($CompareValues -ne $Null) { $DesiredState = $False }
        }
        Else { $DesiredState = $False } 
    }

    Foreach ($Filter in $CurrentFilters){
        $Check = ($SetFilters | Where Type -eq $Filter.Type) -eq $Null
        If ($Check) { $DesiredState = $False }
    }
        
    Return @{
            DriverGroup  = $DriverGroup
            SetFilters   = $SetFilters
            DesiredState = $DesiredState
    }    
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Filters,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $FilterInfo = WdsUtil /Get-DriverGroup /DriverGroup:"$DriverGroup" /Show:Filters
    $LineCount = $FilterInfo.Count
    $LineNumbers = [array]($FilterInfo | Select-String -Pattern 'Filter Type').LineNumber
    $FilterCount = $LineNumbers.Count

    $CurrentFilters = @()
    Foreach ($LineNumber in $LineNumbers){
        $Index = $LineNumbers.IndexOf($LineNumber)
        If ($Index -eq ($FilterCount - 1)) { $EndLine = $LineCount }
        Else { $EndLine = $LineNumbers[$Index + 1] }

        $Filter = $FilterInfo[($LineNumber - 1)..($EndLine - 1)]    

        $CurrentFilters += New-Object -TypeName psobject -Property @{
            Type = [string](($Filter | Select-String -Pattern 'Filter Type') -split 'Type: ')[1].Trim().Replace(' ','')
            Policy = [string](($Filter | Select-String -Pattern 'Filter Policy') -split 'policy = ')[1].Trim()
            Values = [array]($Filter | Select-String -Pattern "Value").Line | % { ($_ -split '] = ')[1] }
        }  
    }

    If ($Filters -eq 'Unset') { Foreach ($Filter in $CurrentFilters) { WdsUtil /Remove-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" } }
    Else {
        $SetFilters = @()
        Foreach ($Filter in $Filters) {
            $Split = $Filter -split ';'
            $Count = $Split.Count
            $SetFilters += New-Object -TypeName psobject -Property @{
                Type = [string]$Split[0].Replace(' ','').Trim()
                Policy = [string]$Split[1].Trim()
                Values = [array]$Split[2..($Count - 1)]
            }      
        }

        Foreach ($Filter in $SetFilters) {
            $Check = $CurrentFilters | Where Type -eq $Filter.Type
            If ($Check -ne $Null) {
                If ($Filter.Policy -ne $Check.Policy) { WdsUtil /Set-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" /Policy:"$($Filter.Policy)"}
                $CompareValues = Compare-Object -ReferenceObject $Filter.Values -DifferenceObject $Check.Values | % {
                    If ($_.SideIndicator -eq '<=') { WdsUtil /Set-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" /AddValue:"$($_.InputObject)" }
                    Elseif ($_.SideIndicator -eq '=>') { WdsUtil /Set-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" /RemoveValue:"$($_.InputObject)" }
                }
            }
            Else {
                WdsUtil /Add-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" /Policy:"$($Filter.Policy)" /Value:"$($Filter.Values[0])"
                If ($Filter.Values.Count -gt 1) {
                    Foreach ($Value in $Filter.Values[1..($Filter.Values.Count -1 )]) {
                        WdsUtil /Set-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" /AddValue:"$Value"
                    }
                }
            } 
        }

        Foreach ($Filter in $CurrentFilters){
            $Check = ($SetFilters | Where Type -eq $Filter.Type) -eq $Null
            If ($Check) { WdsUtil /Remove-DriverGroupFilter /DriverGroup:"$DriverGroup" /FilterType:"$($Filter.Type)" }
        }
    }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DriverGroup,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Filters,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $FilterInfo = WdsUtil /Get-DriverGroup /DriverGroup:"$DriverGroup" /Show:Filters
    $LineCount = $FilterInfo.Count
    $LineNumbers = [array]($FilterInfo | Select-String -Pattern 'Filter Type').LineNumber
    $FilterCount = $LineNumbers.Count

    If (($Filters -eq 'Unset') -AND ($LineNumbers -ne $Null)) { Return $False }
    Elseif (($Filters -eq 'Unset') -AND ($LineNumbers -eq $Null)) { Return $True }

    $CurrentFilters = @()
    Foreach ($LineNumber in $LineNumbers){
        $Index = $LineNumbers.IndexOf($LineNumber)
        If ($Index -eq ($FilterCount - 1)) { $EndLine = $LineCount }
        Else { $EndLine = $LineNumbers[$Index + 1] }

        $Filter = $FilterInfo[($LineNumber - 1)..($EndLine - 1)]    

        $CurrentFilters += New-Object -TypeName psobject -Property @{
            Type = [string](($Filter | Select-String -Pattern 'Filter Type') -split 'Type: ')[1].Trim().Replace(' ','')
            Policy = [string](($Filter | Select-String -Pattern 'Filter Policy') -split 'policy = ')[1].Trim()
            Values = [array]($Filter | Select-String -Pattern "Value").Line | % { ($_ -split '] = ')[1] }
        }  
    }
    
    $SetFilters = @()
    Foreach ($Filter in $Filters) {
        $Split = $Filter -split ';'
        $Count = $Split.Count
        $SetFilters += New-Object -TypeName psobject -Property @{
            Type = [string]$Split[0].Replace(' ','').Trim()
            Policy = [string]$Split[1].Trim()
            Values = [array]$Split[2..($Count - 1)]
        }      
    }

    Foreach ($Filter in $SetFilters) {
        $Check = $CurrentFilters | Where Type -eq $Filter.Type
        If ($Check -ne $Null) {
            If ($Filter.Policy -ne $Check.Policy) { Return $False }
            $CompareValues = Compare-Object -ReferenceObject $Filter.Values -DifferenceObject $Check.Values
            If ($CompareValues -ne $Null) { Return $False }
        }
        Else { Return $False } 
    }

    Foreach ($Filter in $CurrentFilters){
        $Check = ($SetFilters | Where Type -eq $Filter.Type) -eq $Null
        If ($Check) { Return $False }
    }

    Return $True
}
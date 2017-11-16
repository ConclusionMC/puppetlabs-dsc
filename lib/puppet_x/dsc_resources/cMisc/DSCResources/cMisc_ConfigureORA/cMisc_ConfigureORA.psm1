Function Get-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$HomeName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBPort,

        [Parameter(Mandatory=$False)]
        [string]$DisableRULEHint = "T",

        [Parameter(Mandatory=$False)]
        [string]$Attributes = "W",

        [Parameter(Mandatory=$False)]
        [string]$SQLTranslateErrors = "F",

        [Parameter(Mandatory=$False)]
        [string]$MaxTokenSize = "8192",

        [Parameter(Mandatory=$False)]
        [string]$FetchBufferSize = "64000",

        [Parameter(Mandatory=$False)]
        [string]$NumericSetting = "NLS",

        [Parameter(Mandatory=$False)]
        [string]$ForceWCHAR = "F",

        [Parameter(Mandatory=$False)]
        [string]$FailoverDelay = "10",

        [Parameter(Mandatory=$False)]
        [string]$FailoverRetryCount = "10",

        [Parameter(Mandatory=$False)]
        [string]$MetadataIdDefault = "F",

        [Parameter(Mandatory=$False)]
        [string]$BindAsFLOAT = "F",

        [Parameter(Mandatory=$False)]
        [string]$BindAsDATE = "F",

        [Parameter(Mandatory=$False)]
        [string]$CloseCursor = "F",

        [Parameter(Mandatory=$False)]
        [string]$EXECSchemaOpt = "",

        [Parameter(Mandatory=$False)]
        [string]$EXECSyntax = "F",

        [Parameter(Mandatory=$False)]
        [string]$Application_Attributes = "T",

        [Parameter(Mandatory=$False)]
        [string]$QueryTimeout = "T",

        [Parameter(Mandatory=$False)]
        [string]$CacheBufferSize = "20",

        [Parameter(Mandatory=$False)]
        [string]$StatementCache = "F",

        [Parameter(Mandatory=$False)]
        [string]$ResultSets = "T",

        [Parameter(Mandatory=$False)]
        [string]$MaxLargeData = "0",

        [Parameter(Mandatory=$False)]
        [string]$UseOCIDescribeAny = "F",

        [Parameter(Mandatory=$False)]
        [string]$Failover = "T",

        [Parameter(Mandatory=$False)]
        [string]$Lobs = "T",

        [Parameter(Mandatory=$False)]
        [string]$DisableMTS = "T",

        [Parameter(Mandatory=$False)]
        [string]$DisableDPM = "F",

        [Parameter(Mandatory=$False)]
        [string]$BatchAutocommitMode = "IfAllSuccessful",

        [Parameter(Mandatory=$False)]
        [string]$Description = "",

        [Parameter(Mandatory=$False)]
        [string]$ServerName = "",

        [Parameter(Mandatory=$False)]
        [string]$Password = "",

        [Parameter(Mandatory=$False)]
        [string]$UserID = "",

        [Parameter(Mandatory=$False)]
        [string]$DSN = ""

    )

    $ODBC = "HKLM:\SOFTWARE\ODBC"
    $ORACLE = "HKLM:\SOFTWARE\ORACLE"

    If ((Test-Path $ODBC) -eq $False) { Throw "No ODBC installation found" }
    If ((Test-Path $ORACLE) -eq $False) { Throw "No ORACLE installation found" }

    $Inventory = Get-Item -Path $ORACLE | Get-ItemPropertyValue -Name "inst_loc"
    [xml]$InventoryXML = Get-Content -Path "$Inventory\ContentsXML\inventory.xml"
    $Homes = $InventoryXML.INVENTORY.HOME_LIST.HOME
    If ($Homes -eq $Null) { Throw "No oracle homes found in inventory." }
    $ORAHome = $Homes | Where NAME -match $HomeName
    If ($ORAHome -eq $Null) { Throw "$HomeName not found in oracle inventory." }

    $CreateItems = @()
    If ((Test-Path "$ODBC\ODBC.INI\ODBC Data Sources") -eq $False) { $CreateItems += "$ODBC\ODBC.INI\ODBC Data Sources" }
    Else { $DataSources = Get-Item "$ODBC\ODBC.INI\ODBC Data Sources" }
    If ((Test-Path "$ODBC\ODBC.INI\$ConnectionName") -eq $False) { $CreateItems += "$ODBC\ODBC.INI\$ConnectionName" }
    Else { $Connection = Get-Item "$ODBC\ODBC.INI\$ConnectionName" }
    
    $Keys = $MyInvocation.MyCommand.Parameters.Keys | ?  { $_ -notmatch "(variable)|(outbuffer)|(action)|(verbose)|(debug)|(homename)|(dbhost)|(dbport)|(connectionname)" }
    $Properties = @{}
    Foreach ($Key in $Keys) { $Properties.Add($Key, (Get-Variable -Name $Key -ValueOnly)) }
    $Properties.Add("Driver","$($ORAHome.LOC)\BIN\SQORA32.DLL")

    $CreateProperties = @()
    $SetProperties = @()
    If ($DataSources -eq $Null) { $CreateProperties += @{ Path = "$ODBC\ODBC.INI\ODBC Data Sources" ; Name = $ConnectionName ; Value = "Oracle in $($ORAHome.NAME)" } }
    Else {
        If ($ConnectionName -notin $DataSources.GetValueNames()) { $CreateProperties += @{ Path = $DataSources.PSPath ; Name = $ConnectionName ; Value = "Oracle in $($ORAHome.NAME)" } }
        Elseif ($DataSources.GetValue($ConnectionName) -ne "Oracle in $($ORAHome.NAME)") { $SetProperties += @{ Path = $DataSources.PSPath ; Name = $ConnectionName ; Value = "Oracle in $($ORAHome.NAME)" } }
    }

    If ($Connection -eq $Null) {
        Foreach ($Property in $Properties.GetEnumerator()) {
            $Key = $Property.Key.Replace('_',' ')
            $CreateProperties += @{ Path = "$ODBC\ODBC.INI\$ConnectionName" ; Name = $Key ; Value = $Property.Value }
        }
    }
    Else {
        $Values = $Connection.GetValueNames()
        Foreach ($Property in $Properties.GetEnumerator()) {
            $Key = $Property.Key.Replace('_',' ')
            If ($Key -notin $Values) { $CreateProperties += @{ Path = $Connection.PSPath ; Name = $Key ; Value = $Property.Value } }
            Else {
                $Value = $Connection.GetValue($Key)
                If ($Value -ne $Property.Value) { $SetProperties += @{ Path = $Connection.PSPath ; Name = $Key ; Value =  $Property.Value } }
            }
        }
    }

    $TnsNames = "$($ORAHome.LOC)\network\admin\tnsnames.ora"
    If ((Test-Path $TnsNames) -eq $False) { $CreateTnsNames = $True ; $SetTnsNames = $True }
    Else { $CreateTnsNames = $False }

    $TnsName  = @()
    $TnsName += "$ConnectionName ="
    $TnsName += "  (DESCRIPTION ="
    $TnsName += "    (ADDRESS_LIST ="
    $TnsName += "      (ADDRESS = (PROTOCOL = TCP)(HOST = $DBHOST)(PORT = $DBPort))"
    $TnsName += "    )"
    $TnsName += "    (CONNECT_DATA = (SERVICE_NAME = $ConnectionName))"
    $TnsName += "  )"

    If ($CreateTnsNames -eq $False) {
        $Content = @(Get-Content -Path $TnsNames)
        $Comparison = Compare-Object -ReferenceObject $Content -DifferenceObject $TnsName
        If ($Comparison.Count -gt 0) { $SetTnsNames = $True }
        Else { $SetTnsNames = $False }
    }

    If ( ($CreateItems.Count -gt 0) -or ($CreateProperties.Count -gt 0) -or ($SetProperties.Count -gt 0) -or $CreateTnsNames -or $SetTnsNames ) { $DesiredState = $False }
    Else { $DesiredState = $True }

    Return @{
        DesiredState = $DesiredState
        CreateItems = $CreateItems
        CreateProperties = $CreateProperties
        SetProperties = $SetProperties
        CreateTnsNames = $CreateTnsNames
        SetTnsNames = $SetTnsNames
        TnsName = $TnsName
        TnsPath = $TnsNames
    }
}

Function Set-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$HomeName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBPort,

        [Parameter(Mandatory=$False)]
        [string]$DisableRULEHint = "T",

        [Parameter(Mandatory=$False)]
        [string]$Attributes = "W",

        [Parameter(Mandatory=$False)]
        [string]$SQLTranslateErrors = "F",

        [Parameter(Mandatory=$False)]
        [string]$MaxTokenSize = "8192",

        [Parameter(Mandatory=$False)]
        [string]$FetchBufferSize = "64000",

        [Parameter(Mandatory=$False)]
        [string]$NumericSetting = "NLS",

        [Parameter(Mandatory=$False)]
        [string]$ForceWCHAR = "F",

        [Parameter(Mandatory=$False)]
        [string]$FailoverDelay = "10",

        [Parameter(Mandatory=$False)]
        [string]$FailoverRetryCount = "10",

        [Parameter(Mandatory=$False)]
        [string]$MetadataIdDefault = "F",

        [Parameter(Mandatory=$False)]
        [string]$BindAsFLOAT = "F",

        [Parameter(Mandatory=$False)]
        [string]$BindAsDATE = "F",

        [Parameter(Mandatory=$False)]
        [string]$CloseCursor = "F",

        [Parameter(Mandatory=$False)]
        [string]$EXECSchemaOpt = "",

        [Parameter(Mandatory=$False)]
        [string]$EXECSyntax = "F",

        [Parameter(Mandatory=$False)]
        [string]$Application_Attributes = "T",

        [Parameter(Mandatory=$False)]
        [string]$QueryTimeout = "T",

        [Parameter(Mandatory=$False)]
        [string]$CacheBufferSize = "20",

        [Parameter(Mandatory=$False)]
        [string]$StatementCache = "F",

        [Parameter(Mandatory=$False)]
        [string]$ResultSets = "T",

        [Parameter(Mandatory=$False)]
        [string]$MaxLargeData = "0",

        [Parameter(Mandatory=$False)]
        [string]$UseOCIDescribeAny = "F",

        [Parameter(Mandatory=$False)]
        [string]$Failover = "T",

        [Parameter(Mandatory=$False)]
        [string]$Lobs = "T",

        [Parameter(Mandatory=$False)]
        [string]$DisableMTS = "T",

        [Parameter(Mandatory=$False)]
        [string]$DisableDPM = "F",

        [Parameter(Mandatory=$False)]
        [string]$BatchAutocommitMode = "IfAllSuccessful",

        [Parameter(Mandatory=$False)]
        [string]$Description = "",

        [Parameter(Mandatory=$False)]
        [string]$ServerName = "",

        [Parameter(Mandatory=$False)]
        [string]$Password = "",

        [Parameter(Mandatory=$False)]
        [string]$UserID = "",

        [Parameter(Mandatory=$False)]
        [string]$DSN = ""

    )

    $CurrentState = Get-TargetResource @PSBoundParameters

    $CurrentState.CreateItems | % { New-Item -Path $_ -Force }
    $CurrentState.CreateProperties | % { New-ItemProperty -Path $_.Path -Name $_.Name -Value $_.Value }
    $CurrentState.SetProperties | % { Set-ItemProperty -Path $_.Path -Name $_.Name -Value $_.Value }
    If ($CurrentState.CreateTnsNames -eq $True) { New-Item -Path $CurrentState.TnsPath -ItemType File -Force }
    If ($CurrentState.SetTnsNames -eq $True) { Set-Content -Path $CurrentState.TnsPath -Value $CurrentState.TnsName }
}

Function Test-TargetResource {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$HomeName,
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBPort,

        [Parameter(Mandatory=$False)]
        [string]$DisableRULEHint = "T",

        [Parameter(Mandatory=$False)]
        [string]$Attributes = "W",

        [Parameter(Mandatory=$False)]
        [string]$SQLTranslateErrors = "F",

        [Parameter(Mandatory=$False)]
        [string]$MaxTokenSize = "8192",

        [Parameter(Mandatory=$False)]
        [string]$FetchBufferSize = "64000",

        [Parameter(Mandatory=$False)]
        [string]$NumericSetting = "NLS",

        [Parameter(Mandatory=$False)]
        [string]$ForceWCHAR = "F",

        [Parameter(Mandatory=$False)]
        [string]$FailoverDelay = "10",

        [Parameter(Mandatory=$False)]
        [string]$FailoverRetryCount = "10",

        [Parameter(Mandatory=$False)]
        [string]$MetadataIdDefault = "F",

        [Parameter(Mandatory=$False)]
        [string]$BindAsFLOAT = "F",

        [Parameter(Mandatory=$False)]
        [string]$BindAsDATE = "F",

        [Parameter(Mandatory=$False)]
        [string]$CloseCursor = "F",

        [Parameter(Mandatory=$False)]
        [string]$EXECSchemaOpt = "",

        [Parameter(Mandatory=$False)]
        [string]$EXECSyntax = "F",

        [Parameter(Mandatory=$False)]
        [string]$Application_Attributes = "T",

        [Parameter(Mandatory=$False)]
        [string]$QueryTimeout = "T",

        [Parameter(Mandatory=$False)]
        [string]$CacheBufferSize = "20",

        [Parameter(Mandatory=$False)]
        [string]$StatementCache = "F",

        [Parameter(Mandatory=$False)]
        [string]$ResultSets = "T",

        [Parameter(Mandatory=$False)]
        [string]$MaxLargeData = "0",

        [Parameter(Mandatory=$False)]
        [string]$UseOCIDescribeAny = "F",

        [Parameter(Mandatory=$False)]
        [string]$Failover = "T",

        [Parameter(Mandatory=$False)]
        [string]$Lobs = "T",

        [Parameter(Mandatory=$False)]
        [string]$DisableMTS = "T",

        [Parameter(Mandatory=$False)]
        [string]$DisableDPM = "F",

        [Parameter(Mandatory=$False)]
        [string]$BatchAutocommitMode = "IfAllSuccessful",

        [Parameter(Mandatory=$False)]
        [string]$Description = "",

        [Parameter(Mandatory=$False)]
        [string]$ServerName = "",

        [Parameter(Mandatory=$False)]
        [string]$Password = "",

        [Parameter(Mandatory=$False)]
        [string]$UserID = "",

        [Parameter(Mandatory=$False)]
        [string]$DSN = ""

    )
    
    Return (Get-TargetResource @PSBoundParameters).DesiredState
}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JavaPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OraHomeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DBPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DataSets,


        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQManager,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSTransportType,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSUsername,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSPassword

    )

    $CurrentOwner = (Get-ClusterGroup -Name $GroupName).OwnerNode.Name-eq $env:COMPUTERNAME

    $ORACLE = "HKLM:\SOFTWARE\ORACLE"
    $Inventory = Get-Item -Path $ORACLE | Get-ItemPropertyValue -Name "inst_loc"
    [xml]$InventoryXML = Get-Content -Path "$Inventory\ContentsXML\inventory.xml"
    $Homes = $InventoryXML.INVENTORY.HOME_LIST.HOME
    If ($Homes -eq $Null) { Throw "No oracle homes found in inventory." }
    $ORAHome = ($Homes | Where NAME -match $OraHomeName).LOC
    If ($ORAHome -eq $Null) { Throw "$OraHomeName not found in oracle inventory." }
    $MQJar = "$($ClusterDisk.Replace('\',''))\Crews-Adaptor\com.ibm.mq.runtime_7.0.1.3\lib\com.ibm.mqjms.jar"
    $OracleJar = "$ORAHome\jdbc\lib"

    If ($CurrentOwner) {

        If (-not (Test-Path "$ClusterDisk\Crews-Adaptor")) { $Expanded = $False }
        Else { $Expanded = $True }

        If (-not (Test-Path "$ClusterDisk\Crews-Adaptor\crews-local.cmd")) { $JavaCorrect = $False ; $MQJarCorrect = $False ; $OracleJarCorrect = $False }
        Else {
            $CurrJavaPath = ((Get-Content -Path "$ClusterDisk\Crews-Adaptor\crews-local.cmd" | Select-String "set JAVA_HOME") -split "=")[1]
            $JavaCorrect = $CurrJavaPath -eq $JavaPath
            $CurrMQJar = ((Get-Content -Path "$ClusterDisk\Crews-Adaptor\crews-local.cmd" | Select-String "set MQJAR") -split "=")[1]
            $MQJarCorrect = $CurrMQJar -eq $MQJar
            $CurrOracleJar = ((Get-Content -Path "$ClusterDisk\Crews-Adaptor\crews-local.cmd" | Select-String "set ORACLEJAR") -split "=")[1]
            $OracleJarCorrect = $CurrOracleJar -eq $OracleJar
        }

        If (-not (Test-Path "$ClusterDisk\Crews-Adaptor\config\crews-adaptor.properties")) { $ConfigCorrect = $False }
        Else { $ConfigCorrect = Configure-PropertiesFile @PSBoundParameters -ReturnBoolean }

        If (-not (Test-Path "$ClusterDisk\Crews-Adaptor\config\datasets.xml")) { $DataSetsCorrect = $False }
        Else {
            $DataSetsCorrect = $True
            $DataSetsXML = [xml](Get-Content -Path "$ClusterDisk\Crews-Adaptor\config\datasets.xml")
            $RequiredDatasets = $DataSets | % { ((($_ -split ";") | ? { $_ -match "user=" }) -split "=")[1] }
            $CurrentDatasets = $DataSetsXML.datasets.dataset.user
            $ToRemove = (Compare-Object -ReferenceObject $RequiredDatasets -DifferenceObject $CurrentDatasets | Where SideIndicator -eq "=>").InputObject        
            Foreach ($Dataset in $DataSets){
                $DataSet -split ';' | % -Begin { $Properties = @{} } -Process { $Split = $_ -split "=" ; $Properties.Add($Split[0],$Split[1]) }
                $CurrDataSet = $DataSetsXML.datasets.dataset | Where user -eq $Properties.user
                If ($CurrDataSet -eq $Null) { $DataSetsCorrect = $False }
                Else {
                    Foreach ($Property in $Properties.GetEnumerator()) {
                        $CurrentValue = $CurrDataSet.($Property.Key)
                        If ([string]::IsNullOrEmpty($CurrentValue)) { $DataSetsCorrect = $False }
                        Elseif ($CurrentValue -ne $Property.Value) { $DataSetsCorrect = $False }            
                    }
                }
            }
            If ($ToRemove -ne $Null) { $DataSetsCorrect = $False }
        }

    } Else { $Expanded = $True ; $JavaCorrect = $True ; $MQJarCorrect = $True ; $OracleJarCorrect = $True ; $ConfigCorrect = $True ; $DataSetsCorrect = $True }
    
    $Installed = (Get-Service -Name "CrewsAdaptor" -ErrorAction SilentlyContinue) -ne $Null

    $Parameters = @(
        @{ Name = 'Current Directory' ; Value = "$($ClusterDisk.Replace('\',''))\Crews-Adaptor" }
        @{ Name = 'JVM Library' ; Value = "$JavaPath\bin\server\jvm.dll" }
        @{ Name = 'JVM Option Number 0' ; Value = "-Djava.class.path=$($ClusterDisk.Replace('\',''))\Crews-Adaptor\config;$MQJar;$OracleJar;$($ClusterDisk.Replace('\',''))\Crews-Adaptor\lib\crews-adaptor-main.jar" }
        @{ Name = 'System.err File' ; Value = "$($ClusterDisk.Replace('\',''))\Crews-Adaptor\log\stderr.log" }
        @{ Name = 'System.out File' ; Value = "$($ClusterDisk.Replace('\',''))\Crews-Adaptor\log\stdout.log" }
    ) 

    If ($Installed) {
        $RegCrewsAdaptor = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Services\CrewsAdaptor"
        $RegParameters = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Services\CrewsAdaptor\Parameters"
        $CurrParameters = $RegParameters.GetValueNames()
        $CorrectImagePath = $RegCrewsAdaptor.GetValue('ImagePath') -eq "$($ClusterDisk.Replace('\',''))\Crews-Adaptor\crews-service.exe" 
        $CorrectParameters = $True
        Foreach ($Parameter in $Parameters) {
            If ($Parameter.Name -notin $CurrParameters) { $CorrectParameters = $False }
            Elseif ($RegParameters.GetValue($Parameter.Name) -ne $Parameter.Value) { $CorrectParameters = $False }
        }
    }
    Elseif (!$CurrentOwner) { $CorrectImagePath = $False ; $CorrectParameters = $False }
    Else { $CorrectImagePath = $True ; $CorrectParameters = $True }

    If ($CurrentOwner) { 
        $Clustered = (Get-ClusterResource -Name "CrewsAdaptor" -ErrorAction SilentlyContinue) -ne $Null 
        $CorrectParam = (Get-ClusterResource -Name "CrewsAdaptor" -ErrorAction SilentlyContinue | Get-ClusterParameter | Where Name -eq "ServiceName").Value -eq "CrewsAdaptor"
        $Online = (Get-ClusterResource -Name "CrewsAdaptor" -ErrorAction SilentlyContinue -Verbose:$False).State -eq 'Online'
    }
    Else { $Clustered = $True ; $CorrectParam = $True ; $Online = $True }

    If ( ($Installed -eq $True -and $Expanded -eq $True -and $Clustered -eq $True -and $CurrentOwner) -and ($ConfigCorrect -eq $False -or $DataSetsCorrect -eq $False -or $CorrectParameters -eq $False -or $CorrectParam -eq $False -or $CorrectImagePath -eq $False) ) {
         $RequireRestart = $True
    } Else { $RequireRestart = $False }

    If ($Expanded -eq $False -or $JavaCorrect -eq $False -or $MQJarCorrect -eq $False -or $OracleJarCorrect -eq $False -or $ConfigCorrect -eq $False -or $DataSetsCorrect -eq $False -or $Installed -eq $False -or $CorrectParameters -eq $False -or $CorrectImagePath -eq $False -or $Clustered -eq $False -or $CorrectParam -eq $False -or $Online -eq $False) {
        $DesiredState = $False
    } Else { $DesiredState = $True }

    Return @{
        Expanded = $Expanded
        JavaCorrect = $JavaCorrect
        MQJarCorrect = $MQJarCorrect
        OracleJarCorrect = $OracleJarCorrect
        ConfigCorrect = $ConfigCorrect
        DataSetsCorrect = $DataSetsCorrect
        Installed = $Installed
        CorrectImagePath = $CorrectImagePath
        Clustered = $Clustered
        CorrectParam = $CorrectParam
        CorrectParameters = $CorrectParameters
        Parameters = $Parameters
        Online = $Online
        RequireRestart = $RequireRestart
        MQJar = $MQJar
        OracleJar = $OracleJar
        DesiredState = $DesiredState
    }
}

Function Set-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JavaPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OraHomeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DBPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DataSets,


        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQManager,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSTransportType,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSUsername,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSPassword

    )

    $CurrentState = Get-TargetResource @PSBoundParameters

    If ($CurrentState.Expanded -eq $False) {
        Write-Verbose "Expanding archive"
        Expand-Archive -Path "$PSScriptRoot\CrewsAdaptor.zip" -DestinationPath "$ClusterDisk\Crews-Adaptor" 
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log" -ItemType Directory -Force -ErrorAction SilentlyContinue
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log\spring" -ItemType Directory -Force -ErrorAction SilentlyContinue
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log\archive" -ItemType Directory -Force -ErrorAction SilentlyContinue
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log\_scom" -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    If ($CurrentState.JavaCorrect -eq $False -or $CurrentState.MQJarCorrect -eq $False -or $CurrentState.OracleJarCorrect -eq $False) {
        $CrewsLocal = Get-Content -Path "$ClusterDisk\Crews-Adaptor\crews-local.cmd"
        If ($CurrentState.JavaCorrect -eq $False) {
            Write-Verbose "Configuring java path"
            $JavaMatch = $CrewsLocal | Select-String "set JAVA_HOME"
            $CurrJavaPath = ($JavaMatch -split "=")[1]
            $CrewsLocal[$JavaMatch.Linenumber - 1] = $CrewsLocal[$JavaMatch.Linenumber - 1].Replace($CurrJavaPath,$JavaPath)
        }
        If ($CurrentState.MQJarCorrect -eq $False) {
            Write-Verbose "Configuring mq jar path"
            $MQJarMatch = $CrewsLocal | Select-String "set MQJAR"
            $CurrMQJar = ($MQJarMatch -split "=")[1]
            $CrewsLocal[$MQJarMatch.Linenumber - 1] = $CrewsLocal[$MQJarMatch.Linenumber - 1].Replace($CurrMQJar,$CurrentState.MQJar)
        }
        If ($CurrentState.OracleJarCorrect -eq $False) {
            Write-Verbose "Configuring oracle jar path"
            $OracleJarMatch = $CrewsLocal | Select-String "set ORACLEJAR"
            $CurrOracleJar = ($OracleJarMatch -split "=")[1]
            $CrewsLocal[$OracleJarMatch.Linenumber - 1] = $CrewsLocal[$OracleJarMatch.Linenumber - 1].Replace($CurrOracleJar,$CurrentState.OracleJar)
        }
        Set-Content -Path "$ClusterDisk\Crews-Adaptor\crews-local.cmd" -Value $CrewsLocal
    }
    If ($CurrentState.ConfigCorrect -eq $False) { Write-Verbose "Configuring properties file" ; Configure-PropertiesFile @PSBoundParameters }
    If ($CurrentState.DataSetsCorrect -eq $False) {
        Write-Verbose "Configuring datasets file"
        $DataSetsXML = [xml](Get-Content -Path "$ClusterDisk\Crews-Adaptor\config\datasets.xml")
        $RequiredDatasets = $DataSets | % { ((($_ -split ";") | ? { $_ -match "user=" }) -split "=")[1] }
        $CurrentDatasets = $DataSetsXML.datasets.dataset.user
        $ToRemove = (Compare-Object -ReferenceObject $RequiredDatasets -DifferenceObject $CurrentDatasets | Where SideIndicator -eq "=>").InputObject
        Foreach ($Dataset in $DataSets){
            $DataSet -split ';' | % -Begin { $Properties = @{} } -Process { $Split = $_ -split "=" ; $Properties.Add($Split[0],$Split[1]) }
            $CurrDataSet = $DataSetsXML.datasets.dataset | Where user -eq $Properties.user
            If ($CurrDataSet -eq $Null) {
                [xml]$Child = "<dataset $(($Properties.GetEnumerator() | % { ("$($_.Key)=" + '"' + "$($_.Value)" + '"') }) -join " ") $('vertraging="true" dienstregeling="true" materieelplan="false"/>')"
                $DataSetsXML.datasets.AppendChild($DataSetsXML.ImportNode($Child.dataset,$True))
            }
            Else {
                Foreach ($Property in $Properties.GetEnumerator()) {
                    $CurrentValue = $CurrDataSet.($Property.Key)
                    If ([string]::IsNullOrEmpty($CurrentValue)) {
                        $Attribute = $CurrDataSet.OwnerDocument.CreateAttribute($Property.Key)
                        $CurrDataSet.Attributes.Append($Attribute)
                        $CurrDataSet.SetAttribute($Property.Key, $Property.Value)
                    }
                    Elseif ($CurrentValue -ne $Property.Value) { $CurrDataSet.SetAttribute($Property.Key, $Property.Value) }            
                }
            }
        }
        If ($ToRemove -ne $Null) {
            Foreach ($DataSet in @($ToRemove)) {
                $Remove = @($DataSetsXML.datasets.dataset | Where user -eq $DataSet)[0]
                $DataSetsXml.datasets.RemoveChild($Remove)
            }
        }
        $DataSetsXML.Save("$ClusterDisk\Crews-Adaptor\config\datasets.xml")
    }
    If ($CurrentState.Installed -eq $False) { 
        Write-Verbose "Installing Crews Adaptor"
        If (!(Test-Path $ClusterDisk)) {
            New-Item -Path "$PSScriptRoot\Temp" -ItemType Directory -Force
            Expand-Archive -Path "$PSScriptRoot\CrewsAdaptor.zip" -DestinationPath "$PSScriptRoot\Temp"
            Start-Process -FilePath "$PSScriptRoot\Temp\install-crews.cmd" -Wait
            Remove-Item "$PSScriptRoot\Temp" -Recurse -Force
        }
        Else { Start-Process -FilePath "$ClusterDisk\Crews-Adaptor\install-crews.cmd" -Wait }
    }
    If ($CurrentState.CorrectImagePath -eq $False) { Write-Verbose "Setting imagepath in registry" ; Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\CrewsAdaptor" -Name 'ImagePath' -Value "$($ClusterDisk.Replace('\',''))\Crews-Adaptor\crews-service.exe" }
    If ($CurrentState.CorrectParameters -eq $False) { 
        Write-Verbose "Setting registry parameters"
        $RegParameters = Get-Item "HKLM:\SYSTEM\CurrentControlSet\Services\CrewsAdaptor\Parameters"
        $CurrParameters = $RegParameters.GetValueNames()
        Foreach ($Parameter in $CurrentState.Parameters) {
            If ($Parameter.Name -notin $CurrParameters) { New-ItemProperty -Path $RegParameters.PSPath -Name $Parameter.Name -Value $Parameter.Value -PropertyType 'string' }
            Elseif ($RegParameters.GetValue($Parameter.Name) -ne $Parameter.Value) { Set-ItemProperty -Path $RegParameters.PSPath -Name $Parameter.Name -Value $Parameter.Value }
        }
    }
    If ($CurrentState.Clustered -eq $False) { Write-Verbose "Clustering Crews Adaptor" ; Add-ClusterResource -Name "CrewsAdaptor" -ResourceType "Generic Service" -Group $GroupName -Verbose:$False }
    If ($CurrentState.CorrectParam -eq $False) { Write-Verbose "Configuring Crews Adaptor" ; Get-ClusterResource -Name "CrewsAdaptor" | Set-ClusterParameter -Name ServiceName -Value "CrewsAdaptor" -Verbose:$False }
    If ($CurrentState.Online -eq $True -and $CurrentState.RequireRestart -eq $True) {
        Write-Verbose "Restarting Crews Adaptor"
        Get-ClusterResource -Name "CrewsAdaptor" -Verbose:$False | Stop-ClusterResource -Verbose:$False
        Get-ClusterResource -Name "CrewsAdaptor" -Verbose:$False | Start-ClusterResource -Verbose:$False
    }
    Elseif ($CurrentState.Online -eq $False) { Write-Verbose "Starting Crews Adaptor" ; Get-ClusterResource -Name "CrewsAdaptor" -Verbose:$False | Start-ClusterResource -Verbose:$False }
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JavaPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OraHomeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DBPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DataSets,


        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQManager,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSTransportType,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSUsername,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSPassword

    )
    Return (Get-TargetResource @PSBoundParameters).DesiredState
}

Function Configure-PropertiesFile {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JavaPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OraHomeName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$DBHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DBPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DataSets,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSHost,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSPort,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQManager,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [uint32]$JMSTransportType,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSQName,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSUsername,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JMSPassword,

        [Parameter(Mandatory=$False)]
        [switch]$ReturnBoolean

    )

    $ConfigProperties = Get-Content -Path "$ClusterDisk\Crews-Adaptor\config\crews-adaptor.properties"
    $JDBC = $ConfigProperties | Select-String "jdbc.url" | ? { $_.Line.StartsWith('#') -eq $False }

    $Checks = @(
        @{
            Type = [string]
            Regex = '(?<=HOST=).+?(?=\))'
            SearchString = $Null
            LineNumber = $JDBC.LineNumber
            Value = $DBHost
        },
        @{
            Type = [int]
            Regex = '(?<=PORT=).+?(?=\))'
            SearchString = $Null
            LineNumber = $JDBC.LineNumber
            Value = $DBPort
        },
        @{
            Type = [string]
            Regex = '(?<=SERVICE_NAME=).+?(?=\))'
            SearchString = $Null
            LineNumber = $JDBC.LineNumber
            Value = $ServiceName
        },
        @{
            Type = [string]
            Regex = $Null
            SearchString = "jms.host"
            LineNumber = ($ConfigProperties | Select-String "jms.host").LineNumber
            Value = $JMSHost
        },
        @{
            Type = [int]
            Regex = $Null
            SearchString = "jms.port"
            LineNumber = ($ConfigProperties | Select-String "jms.port").LineNumber
            Value = $JMSPort
        },
        @{
            Type = [string]
            Regex = $Null
            SearchString = "jms.queueManager"
            LineNumber = ($ConfigProperties | Select-String "jms.queueManager").LineNumber
            Value = $JMSQManager
        },
        @{
            Type = [int]
            Regex = $Null
            SearchString = "jms.transporttype"
            LineNumber = ($ConfigProperties | Select-String "jms.transporttype").LineNumber
            Value = $JMSTransportType
        },
        @{
            Type = [string]
            Regex = $Null
            SearchString = "jms.queuename"
            LineNumber = ($ConfigProperties | Select-String "jms.queuename").LineNumber
            Value = $JMSQName
        },
        @{
            Type = [string]
            Regex = $Null
            SearchString = "jms.username"
            LineNumber = ($ConfigProperties | Select-String "jms.username").LineNumber
            Value = $JMSUsername
        },
        @{
            Type = [string]
            Regex = $Null
            SearchString = "jms.password"
            LineNumber = ($ConfigProperties | Select-String "jms.password").LineNumber
            Value = $JMSPassword
        }
    )

    Foreach ($Check in $Checks) {
        If (![string]::IsNullOrEmpty($Check.Regex)) { $CurrentValue = ([regex]::match($ConfigProperties[$Check.LineNumber - 1],$Check.Regex)).Value }
        Elseif (![string]::IsNullOrEmpty($Check.SearchString)) { $CurrentValue = ($ConfigProperties[$Check.LineNumber - 1] -split "=")[1].Trim() } 
        $CurrentValue = $CurrentValue.ToType($Check.Type,$Null)
        If ($CurrentValue -ne $Check.Value) {
            If ($ReturnBoolean) { Return $False }
            Elseif (![string]::IsNullOrEmpty($Check.SearchString)) { 
                $ConfigProperties[$Check.LineNumber - 1] = $ConfigProperties[$Check.LineNumber - 1].Replace($CurrentValue.ToString(),$Check.Value.ToString())
                $ConfigChanged = $True 
            }
            Elseif (![string]::IsNullOrEmpty($Check.Regex)) { 
                $ConfigProperties[$Check.LineNumber - 1] = $ConfigProperties[$Check.LineNumber - 1] -replace $Check.regex,$Check.Value.ToString()
                $ConfigChanged = $True 
            }
        }
    }
    If ($ReturnBoolean) { Return $True } 
    Elseif ($ConfigChanged) { Set-Content -Path "$ClusterDisk\Crews-Adaptor\config\crews-adaptor.properties" -Value $ConfigProperties }
}
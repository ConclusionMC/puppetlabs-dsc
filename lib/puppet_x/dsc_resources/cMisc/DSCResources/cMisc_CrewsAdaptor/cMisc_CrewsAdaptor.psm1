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
    
    $TestResource = (Get-PSCallStack).Command[1] -eq 'Test-TargetResource'

    $ClusterDisk = "$($ClusterDisk.Replace('\','').Replace(':','').Trim()):"
    $CurrentOwner = (Get-ClusterGroup -Name $GroupName).OwnerNode.Name -eq $env:COMPUTERNAME
    $ClusterOnline = (Get-ClusterResource -Name $GroupName -ErrorAction SilentlyContinue) -ne $Null
    $ClusterDiskAvailable = Test-Path "${ClusterDisk}"
    $ServiceInstalled = (Get-Service -Name "CrewsAdaptor" -ErrorAction SilentlyContinue) -ne $Null
    $Inventory = [xml](Get-Content -Path "$((Get-Item -Path "HKLM:\SOFTWARE\ORACLE" | Get-ItemPropertyValue -Name "inst_loc"))\ContentsXML\inventory.xml")
    $OraHomeAvailable = ($Inventory.INVENTORY.HOME_LIST.HOME | Where NAME -eq $OraHomeName) -ne $Null
    If ($OraHomeAvailable) { $OraHome = ($Inventory.INVENTORY.HOME_LIST.HOME | Where NAME -eq $OraHomeName).LOC }
    Else { Throw "$OraHomeName could not be found" }

    $Result = @{
        DesiredState = $True
        ClusterDisk = $ClusterDisk
        OraHome = $OraHome
        Actions = @()
    }

    #Expanded
    If ($ClusterDiskAvailable) { 
        $Expanded = Test-Path "${ClusterDisk}\crews-adaptor\crews-service.exe"
        If (-not $Expanded) { If ($TestResource) { Return @{ DesiredState  = $False } } Else { $Result.Actions += "ExpandArchive" } }
    }
    
    #Installed
    If (-not $ServiceInstalled) { 
        If ($TestResource) { Return @{ DesiredState  = $False } } 
        Elseif ($ClusterDiskAvailable) { $Result.Actions += "InstallService" }
        Else { $Result.Actions += @("InstallServiceTemp","ConfigureRegistry") }
    }

    #Registered
    $Registered = Configure-Registry -ClusterDisk $ClusterDisk -JavaPath $JavaPath -OraHome $OraHome -ReturnBoolean
    If (-not $Registered) {
        If ($TestResource) { Return @{ DesiredState  = $False } } 
        Else { $Result.Actions += "ConfigureRegistry" }
    }

    #crews-adaptor.properties
    If ($ClusterDiskAvailable) {
        If ($Expanded -eq $True) {
            $Configured = Configure-PropertiesFile @PSBoundParameters -ReturnBoolean
            If (-not $Configured) {
                If ($TestResource) { Return @{ DesiredState  = $False } } 
                Else { $Result.Actions += "ConfigureProperties" }
            }
        } Else { $Result.Actions += "ConfigureProperties" }
    }

    #datasets.xml
    If ($ClusterDiskAvailable) {
        If ($Expanded -eq $True) {
            $CorrectDatasets = Configure-DataSets -ClusterDisk $ClusterDisk -DataSets $DataSets -ReturnBoolean
            If (-not $CorrectDatasets) {
                If ($TestResource) { Return @{ DesiredState = $False } }
                Else { $Result.Actions += "ConfigureDatasets" }
            }
        }
        Else { $Result.Actions += "ConfigureDatasets" }
    }

    #Clustered
    If ($CurrentOwner -and $ClusterOnline -and $ClusterDiskAvailable) {
        $Clustered = (Get-ClusterResource -Name "CrewsAdaptor" -ErrorAction SilentlyContinue) -ne $Null
        If (-not $Clustered) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "ClusterService" }
        }
    }

    #Parameter set
    If ($CurrentOwner -and $ClusterOnline) {
        $ParameterSet = (Get-ClusterResource -Name "CrewsAdaptor" -ErrorAction SilentlyContinue | Get-ClusterParameter | Where Name -eq "ServiceName").Value -eq "CrewsAdaptor"
        If (-not $ParameterSet) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "SetClusterParameter" }
        }
    }

    #Online
    If ($CurrentOwner -and $ClusterOnline) {
        $Online = (Get-ClusterResource -Name "CrewsAdaptor" -ErrorAction SilentlyContinue).State -eq 'Online'
        If (-not $Online) {
            If ($TestResource) { Return @{ DesiredState = $False } }
            Else { $Result.Actions += "BringOnline" }
        }
    }

    #Restart service
    If (($Result.Actions -contains 'ConfigureProperties' -or $Result.Actions -contains 'ConfigureRegistry' -or $Result.Actions -contains 'ConfigureDataSets' -or $Result.Actions -contains 'SetClusterParameter') -and $Online -eq $True) {
        $Result.Actions += @("TakeOffline","BringOnline")
    }
         

    If ($Result.Actions.Count -gt 0) { $Result.DesiredState = $False ; $Result.Actions = $Result.Actions | Get-Unique }

    Return $Result
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

    $State = Get-TargetResource @PSBoundParameters
    $Actions = $State.Actions
    $ClusterDisk = $State.ClusterDisk
    $OraHome = $State.OraHome

    Write-Host "List of actions:"
    $Actions | % { Write-Host $_ }

    If ($Actions -contains "ExpandArchive") {
        Write-Verbose "Expanding archive"
        Expand-Archive -Path "$PSScriptRoot\CrewsAdaptor.zip" -DestinationPath "$ClusterDisk\Crews-Adaptor" 
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log" -ItemType Directory -Force -ErrorAction SilentlyContinue
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log\spring" -ItemType Directory -Force -ErrorAction SilentlyContinue
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log\archive" -ItemType Directory -Force -ErrorAction SilentlyContinue
        New-Item -Path "$ClusterDisk\Crews-Adaptor\log\_scom" -ItemType Directory -Force -ErrorAction SilentlyContinue
    }
    If ($Actions -contains "InstallServiceTemp") {
        Write-Verbose "Expanding archive to temporary dir"
        New-Item -Path "$PSScriptRoot\Temp" -ItemType Directory
        Expand-Archive -Path "$PSScriptRoot\CrewsAdaptor.zip" -DestinationPath "$PSScriptRoot\Temp"
        Start-Process -FilePath "$PSScriptRoot\Temp\install-crews.cmd" -Wait
        Remove-Item -Path "$PSScriptRoot\Temp" -Recurse -Force
    }
    If ($Actions -contains "InstallService") { Start-Process -FilePath "$ClusterDisk\Crews-Adaptor\install-crews.cmd" -Wait }
    If ($Actions -contains "ConfigureRegistry") { Configure-Registry -ClusterDisk $ClusterDisk -JavaPath $JavaPath -OraHome $OraHome }
    If ($Actions -contains "ConfigureProperties") { Configure-PropertiesFile @PSBoundParameters }
    If ($Actions -contains "ConfigureDatasets") { Configure-DataSets -ClusterDisk $ClusterDisk -DataSets $DataSets }
    If ($Actions -contains "ClusterService") { Add-ClusterResource -Name "CrewsAdaptor" -ResourceType "Generic Service" -Group $GroupName }
    If ($Actions -contains "SetClusterParameter") { Get-ClusterResource -Name "CrewsAdaptor" | Set-ClusterParameter -Name ServiceName -Value "CrewsAdaptor" }
    If ($Actions -contains "TakeOffline") { Get-ClusterResource -Name "CrewsAdaptor" | Stop-ClusterResource -ErrorAction SilentlyContinue }
    If ($Actions -contains "BringOnline") { Get-ClusterResource -Name "CrewsAdaptor" | Start-ClusterResource -ErrorAction SilentlyContinue }

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

    Get-TargetResource @PSBoundParameters
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

    $ClusterDisk = "$($ClusterDisk.Replace('\','').Replace(':','').Trim()):"
    $ConfigProperties = Get-Content -Path "${ClusterDisk}\Crews-Adaptor\config\crews-adaptor.properties"
    $JDBC = $ConfigProperties | Select-String "jdbc.url" | ? { $_.Line.StartsWith('#') -eq $False }

    $Checks = @(
        @{
            Type = [string]
            Regex = '(?<=HOST=).+?(?=\))'
            LineNumber = $JDBC.LineNumber
            Value = $DBHost
        },
        @{
            Type = [int]
            Regex = '(?<=PORT=).+?(?=\))'
            LineNumber = $JDBC.LineNumber
            Value = $DBPort
        },
        @{
            Type = [string]
            Regex = '(?<=SERVICE_NAME=).+?(?=\))'
            LineNumber = $JDBC.LineNumber
            Value = $ServiceName
        },
        @{
            Type = [string]
            Regex = '(?<=jms.host=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.host").LineNumber
            Value = $JMSHost
        },
        @{
            Type = [int]
            Regex = '(?<=jms.port=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.port").LineNumber
            Value = $JMSPort
        },
        @{
            Type = [string]
            Regex = '(?<=jms.queueManager=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.queueManager").LineNumber
            Value = $JMSQManager
        },
        @{
            Type = [int]
            Regex = '(?<=jms.transportType=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.transporttype").LineNumber
            Value = $JMSTransportType
        },
        @{
            Type = [string]
            Regex = '(?<=jms.queueName=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.queuename").LineNumber
            Value = $JMSQName
        },
        @{
            Type = [string]
            Regex = '(?<=jms.username=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.username").LineNumber
            Value = $JMSUsername
        },
        @{
            Type = [string]
            Regex = '(?<=jms.password=).+$'
            LineNumber = ($ConfigProperties | Select-String "jms.password").LineNumber
            Value = $JMSPassword
        }
    )

    Foreach ($Check in $Checks) {
        $CurrentValue = ([regex]::match($ConfigProperties[$Check.LineNumber - 1],$Check.Regex)).Value 
        If ([string]::IsNullOrEmpty($CurrentValue)) { $CurrentValue = ([regex]::match($ConfigProperties[$Check.LineNumber - 1],$Check.Regex.ToLower())).Value }
        If ([string]::IsNullOrEmpty($CurrentValue)) { Continue }
        $CurrentValue = $CurrentValue.ToType($Check.Type,$Null)        
        If ($CurrentValue -ne $Check.Value) {
            If ($ReturnBoolean) { Return $False }
            Else { 
                $ConfigProperties[$Check.LineNumber - 1] = $ConfigProperties[$Check.LineNumber - 1] -replace $Check.regex,$Check.Value.ToString()
                $ConfigChanged = $True 
            }
        }
    }
    If ($ReturnBoolean) { Return $True } 
    Elseif ($ConfigChanged) { Set-Content -Path "$ClusterDisk\Crews-Adaptor\config\crews-adaptor.properties" -Value $ConfigProperties }
}

Function Configure-Registry {
    
    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$JavaPath,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$OraHome,

        [Parameter(Mandatory=$False)]
        [switch]$ReturnBoolean = $False
    )
    
    $Registry = @(
        @{
            Key = "HKLM:\SYSTEM\CurrentControlSet\Services\CrewsAdaptor"
            Properties = @(
                @{
                    Name = "Description"
                    Value = "JavaService utility runs Java applications as services. See http://javaservice.objectweb.org"
                    Type = "String"
                },
                @{
                    Name = "DisplayName"
                    Value = "CrewsAdaptor"
                    Type = "String"
                },
                @{
                    Name = "ErrorControl"
                    Value = "1"
                    Type = "DWord"
                },
                @{
                    Name = "ImagePath"
                    Value = "${ClusterDisk}\crews-adaptor\crews-service.exe"
                    Type = "ExpandString"
                },
                @{
                    Name = "ObjectName"
                    Value = "LocalSystem"
                    Type = "String"
                },
                @{
                    Name = "Start"
                    Value = "3"
                    Type = "DWord"
                },
                @{
                    Name = "Type"
                    Value = "16"
                    Type = "DWord"
                }
            )
        },
        @{
            Key = "HKLM:\SYSTEM\CurrentControlSet\Services\CrewsAdaptor\Parameters"
            Properties = @(
                @{
                    Name = "Current Directory"
                    Value = "${ClusterDisk}\crews-adaptor"
                    Type = "String"
                },
                @{
                    Name = "JavaService Version"
                    Value = "2,0,10,1"
                    Type = "String"
                },
                @{
                    Name = "JVM Library"
                    Value = "${JavaPath}\jre\bin\server\jvm.dll" 
                    Type = "String"
                },
                @{
                    Name = "JVM Option Count"
                    Value = "1"
                    Type = "DWord"
                },
                @{
                    Name = "JVM Option Number 0"
                    Value = "-Djava.class.path=${ClusterDisk}\Crews-adaptor\config;${ClusterDisk}\crews-adaptor\com.ibm.mq.runtime_7.0.1.3\lib\com.ibm.mqjms.jar;${OraHome}\jdbc\lib\ojdbc6.jar;${ClusterDisk}\Crews-adaptor\lib\crews-adaptor-main.jar"
                    Type = "String"
                },
                @{
                    Name = "Overwrite Files Flag"
                    Value = "0"
                    Type = "DWord"
                },
                @{
                    Name = "Shutdown Timeout"
                    Value = "30000"
                    Type = "DWord"
                },
                @{
                    Name = "Start Class"
                    Value = "com.hp.emea.ttsol.crews.CrewsAdaptor"
                    Type = "String"
                },
                @{
                    Name = "Start Method"
                    Value = "main"
                    Type = "String"
                },
                @{
                    Name = "Start Param Count"
                    Value = "0"
                    Type = "DWord"
                },
                @{
                    Name = "Startup Sleep"
                    Value = "0"
                    Type = "DWord"
                },
                @{
                    Name = "System.err File"
                    Value = "${ClusterDisk}\Crews-adaptor\log\stderr.log"
                    Type = "String"
                },
                @{
                    Name = "System.out File"
                    Value = "${ClusterDisk}\Crews-adaptor\log\stdout.log"
                    Type = "String"
                }
            )
        }
    )

    Foreach ($Key in $Registry) {
        If (-not (Test-Path $Key.Key)) {
            If ($ReturnBoolean) { Return $False }
            New-Item -Path $Key.Key -Force
        }
        $Properties = (Get-Item $Key.Key).GetValueNames()
        Foreach ($Property in $Key.Properties) {
            If ($Property.Name -notin $Properties) {
                If ($ReturnBoolean) { Return $False }
                New-ItemProperty -Path $Key.Key -Name $Property.Name -Value $Property.Value -PropertyType $Property.Type
            }
            Else {
                $Value = Get-ItemPropertyValue -Path $Key.Key -Name $Property.Name
                If ($Value -cne $Property.Value) {
                    If ($ReturnBoolean) { Return $False }
                    Set-ItemProperty -Path $Key.Key -Name $Property.Name -Value $Property.Value
                }
            }
        }
    }

    If ($ReturnBoolean) { Return $True }

}

Function Configure-DataSets {

    Param(

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$ClusterDisk,

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DataSets,

        [Parameter(Mandatory=$False)]
        [switch]$ReturnBoolean = $False

    )

    $DataSetsXML = [xml](Get-Content -Path "${ClusterDisk}\Crews-Adaptor\config\datasets.xml")
    $RequiredDatasets = $DataSets | % { ((($_ -split ";") | ? { $_ -match "user=" }) -split "=")[1] }
    $CurrentDatasets = $DataSetsXML.datasets.dataset.user
    $ToRemove = (Compare-Object -ReferenceObject $RequiredDatasets -DifferenceObject $CurrentDatasets | Where SideIndicator -eq "=>").InputObject
    If ($ReturnBoolean -and $ToRemove.Count -gt 0) { Return $False }
    
    Foreach ($Dataset in $DataSets){
        $DataSet -split ';' | % -Begin { $Properties = @{} } -Process { $Split = $_ -split "=" ; $Properties.Add($Split[0],$Split[1]) }
        $CurrDataSet = $DataSetsXML.datasets.dataset | Where user -eq $Properties.user
        If ($CurrDataSet -eq $Null) {
            If ($ReturnBoolean) { Return $False } 
            [xml]$Child = "<dataset $(($Properties.GetEnumerator() | % { ("$($_.Key)=" + '"' + "$($_.Value)" + '"') }) -join " ") $('vertraging="true" dienstregeling="true" materieelplan="false"/>')"
            $DataSetsXML.datasets.AppendChild($DataSetsXML.ImportNode($Child.dataset,$True))
        }
        Else {
            Foreach ($Property in $Properties.GetEnumerator()) {
                $CurrentValue = $CurrDataSet.($Property.Key)
                If ([string]::IsNullOrEmpty($CurrentValue)) {
                    If ($ReturnBoolean) { Return $False }
                    $Attribute = $CurrDataSet.OwnerDocument.CreateAttribute($Property.Key)
                    $CurrDataSet.Attributes.Append($Attribute)
                    $CurrDataSet.SetAttribute($Property.Key, $Property.Value)
                }
                Elseif ($CurrentValue -ne $Property.Value) { 
                    If ($ReturnBoolean) { Return $False }
                    $CurrDataSet.SetAttribute($Property.Key, $Property.Value) 
                }            
            }
        }
    }

    If ($ToRemove.Count -gt 0) {
        Foreach ($DataSet in $ToRemove) {
            $Remove = @($DataSetsXML.datasets.dataset | Where user -eq $DataSet)[0]
            $DataSetsXml.datasets.RemoveChild($Remove)
        }
    }

    If ($ReturnBoolean) { Return $True }
    $DataSetsXML.Save("$ClusterDisk\Crews-Adaptor\config\datasets.xml")
}
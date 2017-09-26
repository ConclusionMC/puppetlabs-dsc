Function Get-TargetResource {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IsSingleInstance = 'Yes',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AcceptTrustedPublisherCerts,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$DisableWindowsUpdateAccess,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$ElevateNonAdmins,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$TargetGroup,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$TargetGroupEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$WUServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$WUStatusServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$AUOptions,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AutoInstallMinorUpdates,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DetectionFrequency,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$DetectionFrequencyEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAutoRebootWithLoggedOnUsers,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAutoUpdate,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RebootRelaunchTimeout,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RebootRelaunchTimeoutEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RebootWarningTimeout,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RebootWarningTimeoutEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RescheduleWaitTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RescheduleWaitTimeEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ScheduledInstallDay,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ScheduledInstallTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$UseWUServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$EnableFeaturedSoftware,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$IncludeRecommendedUpdates,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AUPowerManagement,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAUAsDefaultShutdownOption,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAUShutdownOption
    )

    $RegistryItems = @(
        @{
            Path = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate'
            Items = @(
                @{
                    Name = 'AcceptTrustedPublisherCerts'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'DisableWindowsUpdateAccess'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'ElevateNonAdmins'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'TargetGroup'
                    Type = 'STRING'
                    Range = $Null
                    Requires = @('TargetGroupEnabled(1)')
                },
                @{
                    Name = 'TargetGroupEnabled'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @('TargetGroup')
                },
                @{
                    Name = 'WUServer'
                    Type = 'STRING'
                    Range = $Null
                    Requires = @('WUStatusServer', 'UseWUServer(1)')
                },
                @{
                    Name = 'WUStatusServer'
                    Type = 'STRING'
                    Range = $Null
                    Requires = @('WUServer','UseWUServer(1)')
                }
            )
        },
        @{
            Path = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU'
            Items = @(
                @{
                    Name = 'AUOptions'
                    Type = 'DWORD'
                    Range = 2..5
                    Requires = @()
                },
                @{
                    Name = 'AutoInstallMinorUpdates'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'DetectionFrequency'
                    Type = 'DWORD'
                    Range = 1..22
                    Requires = @('DetectionFrequencyEnabled(1)')
                },
                @{
                    Name = 'DetectionFrequencyEnabled'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'NoAutoRebootWithLoggedOnUsers'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'NoAutoUpdate'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'RebootRelaunchTimeout'
                    Type = 'DWORD'
                    Range = 1..1440
                    Requires = @('RebootRelaunchTimeoutEnabled(1)')
                },
                @{
                    Name = 'RebootRelaunchTimeoutEnabled'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'RebootWarningTimeout'
                    Type = 'DWORD'
                    Range = 1..30
                    Requires = @('RebootWarningTimeoutEnabled(1)')
                },
                @{
                    Name = 'RebootWarningTimeoutEnabled'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'RescheduleWaitTime'
                    Type = 'DWORD'
                    Range = 1..60
                    Requires = @('RescheduleWaitTimeEnabled(1)')
                },
                @{
                    Name = 'RescheduleWaitTimeEnabled'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'ScheduledInstallDay'
                    Type = 'DWORD'
                    Range = 0..7
                    Requires = @('AUOptions(4)','ScheduledInstallTime')
                },
                @{
                    Name = 'ScheduledInstallTime'
                    Type = 'DWORD'
                    Range = 0..23
                    Requires = @('AUOptions(4)','ScheduledInstallDay')
                },
                @{
                    Name = 'UseWUServer'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @('WUServer','WUStatusServer')
                },
                @{
                    Name = 'EnableFeaturedSoftware'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'AUPowerManagement'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'IncludeRecommendedUpdates'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'NoAUAsDefaultShutdownOption'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                },
                @{
                    Name = 'NoAUShutdownOption'
                    Type = 'DWORD'
                    Range = 0..1
                    Requires = @()
                }
            )
        }
    )

    $Errors = @()
    Foreach ($Parameter in ($PSBoundParameters.GetEnumerator() | Where Key -ne 'Verbose')) {
        $Registry = $RegistryItems | ? { $_.Items.Name -contains $Parameter.Key }
        $Item = $Registry.Items | Where Name -eq $Parameter.Key

        Foreach ($Requirement in $Item.Requires) {
        
            If ($Requirement -match "\(.\)") {
                $Value = ($Requirement -split '\(')[1].Replace(')','')
                $Required = ($Requirement -split '\(')[0]
            } Else { $Required = $Requirement ; $Value = $Null }
            If (-not $PSBoundParameters.ContainsKey($Required)) { $Errors += "The $($Parameter.Key) parameter requires $Required to be set." }
            Elseif (($Value -ne $Null) -and ($Value -ne [int]($PSBoundParameters[$Required]))) {
                    $Errors += "The $($Parameter.Key) parameter requires $Required to be set to $Value."
            }
        }
        If (($Item.Type -match 'dword') -and ([int]$PSBoundParameters[$Parameter.Key] -notin $Item.Range)) { $Errors += "The value for $($Parameter.Key) is outside its range." }
    }
    If ($Errors.Count -gt 0) { Throw "One or more errors encountered: $Errors" }

    $ToAdd = @() ; $ToSet = @() ; $ToRemove = @() ; $ToCreate = @()
    Foreach ($RegistryKey in $RegistryItems) {
        Try { $Key = Get-Item $($RegistryKey.Path) -ErrorAction Stop ; $ValueNames = $Key.GetValueNames() }
        Catch {
            $ToCreate += $RegistryKey.Path
            Foreach ($Item in $RegistryKey.Items) { If ($PSBoundParameters.ContainsKey($Item.Name)) { $Item.Add('Key',$RegistryKey.Path) ; $ToAdd += $Item } }
            Continue
        }

        Foreach ($Item in $RegistryKey.Items) {
            If ($PSBoundParameters.ContainsKey($Item.Name)) {
                If (-not $ValueNames.Contains($Item.Name)) { $Item.Add('Key',$RegistryKey.Path) ; $ToAdd += $Item }
                Elseif (($Item.Type -match 'dword') -and ($Key.GetValue($Item.Name) -ne [int]$PSBoundParameters[$Item.Name])) { $Item.Add('Key',$RegistryKey.Path) ; $ToSet += $Item }
                Elseif (($Item.Type -match 'string') -and ($Key.GetValue($Item.Name) -ne $PSBoundParameters[$Item.Name])) { $Item.Add('Key',$RegistryKey.Path) ; $ToSet += $Item }
            }
            Elseif ($ValueNames.Contains($Item.Name)) { $Item.Add('Key',$RegistryKey.Path) ; $ToRemove += $Item }
        }
    }

    If (($ToAdd.Count -gt 0) -or ($ToCreate.Count -gt 0) -or ($ToSet.Count -gt 0) -or ($ToRemove.Count -gt 0)) { $DesiredState = $False }
    Else { $DesiredState = $True }
    
    Return @{
        DesiredState = $DesiredState
        ToAdd = $ToAdd
        ToCreate = $ToCreate
        ToSet = $ToSet
        ToRemove = $ToRemove
    }
}

Function Set-TargetResource {
    
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IsSingleInstance = 'Yes',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AcceptTrustedPublisherCerts,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$DisableWindowsUpdateAccess,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$ElevateNonAdmins,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$TargetGroup,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$TargetGroupEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$WUServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$WUStatusServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$AUOptions,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AutoInstallMinorUpdates,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DetectionFrequency,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$DetectionFrequencyEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAutoRebootWithLoggedOnUsers,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAutoUpdate,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RebootRelaunchTimeout,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RebootRelaunchTimeoutEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RebootWarningTimeout,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RebootWarningTimeoutEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RescheduleWaitTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RescheduleWaitTimeEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ScheduledInstallDay,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ScheduledInstallTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$UseWUServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$EnableFeaturedSoftware,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$IncludeRecommendedUpdates,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AUPowerManagement,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAUAsDefaultShutdownOption,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAUShutdownOption
    )

    $CurrentState = Get-TargetResource @PSBoundParameters
    Foreach ($Path in $Currentstate.ToCreate) {  
        
        $Split = $Path -split '\\'
        Foreach ($SubPath in $Split) {
            $Index = $Split.IndexOf($SubPath)
            $Path = $Split[0..$Index] -join '\'
            If (-not (Test-Path $Path)) { New-Item $Path }
        }
    }
    Foreach ($Item in $CurrentState.ToAdd) { New-ItemProperty -Path $Item.Key -PropertyType $Item.Type -Name $Item.Name -Value $PSBoundParameters[$Item.Name] }
    Foreach ($Item in $CurrentState.ToSet) { Set-ItemProperty -Path $Item.Key -Name $Item.Name -Value $PSBoundParameters[$Item.Name] }
    Foreach ($Item in $CurrentState.ToRemove) { Remove-ItemProperty -Path $Item.Key -Name $Item.Name -Force }
}

Function Test-TargetResource {
    
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [String]$IsSingleInstance = 'Yes',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AcceptTrustedPublisherCerts,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$DisableWindowsUpdateAccess,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$ElevateNonAdmins,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$TargetGroup,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$TargetGroupEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$WUServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [String]$WUStatusServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$AUOptions,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AutoInstallMinorUpdates,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$DetectionFrequency,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$DetectionFrequencyEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAutoRebootWithLoggedOnUsers,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAutoUpdate,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RebootRelaunchTimeout,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RebootRelaunchTimeoutEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RebootWarningTimeout,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RebootWarningTimeoutEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$RescheduleWaitTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$RescheduleWaitTimeEnabled,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ScheduledInstallDay,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [uint32]$ScheduledInstallTime,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$UseWUServer,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$EnableFeaturedSoftware,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$IncludeRecommendedUpdates,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$AUPowerManagement,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAUAsDefaultShutdownOption,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [Boolean]$NoAUShutdownOption
    )

    Return (Get-TargetResource @PSBoundParameters).DesiredState
}

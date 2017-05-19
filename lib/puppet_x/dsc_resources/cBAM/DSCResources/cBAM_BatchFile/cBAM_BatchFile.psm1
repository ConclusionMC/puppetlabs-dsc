Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [string]$Auth_Server,

        [Parameter(Mandatory=$False)]
        [string]$Defect_Server,

        [Parameter(Mandatory=$False)]
        [string]$Conflict_Server,

        [Parameter(Mandatory=$False)]
        [string]$Plan_Server,

        [Parameter(Mandatory=$False)]
        [string]$Main_Server,

        [Parameter(Mandatory=$False)]
        [string]$JMS_Address,

        [Parameter(Mandatory=$False)]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $DesiredState = $True

    $BamDir = "$env:ProgramFiles\BAMClient"

    If (-not (Test-Path "$BamDir\$BatchFile")){ $DesiredState = $False }
    Else { $Content = Get-Content -Path "$BamDir\$BatchFile" }

    $Configuration = $PSBoundParameters.GetEnumerator() | ? { $_.Key -notmatch 'BatchFile' -and $_.Key -notmatch 'Template' }

    $Commands = @{
        Auth_Server = 'SET NS_AUTHENTICATION_PROVIDER_ADRES='
        Defect_Server = 'SET NS_DEFECTENOVERZICHT_ADRES='
        Conflict_Server = 'SET NS_CONFLICTSIGNALERING_ADRES='
        Plan_Server = 'SET NS_PLANSERVER_ADRES='
        Main_Server = 'SET NS_MAINSERVER_ADRES='
        JMS_Address = 'SET NS_JMS_ADRES='
        JRE_Home = 'SET JRE_HOME='
    }

    Foreach ($Config in $Configuration) {

        $Command = $Commands[$Config.Key]
        $Matches = $Content | Select-String -Pattern $Command

        Foreach ($Match in $Matches) {
            $CurrentConfig = ($Match.Line -Split '=')[1]
            If ($CurrentConfig -ne $Config.Value) { $DesiredState = $False }
        }        
    }

    Return @{  
        BatchFile = $BatchFile
        Template = $Template
        Auth_Server = $Auth_Server
        Defect_Server = $Defect_Server
        Conflict_Server = $Conflict_Server
        Plan_Server = $Plan_Server
        Main_Server = $Main_Server
        JMS_Address = $JMS_Address
        JRE_Home = $JRE_Home
        DesiredState    = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [string]$Auth_Server,

        [Parameter(Mandatory=$False)]
        [string]$Defect_Server,

        [Parameter(Mandatory=$False)]
        [string]$Conflict_Server,

        [Parameter(Mandatory=$False)]
        [string]$Plan_Server,

        [Parameter(Mandatory=$False)]
        [string]$Main_Server,

        [Parameter(Mandatory=$False)]
        [string]$JMS_Address,

        [Parameter(Mandatory=$False)]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $BamDir = "$env:ProgramFiles\BAMClient"

    If (-not (Test-Path "$BamDir\$BatchFile")){ New-Item -Path "$BamDir\$BatchFile" -ItemType File ; $Content = $Template }
    Else { $Content = Get-Content -Path "$BamDir\$BatchFile" }

    $Update = $False
    $Configuration = $PSBoundParameters.GetEnumerator() | ? { $_.Key -notmatch 'BatchFile' -and $_.Key -notmatch 'Template' }

    $Commands = @{
        Auth_Server = 'SET NS_AUTHENTICATION_PROVIDER_ADRES='
        Defect_Server = 'SET NS_DEFECTENOVERZICHT_ADRES='
        Conflict_Server = 'SET NS_CONFLICTSIGNALERING_ADRES='
        Plan_Server = 'SET NS_PLANSERVER_ADRES='
        Main_Server = 'SET NS_MAINSERVER_ADRES='
        JMS_Address = 'SET NS_JMS_ADRES='
        JRE_Home = 'SET JRE_HOME='
    }

    Foreach ($Config in $Configuration) {

        $Command = $Commands[$Config.Key]
        $Matches = $Content | Select-String -Pattern $Command
        If ($Matches -eq $Null) { Write-Error "No entry for '$($Config.Key)' could be found." ; Continue }
        Else {

            Foreach ($Match in $Matches) {
                $CurrentConfig = ($Match.Line -Split '=')[1]
                If ($CurrentConfig -ne $Config.Value) {
                    $Content[($Match.LineNumber - 1)] = "$Command$($Config.Value)"
                    $Update = $True
                }
            }
        }
    }
    If ($Update) { Set-Content -Path "$BamDir\$BatchFile" -Value $Content }
}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [string]$Auth_Server,

        [Parameter(Mandatory=$False)]
        [string]$Defect_Server,

        [Parameter(Mandatory=$False)]
        [string]$Conflict_Server,

        [Parameter(Mandatory=$False)]
        [string]$Plan_Server,

        [Parameter(Mandatory=$False)]
        [string]$Main_Server,

        [Parameter(Mandatory=$False)]
        [string]$JMS_Address,

        [Parameter(Mandatory=$False)]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $BamDir = "$env:ProgramFiles\BAMClient"

    If (-not (Test-Path "$BamDir\$BatchFile")){ Return $False }
    Else { $Content = Get-Content -Path "$BamDir\$BatchFile" }

    $Configuration = $PSBoundParameters.GetEnumerator() | ? { $_.Key -notmatch 'BatchFile' -and $_.Key -notmatch 'Template' }

    $Commands = @{
        Auth_Server = 'SET NS_AUTHENTICATION_PROVIDER_ADRES='
        Defect_Server = 'SET NS_DEFECTENOVERZICHT_ADRES='
        Conflict_Server = 'SET NS_CONFLICTSIGNALERING_ADRES='
        Plan_Server = 'SET NS_PLANSERVER_ADRES='
        Main_Server = 'SET NS_MAINSERVER_ADRES='
        JMS_Address = 'SET NS_JMS_ADRES='
        JRE_Home = 'SET JRE_HOME='
    }

    Foreach ($Config in $Configuration) {

        $Command = $Commands[$Config.Key]
        $Matches = $Content | Select-String -Pattern $Command

        Foreach ($Match in $Matches) {
            $CurrentConfig = ($Match.Line -Split '=')[1]
            If ($CurrentConfig -ne $Config.Value) { Return $False }
        }        
    }

    Return $True
}
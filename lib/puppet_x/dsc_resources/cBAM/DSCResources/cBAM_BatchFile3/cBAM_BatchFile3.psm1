Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir = 'D:\Apps\BAMClient',

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartCommand,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Auth_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Defect_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Conflict_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Plan_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Main_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JMS_Address,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )    

    $DesiredState = $True

    $Template = $Template -replace '<Blank>',''

    $StartSettings = $Template | Select-String '<Settings>'
    If ($StartSettings -eq $Null) { Throw "No settings segment could be found in the template. Pleas include the '<Settings>' and '</Settings>' keywords in your template." }
    Elseif ($StartSettings.Count -gt 1) { Throw "More than one '<Settings>' keyword was found." }
    $EndSettings = $Template | Select-String '</Settings>'
    If ($EndSettings -eq $Null) { Throw "No settings segment could be found in the template. Pleas include the '<Settings>' and '</Settings>' keywords in your template." }
    Elseif ($EndSettings.Count -gt 1) { Throw "More than one '</Settings>' keyword was found." }
    If ($StartSettings.LineNumber -ge $EndSettings.LineNumber) { Throw "The '</Settings>' keyword can not be on the same line or before the '<Settings>' keyword." }

    If (Test-Path $InstallDir) { $BamDir = $InstallDir }
    Elseif (Test-Path "$env:ProgramFiles\BAMclient") { $BamDir = "$env:ProgramFiles\BAMclient" }
    Elseif (Test-Path "${env:ProgramFiles(x86)}\BAMClient") { $BamDir = "${env:ProgramFiles(x86)}\BAMClient" }
    Else { Throw "BAM Client could not be found on this machine." }
     
    If (-not (Test-Path -Path "$BamDir\$BatchFile")) { $FileExists = $False ; $DesiredState = $False ; $CurrentContent = @() }
    Else { $FileExists = $True ; $CurrentContent = Get-Content "$BamDir\$BatchFile" }
    
    $BeforeSettings = $Template[0..($StartSettings.LineNumber - 1)]
    $AfterSettings = $Template[($EndSettings.LineNumber - 1)..($Template.Count - 1)]
    If ($AfterSettings[-1] -eq '<StartCommand>') { $AfterSettings[-1] = $StartCommand }
    Elseif ($AfterSettings[-1].Contains('start "" eclipse.exe') -and ($AfterSettings[-1] -ne $StartCommand)) { $AfterSettings[-1] = $StartCommand }
    Elseif ($AfterSettings[-1] -ne $StartCommand) { $AfterSettings += $StartCommand }
    
    $Commands = @{
        Auth_Server = 'SET NS_AUTHENTICATION_PROVIDER_ADRES='
        Defect_Server = 'SET NS_DEFECTENOVERZICHT_ADRES='
        Conflict_Server = 'SET NS_CONFLICTSIGNALERING_ADRES='
        Plan_Server = 'SET NS_PLANSERVER_ADRES='
        Main_Server = 'SET NS_MAINSERVER_ADRES='
        JMS_Address = 'SET NS_JMS_ADRES='
        JRE_Home = 'SET JRE_HOME='
    }

    $RequiredSettings = @()
    Foreach ($Command in ($Commands.GetEnumerator() | Sort Key)) { If ($PSBoundParameters.ContainsKey($Command.Key)) { $RequiredSettings += "$($Command.Value)$($PSBoundParameters[$Command.Key])" } }

    $RequiredContent = $BeforeSettings + $RequiredSettings + $AfterSettings

    If (($CurrentContent -ne $Null) -and ($CurrentContent.Count -ne 0)) {
        $Compare = Compare-Object -ReferenceObject $CurrentContent -DifferenceObject $RequiredContent
        If ($Compare -ne $Null) { $DesiredState = $False }
    }
    Else { $DesiredState = $False }

    Return @{  
        BamDir = $BamDir
        FileExists = $FileExists
        CurrentContent = $CurrentContent
        RequiredContent = $RequiredContent
        DesiredState    = $DesiredState
    }
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir = 'D:\Apps\BAMClient',

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartCommand,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Auth_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Defect_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Conflict_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Plan_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Main_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JMS_Address,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )    

    $CurrentState = Get-TargetResource @PSBoundParameters
    If ($CurrentState.FileExists -eq $False) { $File = New-Item -Path "$($CurrentState.BamDir)\$BatchFile" -Value ($CurrentState.RequiredContent | Out-String) }
    Else { Set-Content -Path "$($CurrentState.BamDir)\$BatchFile" -Value $CurrentState.RequiredContent }

}

Function Test-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir = 'D:\Apps\BAMClient',

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartCommand,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Auth_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Defect_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Conflict_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Plan_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Main_Server,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JMS_Address,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )    

    $CurrentState = Get-TargetResource @PSBoundParameters
    Return $CurrentState.DesiredState

}
Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$BatchFile,

        [Parameter(Mandatory=$True)]
        [string[]]$Template,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$InstallDir = 'D:\Apps\DonnaBeheerTool',

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartCommand,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Memory,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Locale,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Bundles,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Config,

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

    If (Test-Path $InstallDir) { $DonnaDir = $InstallDir }
    Elseif (Test-Path "$env:ProgramFiles\DonnaBeheerTool") { $DonnaDir = "$env:ProgramFiles\DonnaBeheerTool" }
    Elseif (Test-Path "${env:ProgramFiles(x86)}\DonnaBeheerTool") { $DonnaDir = "${env:ProgramFiles(x86)}\DonnaBeheerTool" }
    Else { Throw "DonnaBeheerTool could not be found on this machine." }
     
    If (-not (Test-Path -Path "$DonnaDir\$BatchFile")) { $FileExists = $False ; $DesiredState = $False ; $CurrentContent = @() }
    Else { $FileExists = $True ; $CurrentContent = Get-Content "$DonnaDir\$BatchFile" }
    
    $BeforeSettings = $Template[0..($StartSettings.LineNumber - 1)]
    $AfterSettings = $Template[($EndSettings.LineNumber - 1)..($Template.Count - 1)]
    If ($AfterSettings[-1] -eq '<StartCommand>') { $AfterSettings[-1] = $StartCommand }
    Elseif ($AfterSettings[-1].Contains('start "" eclipse.exe') -and ($AfterSettings[-1] -ne $StartCommand)) { $AfterSettings[-1] = $StartCommand }
    Elseif ($AfterSettings[-1] -ne $StartCommand) { $AfterSettings += $StartCommand }
    
    $Commands = @{
        Locale = 'SET LOCALE='
        Memory = 'SET MEMORY='
        Bundles = 'SET BUNDLES='
        Config = 'SET CONFIG='
        JRE_Home = 'SET JRE_HOME='
    }

    $RequiredSettings = @()
    Foreach ($Command in ($Commands.GetEnumerator() | Sort Key)) { 
        If ($PSBoundParameters.ContainsKey($Command.Key)) {
            If ($PSBoundParameters[$Command.Key].Count -gt 1) {
                $VarName = ($Command.Value -split ' ')[1].Replace('=','').Trim()
                Foreach ($Setting in $PSBoundParameters[$Command.Key]){
                    If ($PSBoundParameters[$Command.Key].IndexOf($Setting) -eq 0) { $RequiredSettings += "$($Command.Value)$Setting" }
                    Else { $RequiredSettings += "$($Command.Value)%$VarName% $Setting" }
                }            
            }
            Else { $RequiredSettings += "$($Command.Value)$($PSBoundParameters[$Command.Key])" }
        } 
    }

    $RequiredContent = $BeforeSettings + $RequiredSettings + $AfterSettings

    If (($CurrentContent -ne $Null) -and ($CurrentContent.Count -ne 0)) {
        $Compare = Compare-Object -ReferenceObject $CurrentContent -DifferenceObject $RequiredContent
        If ($Compare -ne $Null) { $DesiredState = $False }
    }
    Else { $DesiredState = $False }

    Return @{  
        DonnaDir = $DonnaDir
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
        [string]$InstallDir = 'D:\Apps\DonnaBeheerTool',

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartCommand,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Memory,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Locale,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Bundles,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Config,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    ) 
    $CurrentState = Get-TargetResource @PSBoundParameters
    If ($CurrentState.FileExists -eq $False) { $File = New-Item -Path "$($CurrentState.DonnaDir)\$BatchFile" -Value ($CurrentState.RequiredContent | Out-String) }
    Else { Set-Content -Path "$($CurrentState.DonnaDir)\$BatchFile" -Value $CurrentState.RequiredContent }

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
        [string]$InstallDir = 'D:\Apps\DonnaBeheerTool',

        [Parameter(Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$StartCommand,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Memory,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Locale,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Bundles,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Config,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$JRE_Home,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    ) 
    $CurrentState = Get-TargetResource @PSBoundParameters
    Return $CurrentState.DesiredState

}
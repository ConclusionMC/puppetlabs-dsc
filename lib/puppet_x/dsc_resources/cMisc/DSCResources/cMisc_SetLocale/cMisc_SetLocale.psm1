Function Get-TargetResource {
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes")]
        [string]$IsSingleInstance,
        
        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Locale = '00000413',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$LocaleName = 'nl-NL',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$s1159 = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$s2359 = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sCountry = 'Netherlands',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sCurrency = '€',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sDate = '-',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sDecimal = ',',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sGrouping = '3;0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sLanguage = 'NLD',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sList = ';',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sLongDate = 'dddd d MMMM yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonDecimalSep = ',',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonGrouping = '3;0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonThousandSep = '.',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sNativeDigits = '0123456789',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sNegativeSign = '-',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sPositiveSign = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sShortDate = 'd-M-yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sThousand = '.',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sTime = ':',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sTimeFormat = 'HH:mm:ss',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sShortTime = 'HH:mm',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sYearMonth = 'MMMM yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCalendarType = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCountry = '31',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCurrDigits = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCurrency = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iDate = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iDigits = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NumShape = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iFirstDayOfWeek = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iFirstWeekOfYear = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iLZero = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iMeasure = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iNegCurr = '12',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iNegNumber = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iPaperSize = '9',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTime = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTimePrefix = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTLZero = '1'
    )
}

Function Set-TargetResource {

    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes")]
        [string]$IsSingleInstance,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Locale = '00000413',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$LocaleName = 'nl-NL',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$s1159 = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$s2359 = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sCountry = 'Netherlands',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sCurrency = '€',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sDate = '-',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sDecimal = ',',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sGrouping = '3;0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sLanguage = 'NLD',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sList = ';',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sLongDate = 'dddd d MMMM yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonDecimalSep = ',',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonGrouping = '3;0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonThousandSep = '.',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sNativeDigits = '0123456789',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sNegativeSign = '-',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sPositiveSign = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sShortDate = 'd-M-yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sThousand = '.',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sTime = ':',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sTimeFormat = 'HH:mm:ss',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sShortTime = 'HH:mm',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sYearMonth = 'MMMM yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCalendarType = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCountry = '31',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCurrDigits = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCurrency = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iDate = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iDigits = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NumShape = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iFirstDayOfWeek = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iFirstWeekOfYear = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iLZero = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iMeasure = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iNegCurr = '12',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iNegNumber = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iPaperSize = '9',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTime = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTimePrefix = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTLZero = '1'
    )

    $Regs = @()
    $Regs += Get-Item -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\.DEFAULT\Control Panel\International"
    $LoggedOnSids = (Get-ChildItem "Microsoft.PowerShell.Core\Registry::HKEY_USERS" | ? { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName | % { 
        $Regs += Get-Item -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$_\Control Panel\International"
    }
    $Keys = $MyInvocation.MyCommand.Parameters.Keys | ?  { $_ -notmatch "(variable)|(outbuffer)|(action)|(verbose)|(debug)|(singleinstance)" }
    Foreach ($Key in $Keys) {
        $RequiredValue = Get-Variable $Key -ValueOnly
        Foreach ($Reg in $Regs) {
            $CurrentValue = $Reg.GetValue($Key)
            If ($RequiredValue -cne $CurrentValue) { Set-ItemProperty -Path $Reg.PSPath -Name $Key -Value $RequiredValue }
        }
    } 
}

Function Test-TargetResource {
    
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateSet("Yes")]
        [string]$IsSingleInstance,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Locale = '00000413',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$LocaleName = 'nl-NL',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$s1159 = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$s2359 = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sCountry = 'Netherlands',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sCurrency = '€',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sDate = '-',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sDecimal = ',',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sGrouping = '3;0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sLanguage = 'NLD',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sList = ';',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sLongDate = 'dddd d MMMM yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonDecimalSep = ',',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonGrouping = '3;0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sMonThousandSep = '.',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sNativeDigits = '0123456789',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sNegativeSign = '-',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sPositiveSign = '',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sShortDate = 'd-M-yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sThousand = '.',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sTime = ':',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sTimeFormat = 'HH:mm:ss',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sShortTime = 'HH:mm',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$sYearMonth = 'MMMM yyyy',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCalendarType = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCountry = '31',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCurrDigits = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iCurrency = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iDate = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iDigits = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$NumShape = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iFirstDayOfWeek = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iFirstWeekOfYear = '2',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iLZero = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iMeasure = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iNegCurr = '12',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iNegNumber = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iPaperSize = '9',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTime = '1',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTimePrefix = '0',

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$iTLZero = '1'
    )

    $Regs = @()
    $Regs += Get-Item -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\.DEFAULT\Control Panel\International"
    $LoggedOnSids = (Get-ChildItem "Microsoft.PowerShell.Core\Registry::HKEY_USERS" | ? { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName | % { 
        $Regs += Get-Item -Path "Microsoft.PowerShell.Core\Registry::HKEY_USERS\$_\Control Panel\International"
    }
    $Keys = $MyInvocation.MyCommand.Parameters.Keys | ?  { $_ -notmatch "(variable)|(outbuffer)|(action)|(verbose)|(debug)|(singleinstance)" }
    Foreach ($Key in $Keys) {
        $RequiredValue = Get-Variable $Key -ValueOnly
        Foreach ($Reg in $Regs) {
            $CurrentValue = $Reg.GetValue($Key)
            If ($RequiredValue -cne $CurrentValue) { Return $False }
        }
    }   
    Return $True
}
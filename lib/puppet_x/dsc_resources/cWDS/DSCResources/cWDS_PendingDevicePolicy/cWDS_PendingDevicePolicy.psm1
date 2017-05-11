Function Get-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("AdminApproval", "Disabled")]
        [string]$Policy,

        [Parameter(Mandatory=$False)]
        [uint32]$PollInterval,

        [Parameter(Mandatory=$False)]
        [uint32]$MaxRetry,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$False)]
        [uint32]$ApprovedDeviceRetention,

        [Parameter(Mandatory=$False)]
        [uint32]$OtherDeviceRetention,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $DesiredState = $True

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $PendingDevicePolicy = $WdsConfig | Select-String -Pattern 'Pending Device Policy' -Context 0,7

    $CurrentPolicy = (($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Policy') -split ': ')[1].Trim()
    If (($CurrentPolicy.Replace(' ','')) -ne $Policy) { $DesiredState = $False }

    If ($PSBoundParameters.ContainsKey('PollInterval')) {
        $CurrentPollInterval = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'interval') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentPollInterval -ne $PollInterval) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('MaxRetry')) {
        $CurrentMaxRetry = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'retry count') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentMaxRetry -ne $MaxRetry) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('Message')) {
        $CurrentMessage = (($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Message to pending clients') -split ': ')[1].Trim()
        If ($CurrentMessage -ne $Message) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('ApprovedDeviceRetention')) {
        $CurrentRetention = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Approved devices') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentRetention -ne $ApprovedDeviceRetention) { $DesiredState = $False }
    }

    If ($PSBoundParameters.ContainsKey('OtherDeviceRetention')) {
        $CurrentRetention = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Other devices') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentRetention -ne $OtherDeviceRetention) { $DesiredState = $False }
    }    
    
    Return @{
        Policy                  = $Policy
        PollInterval            = $PollInterval
        MaxRetry                = $MaxRetry
        Message                 = $Message
        ApprovedDeviceRetention = $ApprovedDeviceRetention
        OtherDeviceRetention    = $OtherDeviceRetention
        DesiredState            = $DesiredState
    } 
}

Function Set-TargetResource {
    
    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("AdminApproval", "Disabled")]
        [string]$Policy,

        [Parameter(Mandatory=$False)]
        [uint32]$PollInterval,

        [Parameter(Mandatory=$False)]
        [uint32]$MaxRetry,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$False)]
        [uint32]$ApprovedDeviceRetention,

        [Parameter(Mandatory=$False)]
        [uint32]$OtherDeviceRetention,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )

    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $PendingDevicePolicy = $WdsConfig | Select-String -Pattern 'Pending Device Policy' -Context 0,7

    $CurrentPolicy = (($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Policy') -split ': ')[1].Trim()
    If (($CurrentPolicy.Replace(' ','')) -ne $Policy) { WdsUtil /Set-Server /Server:Localhost /AutoAddPolicy /Policy:$Policy }

    If ($PSBoundParameters.ContainsKey('PollInterval')) {
        $CurrentPollInterval = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'interval') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentPollInterval -ne $PollInterval) { WdsUtil /Set-Server /Server:Localhost /AutoAddPolicy /PollInterval:$PollInterval }
    }

    If ($PSBoundParameters.ContainsKey('MaxRetry')) {
        $CurrentMaxRetry = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'retry count') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentMaxRetry -ne $MaxRetry) { WdsUtil /Set-Server /Server:Localhost /AutoAddPolicy /MaxRetry:$MaxRetry }
    }

    If ($PSBoundParameters.ContainsKey('Message')) {
        $CurrentMessage = (($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Message to pending clients') -split ': ')[1].Trim()
        If ($CurrentMessage -ne $Message) { WdsUtil /Set-Server /Server:Localhost /AutoAddPolicy /Message:"$Message" }
    }

    If ($PSBoundParameters.ContainsKey('ApprovedDeviceRetention')) {
        $CurrentRetention = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Approved devices') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentRetention -ne $ApprovedDeviceRetention) { WdsUtil /Set-Server /Server:Localhost /AutoAddPolicy /RetentionPeriod /Approved:$ApprovedDeviceRetention }
    }

    If ($PSBoundParameters.ContainsKey('OtherDeviceRetention')) {
        $CurrentRetention = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Other devices') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentRetention -ne $OtherDeviceRetention) { WdsUtil /Set-Server /Server:Localhost /AutoAddPolicy /RetentionPeriod /Others:$OtherDeviceRetention }
    }
  
}

Function Test-TargetResource {

    Param(
        
        [Parameter(Mandatory=$True)]
        [ValidateSet("AdminApproval", "Disabled")]
        [string]$Policy,

        [Parameter(Mandatory=$False)]
        [uint32]$PollInterval,

        [Parameter(Mandatory=$False)]
        [uint32]$MaxRetry,

        [Parameter(Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$False)]
        [uint32]$ApprovedDeviceRetention,

        [Parameter(Mandatory=$False)]
        [uint32]$OtherDeviceRetention,

        [Parameter(Mandatory=$False)]
        [bool]$DesiredState

    )
    
    $WdsConfig = WdsUtil /Get-Server /Show:Config
    $PendingDevicePolicy = $WdsConfig | Select-String -Pattern 'Pending Device Policy' -Context 0,7

    $CurrentPolicy = (($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Policy') -split ': ')[1].Trim()
    If (($CurrentPolicy.Replace(' ','')) -ne $Policy) { Return $False }

    If ($PSBoundParameters.ContainsKey('PollInterval')) {
        $CurrentPollInterval = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'interval') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentPollInterval -ne $PollInterval) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('MaxRetry')) {
        $CurrentMaxRetry = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'retry count') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentMaxRetry -ne $MaxRetry) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('Message')) {
        $CurrentMessage = (($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Message to pending clients') -split ': ')[1].Trim()
        If ($CurrentMessage -ne $Message) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('ApprovedDeviceRetention')) {
        $CurrentRetention = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Approved devices') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentRetention -ne $ApprovedDeviceRetention) { Return $False }
    }

    If ($PSBoundParameters.ContainsKey('OtherDeviceRetention')) {
        $CurrentRetention = [int]((($PendingDevicePolicy.Context.PostContext | Select-String -Pattern 'Other devices') -split ': ')[1].Trim() -split ' ')[0]
        If ($CurrentRetention -ne $OtherDeviceRetention) { Return $False }
    }

    Return $True 

}
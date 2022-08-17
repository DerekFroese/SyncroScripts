<#
    This is handy to run as a setup script in a policy
    By Derek Froese, https://www.linkedin.com/in/derekfroese/
#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting Script"   
Import-Module $env:SyncroModule

function Get-ActivationStatus {
[CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$DNSHostName = $Env:COMPUTERNAME
    )
    process {
        try {
            $wpa = Get-WmiObject SoftwareLicensingProduct -ComputerName $DNSHostName `
            -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f'" `
            -Property LicenseStatus -ErrorAction Stop
        } catch {
            $status = New-Object ComponentModel.Win32Exception ($_.Exception.ErrorCode)
            $wpa = $null    
        }
        $out = New-Object psobject -Property @{
            ComputerName = $DNSHostName;
            Status = [string]::Empty;
        }
        if ($wpa) {
            :outer foreach($item in $wpa) {
                switch ($item.LicenseStatus) {
                    0 {$out.Status = "Unlicensed"}
                    1 {$out.Status = "Licensed"; break outer}
                    2 {$out.Status = "Out-Of-Box Grace Period"; break outer}
                    3 {$out.Status = "Out-Of-Tolerance Grace Period"; break outer}
                    4 {$out.Status = "Non-Genuine Grace Period"; break outer}
                    5 {$out.Status = "Notification"; break outer}
                    6 {$out.Status = "Extended Grace"; break outer}
                    default {$out.Status = "Unknown value"}
                }
            }
        } else {$out.Status = $status.Message}
        $out
    }
}

Write-Output "$(get-date -Format 'HH:mm:ss') Getting activation status"   
$ActivationStatus = Get-ActivationStatus
Write-Output $ActivationStatus
if ($ActivationStatus.Status -notlike "Licensed") {
    Write-Output "$(get-date -Format 'HH:mm:ss') This machine is not licensed"
    Rmm-Alert -Category 'Windows_Activation' -Body "Activation Status is $($ActivationStatus.Status)"
}
Write-Output "$(get-date -Format 'HH:mm:ss') Script complete"   

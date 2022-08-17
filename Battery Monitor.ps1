<#
Monitors battery health by comparing the reported last charge value to the maximum charge value.
Good to run regularly in a policy.

Set a runtime variable called "AlertPercent". Set your own percentage as an acceptable failure rate. E.g. "50" is 50%

From https://admin.syncromsp.com/shared_scripts/1325
Updated By Derek Froese, https://www.linkedin.com/in/derekfroese/
#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting script"
Import-Module $env:SyncroModule
Write-Output "$(get-date -Format 'HH:mm:ss') Running battery report from powercfg"
& powercfg /batteryreport /XML /OUTPUT "batteryreport.xml"
start-sleep 3

Write-Output "$(get-date -Format 'HH:mm:ss') processing battery report"   
[xml]$Report = Get-Content "batteryreport.xml"
 $BatteryStatus = $Report.BatteryReport.Batteries |
ForEach-Object {
    [PSCustomObject]@{
        DesignCapacity     = $_.Battery.DesignCapacity
        FullChargeCapacity = $_.Battery.FullChargeCapacity
        CycleCount         = $_.Battery.CycleCount
        Id                 = $_.Battery.id
    }
}

if (!$Report.BatteryReport.Batteries) {
    Write-Output "$(get-date -Format 'HH:mm:ss') This device does not have batteries, or we could not find the status of the batteries."
}

else {
    Write-Output $BatteryStatus
        
    foreach ($Battery in $BatteryStatus) {
        $batteryPercent = [int64]$Battery.FullChargeCapacity * 100 / [int64]$Battery.DesignCapacity
        if ($batteryPercent -lt $AlertPercent) {
            $message = "Battery Health is $([int]$batteryPercent)% which is below threshold of $($AlertPercent)%. `nThe battery was designed for $($battery.DesignCapacity) but has $($Battery.FullChargeCapacity). `nThe battery info is $($Battery.id)"
            Write-Output $(get-date -Format "HH:mm:ss") $message
            Rmm-Alert -Category 'Battery_Health' -Body $message
    
        }
    }
}

Remove-Item "batteryreport.xml"
Write-Output "$(get-date -Format 'HH:mm:ss') Script complete"   

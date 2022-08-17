Import-Module $env:SyncroModule
& powercfg /batteryreport /XML /OUTPUT "batteryreport.xml"
start-sleep 3
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

if (!$BatteryStatus) {
    Write-Host "This device does not have batteries, or we could not find the status of the batteries."
}

foreach ($Battery in $BatteryStatus) {
    if ([int64]$Battery.FullChargeCapacity * 100 / [int64]$Battery.DesignCapacity -gt $AlertPercent) {
        Rmm-Alert -Category 'Battery_Health' -Body "The battery health is less than expect. The battery was designed for $($battery.DesignCapacity) but the maximum charge is $($Battery.FullChargeCapacity). The battery info is $($Battery.id)"

    }
}

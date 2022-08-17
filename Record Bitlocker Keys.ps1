<#
    Get Bitlocker Recovery Key(s) and store them in a custom field called "Drive Encryption Keys"
    This script requires no input; it will find all encrypted drives on it's own
    
    Set up a custom asset field called "Drive Encryption Keys" as a "Text AREA" on
    your Syncro Device asset type. https://admin.syncromsp.com/asset_types/173088/asset_fields
    Avoids using Bitlocker Powershell Module because it's not available on Win7
    
    By Derek Froese https://www.linkedin.com/in/derekfroese/
#>

Write-Output "$(get-date -Format "HH:mm:ss") Starting Script"   
Import-Module $env:SyncroModule

Write-Output "$(get-date -Format "HH:mm:ss") Getting Drivess" 
$Drives = Get-WmiObject Win32_Volume | Where { $_.DriveType -Match "[23]" } | Select Name, Label, DeviceID, DriveLetter, DriveType
$Drives | Add-Member -NotePropertyName BitlockerStatus -NotePropertyValue "0"
$Drives | Add-Member -NotePropertyName BitlockerKey -NotePropertyValue "0"
$Drives | Add-Member -NotePropertyName Nickname -NotePropertyValue "0"

Write-Output "$(get-date -Format "HH:mm:ss") Iterating through drives to get bitlocker info"
ForEach ($Drive in $Drives) {
    Write-Output "$(get-date -Format "HH:mm:ss") Processing drive $($Drive.Name)"   
    $status = manage-bde -status $Drive.DeviceID
    if ($status -like "*ERROR*") {
        $Drive.BitlockerStatus = "inaccessible"
    }
    else {
        $status = $status | Select-String "Protection Status"
        $status = $status.toString()
        $status = $status.subString(26)
        $Drive.BitlockerStatus = $status
    }
    if ($status -like "*Protection On*") {
        Write-Output "$(get-date -Format "HH:mm:ss") Drive has bitlocker, getting key"   
        $info = manage-bde -protectors -get $Drive.DeviceID
        $key = $($info -match '([0123456789-]){50,}').trim()
        $Drive.BitlockerKey = $key
    }
    if ($Drive.DriveLetter) {$Drive.Nickname = $Drive.DriveLetter}
    elseif ($Drive.Label) {$Drive.Nickname = $Drive.Label}
    else {$Drive.Nickname = $Drive.DeviceID.Substring(($Drive.DeviceID.Length - 7),5)}
}

Write-Output "$(get-date -Format "HH:mm:ss") Results:" 
Write-Output $($Drives | ft -autosize)  


Write-Output "$(get-date -Format "HH:mm:ss") Updating Asset Field"
#$Summary = $Drives | ? {$_.BitlockerStatus -notlike "inaccessible"} | ft -autosize Nickname,BitlockerKey |  Out-String
#Syncro formats PS objects weird, so we'll make our own string.
$Summary = "Bitlocker Keys:`n"
foreach ($Drive in $Drives) {
    if ($Drive.BitlockerStatus -notlike "inaccessible") {
        $Summary += "$($Drive.Nickname.PadRight(12)) $($Drive.BitlockerKey)`n"
    }
}

Set-Asset-Field -Name "Drive Encryption Keys" -Value $Summary
Write-Output "$(get-date -Format "HH:mm:ss") Set the custom field value to `n $Summary"

Write-Output "$(get-date -Format "HH:mm:ss") Script Complete"   
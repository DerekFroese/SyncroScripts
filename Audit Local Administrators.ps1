<#
    Stores a list of the local admins in an asset custom variable called "Local Admins", and checks the current local admins against that list. 
    If there is a change, it fires an RMM Alert
    
    Make a "Text Area" Asset Custom Variable called "Local Admins" https://admin.syncromsp.com/asset_types/173088/asset_fields
    If you have a script that installs a local admin account on client machines, 
    make sure it is in the "Setup Scripts" part of your policy so that it will 
    run first and not trip this alert if this script ends up running before that one. 

#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting Script"
Import-Module $env:SyncroModule

$localAdminsArray = $localadminsString.Split("`n")
Write-Output "**Previous local Administrators** `n$localAdminsString"
$obj_group = [ADSI]"WinNT://localhost/Administrators,group"
$newLocalAdminsArray= @($obj_group.psbase.Invoke("Members")) | foreach{([ADSI]$_).InvokeGet("Name")}
$newLocalAdminsString = $newLocalAdminsArray -join "`n"

Write-Output "** Current local Administrators** `n$newLocalAdminsString"

$comparison = compare-object -ReferenceObject $localAdminsArray -DifferenceObject $newLocalAdminsArray
$newAdmins = $comparison | ? {$_.sideIndicator -like "=>"} | select -ExpandProperty InputObject
$removedAdmins = $comparison | ? {$_.sideIndicator -like "<="} | select -ExpandProperty InputObject
Write-Output "**Comparison:**"
Write-Output $comparison | ft

Write-Output "$(get-date -Format 'HH:mm:ss') Checking if script has run before"

if (($localAdminsString.Length -gt 0) -and ($comparison)) {
    Write-Output "$(get-date -Format 'HH:mm:ss') **script has run before and there's a new admin. Updating Local Admins variable**"
    Set-Asset-Field -Name "Local Admins" -Value $newLocalAdminsString
    
    Write-Output "**Firing RMM Alert**"
    $alertBody = @"
Local Administrators group has changed. 
**Admins added:**
$newAdmins

**Admins Removed:**
$removedAdmins

**Old list:**
$localadminsString

**Current List:** 
$newLocalAdminsString
"@
    rmm-alert -Category "local_administrators_changed" -Body $alertBody
}

if ($localAdminsString.Length -lt 1) {
    Write-Output "$(get-date -Format 'HH:mm:ss') **Script hasn't run before. Setting Local Admins**"
    Set-Asset-Field -Name "Local Admins" -Value $newLocalAdminsString
}

if (($localAdminsString.Length -gt 0) -and (!$comparison)) {
    Write-Output "$(get-date -Format 'HH:mm:ss') **No change to previously listed local admins** "
}
Write-Output "$(get-date -Format 'HH:mm:ss') Script complete"

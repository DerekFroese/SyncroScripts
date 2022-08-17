<# 
    This is handy to set as am autoremediation. https://admin.syncromsp.com/rmm_automations
    By Derek Froese, https://www.linkedin.com/in/derekfroese/
#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting Script"   

###This is how many days old something must be to be erased from $tempFoldersOld
$ageToSave = 90

###Remove things older than $ageToSave days from these
$tempFoldersOld  = @(
"$env:SystemDrive\users\*\Downloads",
"C:\Windows\Logs\CBS",
"$env:SystemDrive\$Recycle.bin"
)

###Remove Everything from these:
$tempFoldersAll = @(
"$env:SystemDrive\Windows\temp",
"$env:SystemDrive\Windows\system32\wbem\logs",
"$env:SystemDrive\Windows\system32\logfiles",
"$env:SystemDrive\Windows\Debug",
"$env:SystemDrive\users\*\AppData\Local\Temp",
"$env:SystemDrive\Users\*\AppData\Local\Microsoft\Windows\INetCache",
"$env:SystemDrive\Users\*\AppData\Local\Microsoft\Windows\INetCookies",
"$env:SystemDrive\Users\*\AppData\Roaming\Microsoft\Windows\Cookies",
"$env:SystemDrive\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files"
)

###Display current state of affairs
Write-Output "$(get-date -Format 'HH:mm:ss') ###Before:###"
Get-PSDrive $env:SystemDrive.Substring(0,1) | Select-Object Name,@{Label="Used_GB";Expression={[int]($_.Used/1GB)}},@{Label="Free_GB";Expression={[Int]($_.Free/1GB)}}

Write-Output "$(get-date -Format 'HH:mm:ss') Emptying Temp Folders"   
ForEach ($tempFolder in $tempFoldersAll) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Emptying $tempFolder"   
    Remove-Item "$tempFolder\*" -Recurse -ErrorAction SilentlyContinue
}

Write-Output "$(get-date -Format 'HH:mm:ss') Deleting items older than $ageToSave days from folders:"   
ForEach ($tempFolder in $tempFoldersOld) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Deleting old files from $tempFolder"   
    dir $tempFolder -recurse | where { ((get-date)-$_.LastWriteTime).days -gt $ageToSave } | remove-item -force -ErrorAction SilentlyContinue
}

###Clean up SXS folder
Write-Output "$(get-date -Format 'HH:mm:ss') Cleaning SXS folder"   
schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"
#dism /online /Cleanup-Image /StartComponentCleanup
# ^ is not as safe as the schtasks method.

Write-Output "$(get-date -Format 'HH:mm:ss') Running Clean Manager"   
cleanmgr.exe /d $($env:SystemDrive.Substring(0,1)) /AUTOCLEAN

#Shadow Copies
Write-Output "$(get-date -Format 'HH:mm:ss') Cleaning shadow copies"   
Vssadmin list shadowstorage 
#gotta finish this.

###Display current state of affairs
Write-Output "$(get-date -Format 'HH:mm:ss') ###After:###"
Get-PSDrive $env:SystemDrive.Substring(0,1) | Select-Object Name,@{Label="Used_GB";Expression={[int]($_.Used/1GB)}},@{Label="Free_GB";Expression={[Int]($_.Free/1GB)}}

Write-Output "$(get-date -Format 'HH:mm:ss') Script complete"   

#In future version, incorporate Patch Cleaner? http://www.homedev.com.au/Free/PatchCleaner
#or this?: https://msdn.microsoft.com/en-us/library/windows/desktop/aa370523(v=vs.85).aspx

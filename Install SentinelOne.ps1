<# 
    Create a Customer Custom Variable called "SentinelOne Site Token" of type "Text Field" https://admin.syncromsp.com/customer_fields
    Remember to upload your SentinelOne installer as a Script File with an exe file extension, and have it download to the location defined in $Exe
    Remember to populate the SentinelOne Site Token for each customer and add its population to your onboarding SOP
    You may want to add it as a startup script to policies that include AV
    I recommend that any policy that includes AV installer also has a process or service monitor to make sure AV is running.

    Written by Derek Froese https://www.linkedin.com/in/derekfroese/

#>

Write-Output "$(get-date -Format "HH:mm:ss") Starting Script"  
Import-Module $env:SyncroModule

$Exe = "C:\windows\temp\S1Agent.exe" 
$Args = "/SITE_TOKEN=$siteToken /SILENT"

if (-not $siteToken) {
    Write-warning "$(get-date -Format "HH:mm:ss") siteToken was not found for this client. Please get your site token from sentinelOne and populate it for this client "
    exit 1
}

if (-not (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.Publisher -like "SentinelOne" -and $_.DisplayName -like "Sentinel Agent" })) {
    #SentinelOne is not already installed

    Write-Output "$(get-date -Format "HH:mm:ss") Starting SentinelOne installer with Site Token $siteToken"
    Start-Process -FilePath $Exe -ArgumentList $Args -Wait
    #Start-Process is used so that Powershell will wait for completion before executing the removal of the installer
    Write-Output "$(get-date -Format "HH:mm:ss") Installer complete."

}
else {
    Write-Warning "$(get-date -Format "HH:mm:ss") SentinelOne already installed. Uninstall it and run this again if you wish to reinstall"
}

Remove-Item $Exe
Write-Output "$(get-date -Format "HH:mm:ss") Exe deleted, script complete"


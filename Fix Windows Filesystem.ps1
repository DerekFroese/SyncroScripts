<#
    Runs various tasks to fix Windows filesystems. Often will set a chkdisk for next boot. 
    Recommended that you schedule a reboot for the night after this script runs.
    
    More complete than https://admin.syncromsp.com/shared_scripts/66
    
    By Derek Froese https://www.linkedin.com/in/derekfroese/

#>

Write-Output "$(get-date -Format "HH:mm:ss") chkdsk /scan $($env:SystemDrive)"
chkdsk /scan $($env:SystemDrive)

Write-Output "$(get-date -Format "HH:mm:ss") chkdsk /spotfix  $($env:SystemDrive)"
echo y | chkdsk /R /spotfix $($env:SystemDrive)

#Write-Output "$(get-date -Format "HH:mm:ss") Setting $($env:SystemDrive) as dirty to force chkdsk on next boot"
#fsutil dirty set $($env:SystemDrive)

Write-Output "$(get-date -Format "HH:mm:ss") dism /online /cleanup-image /CheckHealth"
dism /online /cleanup-image /CheckHealth

Write-Output "$(get-date -Format "HH:mm:ss") dism /online /cleanup-image /ScanHealth"
dism /online /cleanup-image /ScanHealth

Write-Output "$(get-date -Format "HH:mm:ss") dism /online /cleanup-image /startcomponentcleanup"
dism /online /cleanup-image /startcomponentcleanup

Write-Output "$(get-date -Format "HH:mm:ss") dism /online /cleanup-image /restorehealth"
dism /online /cleanup-image /restorehealth

Write-Output "$(get-date -Format "HH:mm:ss") sfc /scannow"
sfc /scannow

Write-Output "$(get-date -Format "HH:mm:ss") Work complete"
Write-Output "check %windir%/Logs/CBS/CBS.log and %windir%\Logs\DISM\dism.log for details"

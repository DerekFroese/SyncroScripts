<#
    Resets Network Stack
    
    By Derek Froese https://www.linkedin.com/in/derekfroese/
#>



Write-Output "$(get-date -Format "HH:mm:ss") ipconfig /all"
ipconfig /all
Write-Output "$(get-date -Format "HH:mm:ss") netsh winsock reset"
netsh winsock reset
Write-Output "$(get-date -Format "HH:mm:ss") netsh int ip reset"
netsh int ip reset
Write-Output "$(get-date -Format "HH:mm:ss") ipconfig /release"
ipconfig /release
Write-Output "$(get-date -Format "HH:mm:ss") ipconfig /renew"
ipconfig /renew
Write-Output "$(get-date -Format "HH:mm:ss") ipconfig /flushdns"
ipconfig /flushdns

#ipconfig /registerdns 

Write-Output "$(get-date -Format "HH:mm:ss") ipoconfig /all"
ipconfig /all
Write-Output "$(get-date -Format "HH:mm:ss") Script complete"  

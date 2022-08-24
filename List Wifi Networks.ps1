<#
    lists wi-fi networks and their passwords
    Stolen from https://gist.github.com/willjobs/8d78fa8bb5de69b1143da6933761a71f
    
    Formatted for Syncro By Derek Froese, https://www.linkedin.com/in/derekfroese/
#>

Write-Output "$(get-date -Format "HH:mm:ss") Starting Script"
$wifiNetworks = (netsh wlan show profiles) | 
    Select-String "\:(.+)$" | 
    %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | 
    %{(netsh wlan show profile name="$name" key=clear)}  | 
    Select-String "Key Content\W+\:(.+)$" | 
    %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | 
    %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }}
$wifiNetworks | Format-Table -AutoSize 

Write-Output "`n$(get-date -Format "HH:mm:ss") Script Complete"

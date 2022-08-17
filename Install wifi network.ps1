<# 
    Installs Wi-fi Network on windows machine. 
    Create dropdown variable "Encryption" with options AES, WEP, TKIP, none
    AES should be default
    
    Create dropdown variable 'Authentication' with options WPA2PSK, shared, WPA, WPAPSK, WPA2
    WPA2PSK should be default
    
    Created runtime variables SSID, Key

    By Derek Froese  # https://www.linkedin.com/in/derekfroese/
    I know Cyberdrain made one in 2022 too: https://admin.syncromsp.com/shared_scripts/1296
    But I think I got there first ;)  https://www.reddit.com/r/PowerShell/comments/fgazrz/comment/fk4k073/

    Microsoft Documentation on XML Schema: https://msdn.microsoft.com/en-us/library/windows/desktop/ms706965(v=vs.85).aspx
#>
Write-Output "$(get-date -Format "HH:mm:ss") Starting Script"   
    $tempFile = "$($env:systemdrive)\windows\temp\wirelessProfile.xml"

    $configXML = @"
    <?xml version="1.0"?>
    <WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
        <name>$SSID</name>
	    <SSIDConfig>
		    <SSID>
			    <name>$SSID</name>
		    </SSID>
	    </SSIDConfig>
	    <connectionType>ESS</connectionType>
	    <connectionMode>auto</connectionMode>
	    <MSM>
		    <security>
			    <authEncryption>
				    <authentication>$Authentication</authentication>
				    <encryption>$Encryption</encryption>
				    <useOneX>false</useOneX>
			    </authEncryption>
			    <sharedKey>
				    <keyType>passPhrase</keyType>
				    <protected>false</protected>
				    <keyMaterial>$Key</keyMaterial>
			    </sharedKey>
		    </security>
	    </MSM>
    </WLANProfile>
"@
Write-Output "$(get-date -Format "HH:mm:ss") Saving XML to $tempFile"   
    $configXML | Out-File $tempFile
    Write-Output "$(get-date -Format "HH:mm:ss") Running netsh to save wireless profile"   
    netsh wlan add profile filename=$tempFile
    del $tempFile

    netsh wlan show profile
Write-Output "$(get-date -Format "HH:mm:ss") Script complete"   

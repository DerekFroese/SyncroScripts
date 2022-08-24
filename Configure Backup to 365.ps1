<# 
    Sets machine-wide backup of docs, desktop, pics to OneDrive for Business (365)
    Create a Customer Custom Field called "365 Tenant ID" https://admin.syncromsp.com/customer_fields
    
    By Derek Froese, https://www.linkedin.com/in/derekfroese/
    
    #TODO In a policy, should be paired with monitoring OneDrive for errors. OneDrive doesn't write errors to the event log but to a file, so parsing will be annoying.
    #TODO would be cleaner to do this with a custom PSObject or at least array, then iterate through them. Scales to more registry keys that way 

#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting Script"

if ($tenantID.length -lt 1) {
    Write-Output "$(get-date -Format 'HH:mm:ss') tenantID not populated. Can't proceed"
    exit 1
}
Write-Output "$(get-date -Format 'HH:mm:ss') 365 tenant ID is $tenantID"

$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'
$Name         = 'KFMSilentOptIn'
$Value        = $tenantID
$Type         = 'String'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Creating registry key $RegistryPath [$Name]"
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
Write-Output "$(get-date -Format 'HH:mm:ss') Setting Registry Key $RegistryPath [$Name]"
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType $Type -Force



$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'
$Name         = 'KFMSilentOptInWithNotification'
$Value        = '00000001'
$Type         = 'DWORD'
# Create the key if it does not exist
If (-NOT (Test-Path $RegistryPath)) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Creating registry key $RegistryPath [$Name]"
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Now set the value
Write-Output "$(get-date -Format 'HH:mm:ss') Setting Registry Key $RegistryPath [$Name]"
New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType $Type -Force


Write-Output "$(get-date -Format 'HH:mm:ss') Script complete"

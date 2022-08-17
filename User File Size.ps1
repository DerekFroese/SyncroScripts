<#
    Counts up space used in User Directory and notes biggest users. 
    Useful before setting up OneDrive backup or Folder Redirection, etc.
    
    If ticket number supplied, results are appended to that ticket. Asset must already be attached to ticket (this is a Syncro limitation)
    if fireAlert is true, results will be presented in an alert.
    
    Create script runtime variable ticketNumber
    Create script dropdown variable fireAlert with options "yes", "no"

    By Derek Froese https://www.linkedin.com/in/derekfroese/
    
    #TODO Need to remake this using PSObjects.
#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting script"
Import-Module $env:SyncroModule

$FilterOut = @("Dropbox","OneDrive")

$Total_Desktops_in_MB = 0
$Total_Docs_in_MB = 0
$Users_With_gt_5GB = 0
$Users_With_gt_1GB = 0
$Users_With_gt_100_MB = 0
$Highest_Usage_User = "No One > 0"
$Highest_Usage_in_MB = 0
$Details =""

Write-Output "$(get-date -Format 'HH:mm:ss') Measuring entire user folder"
$UserFolderSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users | ? {$FilterOut -NotContains $_.Name} | Measure-Object -Sum Length -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;
$UserFolderSizeGB = $UserFolderSize / 1GB
Write-Output "$(get-date -Format 'HH:mm:ss') C:\users is $($UserFolderSizeGB.ToString("#.##")) GB"
$Details += "C:\users is $($UserFolderSizeGB.ToString("#.##")) GB `n"

Write-Output "$(get-date -Format 'HH:mm:ss') Getting User List"
$users = ls C:\users
foreach($user in $users) {
    $username = $user | Select -ExpandProperty Name;
    Write-Output "$(get-date -Format 'HH:mm:ss') Reviewing $username"
    $DocumentSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users\$username\Documents | ? {$FilterOut -NotContains $_.Name} | Measure-Object -Sum Length -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;
    $DocumentSizeMB = $DocumentSize / 1MB
    Write-Output "$(get-date -Format 'HH:mm:ss') $username 's Docs are $($DocumentSizeMB.ToString("#.##")) MB"
    $Details += "$username 's Docs are $($DocumentSizeMB.ToString("#.##")) MB`n"
    $DesktopSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users\$username\Desktop | Measure-Object -Sum Length  -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;
    $DesktopSizeMB = $DesktopSize / 1MB 
    Write-Output "$(get-date -Format 'HH:mm:ss') $username 's Desktop is $($DesktopSizeMB.ToString("#.##")) MB"
    $Details += "$username 's Desktop is $($DesktopSizeMB.ToString("#.##")) MB`n"
    
    $Total_Desktops_in_MB += $DesktopSizeMB
    $Total_Docs_in_MB += $DocumentSizeMB
    if (($DocumentSize + $DesktopSize) -gt 5GB) {$Users_With_gt_5GB ++}
    if (($DocumentSize + $DesktopSize) -gt 1GB) {$Users_With_gt_1GB ++}
    if (($DocumentSize + $DesktopSize) -gt 100MB) {$Users_With_gt_100_MB ++}
    if (($DocumentSizeMB + $DesktopSizeMB) -gt $Highest_Usage_in_MB) {$Highest_Usage_User = $username} 
    if (($DocumentSizeMB + $DesktopSizeMB) -gt $Highest_Usage_in_MB) {$Highest_Usage_in_MB = ($DocumentSizeMB + $DesktopSizeMB)}

    Write-Output "$(get-date -Format 'HH:mm:ss') Done with $username"


    $DocumentSize = 0
    $DesktopSize = 0
    $DocumentSizeMB = 0
    $DesktopSizeMB = 0
}

$summary = ""
$summary += "===============================================================`n"
$summary += "C:\Users is $($UserFolderSizeGB.ToString("#.##")) GB `n"
$summary += "All Desktops take up: $($Total_Desktops_in_MB.ToString("#.##")) MB`n"
$summary += "All Docs take up: $($Total_Docs_in_MB.ToString("#.##")) MB`n"
$summary += "Number of Users with more than 5GB: $Users_With_gt_5GB `n"
$summary += "Number of Users with more than 1GB: $Users_With_gt_1GB `n"
$summary += "Number of Users with more than 100MB: $Users_With_gt_100_MB `n"
$summary += "Biggest User is $Highest_Usage_User with $($Highest_Usage_in_MB.ToString("#.##")) MB`n"
$summary += "===============================================================`n"

Write-Output $summary
Write-Output "$(get-date -Format 'HH:mm:ss') Logging summary snippet to asset lot"
Log-Activity -Message "Largest User is $Highest_Usage_User with $($Highest_Usage_in_MB.ToString("#.##")) MB`n" -EventName "User_Files_Result"
Log-Activity -Message "Desktops take up $($Total_Desktops_in_MB.ToString("#.##")) MB. Docs take up: $($Total_Docs_in_MB.ToString("#.##")) MB."

if ($ticketNumber) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Adding info to ticket $ticketNumber"
    Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketNumber -Subject "Results" -Body "$($env:COMPUTERNAME) `n $($summary) `n $($details)" -Hidden $True -DoNotEmail $True
    Write-Output "$(get-date -Format 'HH:mm:ss') Done updating ticket $ticketNumber"
}

if ($fireAlert -like "yes") {
    Write-Output "$(get-date -Format 'HH:mm:ss') Creating Alert"
    Rmm-Alert -Category 'User_Files_Result' -Body "User files Report Below:`n$summary `n $details"
    Write-Output "$(get-date -Format 'HH:mm:ss') Done creating alert"
}


Write-Output "$(get-date -Format 'HH:mm:ss') Script Complete"

<#
    Counts up space used in User Directory overall, per-user, and per-folder
    Useful before setting up OneDrive backup or Folder Redirection, etc.
    
    If ticket number supplied, results are appended to that ticket. Asset must already be attached to ticket (this is a Syncro limitation)
    if fireAlert is true, results will be presented in an alert.
    You can filter out folders by adding them to $FilterOut and uncommenting that line
    
    #Syncro SETUP#
    Create script runtime variable ticketNumber
    Create script dropdown variable fireAlert with options "yes", "no"

    By Derek Froese https://www.linkedin.com/in/derekfroese/
#>

Write-Output "$(get-date -Format 'HH:mm:ss') Starting script"
Import-Module $env:SyncroModule

#$FilterOut = @("Dropbox","OneDrive")

Write-Output "$(get-date -Format 'HH:mm:ss') Measuring entire user folder"
$UserFolderSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users | ? {$FilterOut -NotContains $_.Name} | Measure-Object -Sum Length -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;
$UserFolderSizeGB = $UserFolderSize / 1GB
Write-Output "$(get-date -Format 'HH:mm:ss') C:\users is $($UserFolderSizeGB.ToString("#.##")) GB"


$users = ls C:\users
Write-Output "$(get-date -Format 'HH:mm:ss') Adding extra properties to `$user variable"
$users | Add-Member -MemberType NoteProperty -Name 'userFolderSize' -value "0"
$users | Add-Member -MemberType NoteProperty -Name 'desktopFolderSize' -value "0"
$users | Add-Member -MemberType NoteProperty -Name 'documentsFolderSize' -value "0"

Write-Output "$(get-date -Format 'HH:mm:ss') Iterating through users"
foreach($user in $users) {
    $username = $user | Select -ExpandProperty Name;
    Write-Output "$(get-date -Format 'HH:mm:ss') Reviewing $username"
    $user.userFolderSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users\$username | Measure-Object -Sum Length  -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;;
    $user.desktopFolderSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users\$username\Desktop | Measure-Object -Sum Length  -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;
    $user.documentsFolderSize = Get-ChildItem -Recurse -Force -errorAction SilentlyContinue C:\users\$username\Documents | ? {$FilterOut -NotContains $_.Name} | Measure-Object -Sum Length -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Sum;
}
Write-Output "$(get-date -Format 'HH:mm:ss') Done reviewing users"


$usersPretty = $users | format-table `
    Name,
    @{Label="User Folder [GB]"; Expression= {($_.userFolderSize/1GB).tostring("#.##")}},
    @{Label="Desktop [GB]"; Expression= {$($_.desktopFoldersize/1GB).tostring("#.##")}},
    @{Label="Documents [GB]"; Expression= {$($_.documentsFolderSize/1GB).tostring("#.##")}}

$usersPretty


if ($ticketNumber) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Adding info to ticket $ticketNumber"
    Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketNumber -Subject "Results" -Body "$($env:COMPUTERNAME) `n C:\users is $($UserFolderSizeGB.ToString("#.##")) GB `n $usersPretty" -Hidden $True -DoNotEmail $True
    Write-Output "$(get-date -Format 'HH:mm:ss') Done updating ticket $ticketNumber"
}

if ($fireAlert -like "yes") {
    Write-Output "$(get-date -Format 'HH:mm:ss') Creating Alert"
    Rmm-Alert -Category 'User_Files_Result' -Body "User files Report Below:`n C:\users is $($UserFolderSizeGB.ToString("#.##")) GB `n $($usersPretty.toString())"
    Write-Output "$(get-date -Format 'HH:mm:ss') Done creating alert"
}

Write-Output "$(get-date -Format 'HH:mm:ss') Script Complete"

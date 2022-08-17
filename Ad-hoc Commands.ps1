<#
    Sometimes you just need to run a custom command or two once on a bunch of machines. 
    Add Script Runtime Variables command1, command2, command3, command4, command5
    
    By Derek Froese https://www.linkedin.com/in/derekfroese/

#>

if ($command1) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Running Command1: $command1"
    Invoke-Expression $command1
    }
else {Write-Output "$(get-date -Format 'HH:mm:ss') Command1 was blank"}

if ($command2) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Running Command2: $command2"
    Invoke-Expression $command2
    }
else {Write-Output "$(get-date -Format 'HH:mm:ss') Command2 was blank"}

if ($command3) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Running Command3: $command1"
    Invoke-Expression $command3
    }
else {Write-Output "$(get-date -Format 'HH:mm:ss') Command3 was blank"}

if ($command4) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Running Command4: $command4"
    Invoke-Expression $command4
    }
else {Write-Output "$(get-date -Format 'HH:mm:ss') Command4 was blank"}

if ($command5) {
    Write-Output "$(get-date -Format 'HH:mm:ss') Running Command5: $command5"
    Invoke-Expression $command5
    }
else {Write-Output "$(get-date -Format 'HH:mm:ss') Command5 was blank"}

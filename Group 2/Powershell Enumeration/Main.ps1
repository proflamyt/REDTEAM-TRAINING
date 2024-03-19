# Just do it

# Import my core script

import-module C:\PSFolder\Core.ps1

$directoryPath = "C:\Program Files"
Get-DirectoryACL -Path $directoryPath
$directoryPath


$hostname = Get-Hostname
$hostname


$securityGroups = Get-SecurityGroups
$securityGroups


$processes = Get-Processes
$processes


$ipAddresses = Get-IPAddresses
$ipAddresses


$domains = Get-Domains
$domains


$registry = Get-Registry
$registry


$services = Get-Services
$services


$scheduledTasks = Get-ScheduledTasks
$scheduledTasks


$autoStartProcesses = Get-AutoStartProcesses
$autoStartProcesses

# Terminate the script
exit
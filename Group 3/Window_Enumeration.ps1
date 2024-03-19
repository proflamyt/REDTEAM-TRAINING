function utility{

    #Using the .NET Framework method
    [System.Net.Dns]::GetHostName()

    #Using the Environment variable:
    $env:COMPUTERNAME

    #Using the hostname command (similar to the command prompt):
    hostname


    #Get ACL for Multiple Files Using Wildcards
    Get-Acl C:\Windows\s*.log | Format-List -Property PSPath, Sddl

    #Get ACL for a Folder: To retrieve the ACL for a specific folder (e.g., C:\Windows), use the following command:
    Get-Acl C:\Windows

    #Get ACL for a Registry Key: 
    Get-Acl -Path HKLM:\System\CurrentControlSet\Control | Format-List


    #Install this to make Add-AD
    Add-WindowsCapability –online –Name “Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0”
    #List All Security Groups:
    Get-ADGroup -Filter {GroupCategory -eq 'Security'}


    Write-Output "`n`nShow all the process running on Host`n`n"
    Get-Process

    Write-Output "`n`nNet IPAddress`n`n"
    Get-NetIPAddress

    Write-Output "`n`nGet Active Directory Domains - If Available`n`n"
    Get-ADDomain

    Write-Output "`n`nShow all the Host Services`n`n"
    Get-Service

    Write-Output "`n`nService check_____ Filtering by Running Service`n`n"
    Get-Service | Where-Object {$_.Status -eq "Running"}

    Write-Output "`n`nService check_____ Check dependencies`n`n"
    Get-Service | Where-Object {$_.DependentServices} | Format-List -Property Name, DependentServices, @{Label="NoOfDependentServices"; Expression={$_.DependentServices.Count}}


    Write-Output "`n`nService check_____ Check ScheduleTask`n`n"
    Get-ScheduledTask

    Write-Output "`n`nService check_____ Check by Status "Ready" `n`n"
    Get-ScheduledTask | Where-Object {$_.State -eq 'Ready'}

    Write-Output "`n`nService check_____ Check by Status "Disabled" `n`n"
    Get-ScheduledTask | Where-Object {$_.State -eq 'Disabled'}


    Write-Output "`n`nAutostart Processes check `n`n"
    Get-WmiObject Win32_Service | Where-Object { $_.StartMode -eq 'Auto' }


}

utility

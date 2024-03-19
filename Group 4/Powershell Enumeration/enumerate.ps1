# Function to get hostname
function Get-Hostname {
    $env:COMPUTERNAME
}

# Function to get security groups
function Get-SecurityGroups {
    Get-LocalGroup | fl
}

# Function to get processes
function Get-Processes {
    Get-Process
}

# Function to get IP addresses
function Get-IPAddresses {
    Get-NetIPAddress
}

# Function to get domain information
function Get-Domains {
    Get-WmiObject Win32_ComputerSystem | Select-Object Domain
}

# Function to get registry information
function Get-Registry {
    param (
        [string[]]$RegistryHives = @("HKLM:", "HKCR:", "HKCU:", "HKU:", "HKCC:")
    )
    
    foreach ($hive in $RegistryHives) {
        Write-Host "Registry keys under $hive"
        Get-ChildItem -Path $hive -Recurse | Select-Object *
    }
}

# Function to get services
function Get-Services {
    Get-Service
}

# Function to get scheduled tasks
function Get-ScheduledTasks {
    Get-ScheduledTask
}

# Function to get autostart processes
function Get-AutoStartProcesses {
    Get-CimInstance Win32_StartupCommand
}

#Function to get ACLs of directories
# Function to get ACLs of directories
function Get-PathAcl {
    $path = Read-Host "Enter the path"
    Get-Acl -Path $path
    }

#Function to get all Users on a host
function Get-Win32UserAccount {
    # Get all user accounts using WMI
    $userAccounts = Get-WmiObject Win32_UserAccount

    # Output the user accounts
    return $userAccounts
}

# Call the function to get user accounts
function Get-UserAccounts {
    # Get all user accounts using WMI
    $userAccounts = Get-WmiObject Win32_UserAccount

    # Output the user accounts
    return $userAccounts
}


# Main script
Write-Host "Under the Nose of Yuki"
Write-Host "What would you like to sniff:):"
Write-Host "1. Hostname"
Write-Host "2. Security Groups"
Write-Host "3. Processes"
Write-Host "4. IP Addresses"
Write-Host "5. Domains"
Write-Host "6. Registry"
Write-Host "7. Services"
Write-Host "8. Scheduled Tasks"
Write-Host "9. AutoStart Processes"
Write-Host "10. ACLs"
Write-Host "11. User Accounts"

# Read user input
$userChoice = Read-Host "Enter the number corresponding to the information you want to retrieve"

# Retrieve the selected information
switch ($userChoice) {
    1 { Get-Hostname }
    2 { Get-SecurityGroups }
    3 { Get-Processes }
    4 { Get-IPAddresses }
    5 { Get-Domains }
    6 { Get-Registry }
    7 { Get-Services }
    8 { Get-ScheduledTasks }
    9 { Get-AutoStartProcesses }
    10 {Get-PathAcl}
    11 {Get-UserAccounts}
    default { Write-Host "Invalid choice. Please select a number between 1 and 11." }
}

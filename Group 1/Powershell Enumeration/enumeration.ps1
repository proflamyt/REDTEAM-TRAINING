# Function to get ACLs of a specified directory
function Get-ACLs {
    param (
        [string]$path
    )
    Get-Acl -Path $path | Select-Object -ExpandProperty AccessToString
}

# Function to get security groups
function Get-SecurityGroups {
    Get-LocalGroup | Select-Object -ExpandProperty Name
}

# Function to get processes
function Get-Processes {
    Get-Process | Select-Object -Property Name, Id, Path, Company
}

# Function to get IP addresses
function Get-IPAddresses {
    Get-NetIPAddress | Select-Object -Property IPAddress
}

# Function to get domain information
function Get-Domains {
    Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Domain
}

# Function to get registry information
function Get-Registry {
    Get-ChildItem -Path Registry::HKEY_LOCAL_MACHINE | Select-Object -ExpandProperty Name
}

# Function to get services
function Get-Services {
    Get-Service | Select-Object -Property Name, DisplayName, Status
}

# Function to get scheduled tasks
function Get-ScheduledTasks {
    Get-ScheduledTask | Select-Object -Property TaskName, TaskPath
}

# Function to get autostart processes
function Get-AutoStartProcesses {
    Get-CimInstance Win32_StartupCommand | Select-Object -Property Command, Location, User
}

# Get hostname
$hostname = $env:COMPUTERNAME

# Collect data
$enumerationData = @{
    Hostname = $hostname
    ACLs = (Get-ACLs -path 'C:\')
    SecurityGroups = (Get-SecurityGroups)
    Processes = (Get-Processes)
    IPAddresses = (Get-IPAddresses)
    Domains = (Get-Domains)
    Registry = (Get-Registry)
    Services = (Get-Services)
    ScheduledTasks = (Get-ScheduledTasks)
    AutoStartProcesses = (Get-AutoStartProcesses)
}

# Output the enumeration data
$enumerationData | ConvertTo-Json

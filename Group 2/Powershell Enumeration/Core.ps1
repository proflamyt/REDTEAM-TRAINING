#Function to get ACLs of a directory
function Get-DirectoryACL {
    param (
        [string]$Path
    )

    $acl = Get-Acl $Path
    $acl | Format-List
}

#Function to get the hostname of the host
function Get-Hostname {
    $hostname = hostname
    $hostname
}

# Function to get security groups of the host
function Get-SecurityGroups {
    $securityGroups = Get-LocalGroup
    $securityGroups
}

# Function to get running processes
function Get-Processes {
    $processes = Get-Process
    $processes
}

# Function to get IP addresses of the host
function Get-IPAddresses {
    $ipconfig = Get-NetIPAddress 
    $ipconfig
}

# Function to get domains
function Get-Domains {
    $domains = Get-WmiObject Win32_ComputerSystem | Select-Object -ExpandProperty Domain
    $domains
}

# Function to get registry information
function Get-Registry {
    $registry = Get-ChildItem HKLM:\SOFTWARE
    $registry
}

# Function to get services
function Get-Services {
    $services = Get-Service
    $services
}

# Function to get scheduled tasks
function Get-ScheduledTasks {
    $tasks = Get-ScheduledTask
    $tasks
}

# Function to get autostart processes
function Get-AutoStartProcesses {
    $autoStart = Get-CimInstance Win32_StartupCommand
    $autoStart
}

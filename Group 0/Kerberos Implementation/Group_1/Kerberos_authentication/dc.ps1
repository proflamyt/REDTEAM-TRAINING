# # Import Encryption Module
Import-Module .\encrypt-decrypt.psm1 -Force


$RECEIVE_PORT = 12346

# Create a TCP listener on the specified port
$listener = [System.Net.Sockets.TcpListener]::new('127.0.0.1', $RECEIVE_PORT)
$listener.Start()

# Accept the incoming connection
$client = $listener.AcceptTcpClient()
$stream = $client.GetStream()


# Simulated User Password
$UserPassword = "password1"

# Simulated Domain Controller Password
$DCPassword = "dcpassword"

# Simulated SQL Server Password
$SQLPassword = "iloveyou"


# Authentication request
$Request = "Authenticate to the SQL server"

#authentication info to be permitted
$dcauth= @{
    "Heading" = "Authentication Request"
    "Message" = $Request
    "password" = $UserPassword
    "sql_password" = $SQLPassword
    "Timestamp" = $Timestamp
}

# Read the data sent by the client
while ($true) {
    $buffer = New-Object byte[] 4096
    $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
    $receivedData = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)
    
    # Check the length of the received data for the user authentication
    if ($receivedData.Length -eq 122 -or $receivedData.Length -eq 118) {
        # Process the data with the desired lengths
        Write-Host "Received data with length $($receivedData.Length): $receivedData"
    }
}


function UserAuthentication($user) {
    return $UserTGT, $SessionKey
}

function ServiceAuthentication($Service){
    return $SQLTicket, $SessionKey
}


# Close the client and the listener
$reader.Close()
$stream.Close()
$client.Close()
$listener.Stop()


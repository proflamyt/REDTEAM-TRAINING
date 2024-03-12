# Domain controller details
Import-Module ./utils.ps1 -Force

$dcDetails = @{
    Ip = "127.0.0.1"
    Port = 8400
    Password = "superman"
}

# Convert DC password to bytes
$dcPasswordBytes = [System.Text.Encoding]::UTF8.GetBytes($dcDetails.Password)

# User details
$userDetails = @{
    Username = "Yuki007"
    FirstName = "Yuki"
    UID = 9000  # Convert UID to integer for consistency
    LastName = "Ahna"
    Email = "Yukiahna@sentinelfounders.com"
    Password = "lexluthor"  
    Ip = "127.0.0.1"
    Port = 8401
    SID = "S-1-5-21-7891234567-8901234567-4567891234-1002"
}

# User details
$SqlDetails = @{
    Service = "SqlService"
    Password = 'iloveyou'
    Ip = "127.0.0.1"
    Port = 5005
}

# Start TCP listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($SqlDetails.Ip), $SqlDetails.Port)
$listener.Start()

Write-Output "The SQL Service Script is awaiting Connections:"

# Accept client connection
$client = $listener.AcceptTcpClient()
$stream = $client.GetStream()


# Receive encrypted data from the domain script
$receivedData = New-Object byte[] 50024
$bytesRead = $stream.Read($receivedData, 0, $receivedData.Length)

# Convert received data to JSON
$data = [System.Text.Encoding]::UTF8.GetString($receivedData, 0, $bytesRead)
$output = ($data -replace ",$", "") | ConvertFrom-Json

# Close the stream and client
$stream.Close()
$client.Close()

# Extract the encrypted SQL session key and SQL service ticket from the received data
$encryptedSQLServiceTicket  = $output.SendsqlTicket
$sqlSessionKey = $output.encryptedSqlmessage

# Output the Encrypted SQL service Ticket
Write-Output "Encrypted SQL Service Session Key Received From the User:"
Write-Output ($encryptedSQLServiceTicket -join '')

# Output the Encrypted SQL session key
Write-Output "Encrypted SQL Service Message Received From the User:"
Write-Output ($sqlSessionKey -join '')
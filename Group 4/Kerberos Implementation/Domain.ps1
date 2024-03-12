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
}

# Start TCP listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($dcDetails.Ip), $dcDetails.Port)
$listener.Start()

Write-Output "The Domain Controller Script is awaiting Connections:"


# Accept client connection
$client = $listener.AcceptTcpClient()
$stream = $client.GetStream()

# Receive data from the client
$ETS = New-Object byte[] 1024
$bytesRead = $stream.Read($ETS, 0, $ETS.Length)

# Convert received data to JSON
$data = [System.Text.Encoding]::UTF8.GetString($ETS, 0, $bytesRead) 
$output = ($data -replace "\x00") | ConvertFrom-Json

# Close the stream and client
$stream.Close()
$client.Close()

# Decrypt the received data using XOR
$decryptedTimestampBytes = Encrypt-Or-Decrypt -data $output.Message -key ([System.Text.Encoding]::UTF8.GetBytes($userDetails.Password))

# Convert decrypted bytes to string
$decryptedTimestamp = [System.Text.Encoding]::UTF8.GetString($decryptedTimestampBytes)

# Display the decrypted timestamp
Write-Output "Decrypted timestamp from the User: $decryptedTimestamp"

# Function to generate a session key

# Generate session key
$sessionKey = Generate-SessionKey

# Convert the session key to byte array
$sessionKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($sessionKey)

# Encrypt the session key with the user's password
$encryptedSessionKeyUser = Encrypt-Or-Decrypt -data $sessionKeyBytes -key ([System.Text.Encoding]::UTF8.GetBytes($userDetails.Password))

# Encrypt the session key with the Domain controller's password
$encryptedSessionKeyDomain = Encrypt-Or-Decrypt -data $sessionKeyBytes -key ([System.Text.Encoding]::UTF8.GetBytes($dcDetails.Password))

# Create the TGT
$tgt = @{
    Username = $userDetails.Username
    UID = $userDetails.UID
    SessionKey = $encryptedSessionKeyDomain
    ExpirationDate = (Get-Date).AddHours(1)
} 

# Convert TGT to JSON
$tgtJson = $tgt | ConvertTo-Json

# Convert JSON string to byte array using UTF-8 encoding
$tgtJsonBytes = [System.Text.Encoding]::UTF8.GetBytes($tgtJson)

# Encrypt the entire TGT with the domain controller's password
$encryptedTGTBytes = Encrypt-Or-Decrypt -data $tgtJsonBytes -key $dcPasswordBytes

# Combine TGT and encrypted session key into a single object
$dataToSend = @{
    SessionKey = $encryptedSessionKeyUser
    TGT = $encryptedTGTBytes
    
} | ConvertTo-Json

# Convert the combined data to bytes
$dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataToSend)

# Send the data to the user script via TCP
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($userDetails.Ip, $userDetails.Port)
$stream = $client.GetStream()
$stream.Write($dataBytes, 0, $dataBytes.Length)

# Close the stream and client
$stream.Close()
$client.Close()



# Receive data from the user script (Encrypted TGT and Service Ticket)
$client = $listener.AcceptTcpClient()
$stream = $client.GetStream()

$receivedData = New-Object byte[] 50024
$bytesRead = $stream.Read($receivedData, 0, $receivedData.Length)

$data = [System.Text.Encoding]::UTF8.GetString($receivedData, 0, $bytesRead)
$output = ($data -replace ",$", "") | ConvertFrom-Json

# Close the stream and client
$stream.Close()
$client.Close()


# Extract the encrypted TGT and encrypted Service Ticket from the received data
$encryptedTGT2 = $output.TGT
$encryptedServiceTicket = $output.ServiceTicket

# Output the encrypted TGT2
Write-Output "Received Encrypted TGT2 From User:"
Write-Output ($encryptedTGT2 -join '')



# Decrypt the encrypted TGT with the domain controller's password
$decryptedTGTBytes = Encrypt-Or-Decrypt -data $encryptedTGTBytes -key $dcPasswordBytes

# Convert the decrypted bytes to a string
$decryptedTGTJson = [System.Text.Encoding]::UTF8.GetString($decryptedTGTBytes)

# Convert the JSON string back to a PowerShell object
$decryptedTGT = ConvertFrom-Json $decryptedTGTJson

# Output the decrypted TGT
Write-Output "Decrypted TGT:"
Write-Output $decryptedTGT


#Write-Output "Decrypted TGT2:"
#Write-Output $encryptedTGT2



# Decrypt the Session Key for User using the Encrypt-Or-Decrypt function
$decryptedSessionKeyBytes = Encrypt-Or-Decrypt -data $encryptedSessionKeyUser -key ([System.Text.Encoding]::UTF8.GetBytes($userDetails.Password))

# Decrypt the encrypted service ticket using the decrypted session key
$decryptedServiceTicketBytes = Encrypt-Or-Decrypt -data $encryptedServiceTicket -key $decryptedSessionKeyBytes

# Convert decrypted session key bytes to string
$decryptedSessionKey = [System.Text.Encoding]::UTF8.GetString($decryptedSessionKeyBytes)

# Convert the decrypted service ticket bytes to string (assuming it was originally encoded as UTF-8)
$decryptedServiceTicketJson = [System.Text.Encoding]::UTF8.GetString($decryptedServiceTicketBytes)

# Convert the decrypted JSON back to PowerShell object
$decryptedServiceTicket = $decryptedServiceTicketJson | ConvertFrom-Json

# Output the decrypted session key for the user
Write-Output "Decrypted Session Key for User:"
Write-Output $decryptedSessionKey

# Output the decrypted service ticket
Write-Output "Decrypted Service Ticket:"
Write-Output $decryptedServiceTicket


# Encrypt the session key with the User's password
$encryptedSessionKeySqlUser = Encrypt-Or-Decrypt -data $sessionKeyBytes -key ([System.Text.Encoding]::UTF8.GetBytes($userDetails.Password))


# Encrypt the session key with the SQL Service's password
$encryptedSessionKeySQL = Encrypt-Or-Decrypt -data $sessionKeyBytes -key ([System.Text.Encoding]::UTF8.GetBytes($SqlDetails.Password))

#Creating the Service Ticket For SQL Service

$sqlTicket = @{
    Service = $SqlDetails.Service
    ExpirationDate = (Get-Date).AddHours(1)
    SID = $userDetails.SID
    SessionKeySql = $encryptedSessionKeySqlUser
} 

# Convert TGT to JSON
$sqlTicketJson = $sqlTicket | ConvertTo-Json

# Convert JSON string to byte array using UTF-8 encoding
$sqlTicketJsonBytes = [System.Text.Encoding]::UTF8.GetBytes($sqlTicketJson)

# Encrypt the entire Sql Service Ticket with the SQL Service's password
$encryptedSQLBytes = Encrypt-Or-Decrypt -data $sqlTicketJsonBytes -key ([System.Text.Encoding]::UTF8.GetBytes($SqlDetails.Password))



# Output the Encrypted SQL service ticket
Write-Output "Encrypted SQL Service Ticket:"
Write-Output ($encryptedSQLBytes -join '')


# Output the Encrypted SQL service session key
Write-Output "Encrypted SQL Service Ticket session key for User:"
Write-Output ($encryptedSessionKeySQLUser -join '')


# Combine SQL Service Ticket and encrypted session key into a single object
$SQLdataToSend = @{
    sqlSessionKey = $encryptedSessionKeySqlUser
    SQL = $encryptedSQLBytes
    
} | ConvertTo-Json

# Convert the combined data to bytes
$SQLdataBytes = [System.Text.Encoding]::UTF8.GetBytes($SQLdataToSend)

# Send the data to the user script via TCP
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($userDetails.Ip, $userDetails.Port)
$stream = $client.GetStream()
$stream.Write($SQLdataBytes, 0, $SQLdataBytes.Length)

# Close the stream and client
$stream.Close()
$client.Close()
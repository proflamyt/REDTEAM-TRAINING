# Import Encrypt-Decrypt Function
Import-Module ./utils.ps1 -Force

# User details
$userDetails = @{
    Username = "Yuki007"
    FirstName = "Yuki"
    LastName = "Ahna"
    Email = "Yukiahna@sentinelfounders.com"
    Password = "lexluthor"  # Enclose the password in quotes
    Ip = "127.0.0.1"
    Port = 8401
}

# Data center details
$dcDetails = @{
    Ip = "127.0.0.1"
    Port = 8400
}

# Data center details
$sqlDetails = @{
    Ip = "127.0.0.1"
    Port = 5005
}

# Convert user password to bytes
$passwordBytes = [System.Text.Encoding]::UTF8.GetBytes($userDetails.Password)

# Get current timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Convert timestamp to bytes
$timestampBytes = [System.Text.Encoding]::UTF8.GetBytes($timestamp)

# Encrypt timestamp using the user's password
$encryptedTimestampBytes = Encrypt-Or-Decrypt -data $timestampBytes -key $passwordBytes

# Encrypted Timestamp Json
$userRequest = @{
    Type = "Timestamp"
    Message = $encryptedTimestampBytes
} | ConvertTo-Json

# Convert JSON to bytes
$sendUserRequest = [System.Text.Encoding]::UTF8.GetBytes($userRequest)

# Send the encrypted timestamp to the domain script via the domain controller IP and port
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($dcDetails.Ip, $dcDetails.Port)
$stream = $client.GetStream()
$stream.Write($sendUserRequest, 0, $sendUserRequest.Length)

# Close the stream and client
$stream.Close()
$client.Close()

# Start TCP listener
$listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($userDetails.Ip), $userDetails.Port)
$listener.Start()

Write-Output "The User Script is awaiting Connections:"

# Accept client connection from the domain script
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

# Extract the encrypted TGT and encrypted session key from the received data
$encryptedTGTBytes = $output.TGT
$encryptedSessionKeyBytes = $output.SessionKey


# Decrypt the Session Key for Users using the Encrypt-Or-Decrypt function
$decryptedSessionKeyBytes = Encrypt-Or-Decrypt -data $encryptedSessionKeyBytes -key ([System.Text.Encoding]::UTF8.GetBytes($userDetails.Password))

# Convert decrypted session key bytes to string
$decryptedSessionKey = [System.Text.Encoding]::UTF8.GetString($decryptedSessionKeyBytes)

# Output the Encrypted TGT
Write-Output "Encrypted TGT for User From Domain Controller:"
Write-Output ($encryptedTGTBytes -join '')


# Output the Encrypted session key for the user
Write-Output "Encrypted Session Key for User From Domain Controller:"
Write-Output ($encryptedSessionKeyBytes -join '')

# Output the decrypted session key for the user
Write-Output "Decrypted Session Key for User:"
Write-Output $decryptedSessionKey


# Create the Service Ticket
$serviceTicket = @{
    serviceName = "sql server"
    userClient = $userDetails.username
    ExpirationDate = (Get-Date).AddHours(1)
} 

# Convert Service Ticket to JSON
$serviceTicketJson = $serviceTicket | ConvertTo-Json

#Convert the Decrypted Session key to byte array
$decryptedSessionKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($decryptedSessionKey)

# Encrypt the entire Service Ticket with the Decrypted Session-Key for the user

$serviceTicket = Encrypt-Or-Decrypt -data ([System.Text.Encoding]::UTF8.GetBytes($serviceTicketJson)) -key $decryptedSessionKeyBytes

# Combine encrypted TGT and encrypted service ticket into a single object
$dataToSend = @{
    TGT = $encryptedTGTBytes
    ServiceTicket = $serviceTicket
} | ConvertTo-Json

# Convert the combined data to bytes
$dataBytes = [System.Text.Encoding]::UTF8.GetBytes($dataToSend)

# Send the data to the domain script via TCP
$client = New-Object System.Net.Sockets.TcpClient
$client.Connect($dcDetails.Ip, $dcDetails.Port)
$stream = $client.GetStream()
$stream.Write($dataBytes, 0, $dataBytes.Length)

# Output the encrypted service ticket
Write-Output "Encrypted Service Ticket and TGT sent to the domain script."


Write-Output "Encrypted Service Ticket:"
write-output ($serviceTicket -join '')

# Close the stream and client
$stream.Close()
$client.Close()



# Accept client connection from the domain script
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
$encryptedSQLSessionKeyUser = $output.sqlSessionKey
$encryptedSQLServiceTicket = $output.SQL

# Output the Encrypted SQL service Session Key
Write-Output "Encrypted SQL Service Session Key From Domain Controller:"
Write-Output ($encryptedSQLSessionKeyUser -join '')

# Output SQL service ticket type
Write-Output "SQL Service Ticket From Domain Controller:"
Write-Output ($encryptedSQLServiceTicket -join '')


# Decrypt the SQL session key for the user using the Encrypt-Or-Decrypt function
$decryptedSQLSessionKeyBytes = Encrypt-Or-Decrypt -data $encryptedSQLSessionKeyUser -key ([System.Text.Encoding]::UTF8.GetBytes($userDetails.Password))

# Convert decrypted SQL session key bytes to string
$decryptedSQLSessionKey = [System.Text.Encoding]::UTF8.GetString($decryptedSQLSessionKeyBytes)

# Output the Decrypted SQL service session key
Write-Output "Decrypted SQL Service Session Key for User:"
Write-Output $decryptedSQLSessionKey

#Message to send
$Message2Sql = @{
    Message = "You a bitch"
    Recepient = "Olamide"
}

$Message2Sqljson = $Message2Sql | ConvertTo-Json


#Convert the Decrypted Sql service Session key to byte array
$decryptedSqlSessionKeyBytes = [System.Text.Encoding]::UTF8.GetBytes($decryptedSQLSessionKey)


# Encrypt the SQL Message for the SQL Service using New Session Key for user
$encryptedMessage2SqlBytes = Encrypt-Or-Decrypt -data ([System.Text.Encoding]::UTF8.GetBytes($Message2Sqljson)) -key $decryptedSqlSessionKeyBytes


#encrypted Message for user
Write-Output "Encrypted Message For SQL Service:"
Write-Output ($encryptedMessage2Sqlbytes -join '')

$SendSqlAuthentication = @{
    SendsqlTicket = $encryptedSQLServiceTicket
    encryptedSqlmessage = $encryptedMessage2SqlBytes
} | ConvertTo-Json

# Convert the combined data to bytes
$sqldataBytes = [System.Text.Encoding]::UTF8.GetBytes($SendSqlAuthentication)

# Send the data to the domain script via TCP
$client2 = New-Object System.Net.Sockets.TcpClient
$client2.Connect($sqlDetails.Ip, $sqlDetails.Port)
$stream2 = $client2.GetStream()
$stream2.Write($sqldataBytes, 0, $sqldataBytes.Length)



# Output the encrypted service ticket
Write-Output "Encrypted Service Ticket and SQL session Key sent to the User."

$stream2.Close()
$client2.Close()

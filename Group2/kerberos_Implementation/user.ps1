# Import the xorencryption module
Import-Module "C:\Users\Lenovo\Home\keberos\utils.psm1"

# Define the user password (should be the same as the one on the domain controller)
$userPassword = "group3"

# Create a TCP client object
$tcpClient = New-Object System.Net.Sockets.TcpClient

$is_true = $true

try {
    # Connect to the domain controller on port 10201
    $tcpClient.Connect("127.0.0.1", 10201)

    # If connection is successful, enter the loop to send and receive messages
    if ($tcpClient.Connected) {
        while ($is_true) {
            # Encrypt the timestamp using XOR encryption function
            $timestamp = "mytime"
            $encryptedTimestamp = XOREncrypt -plaintext $timestamp -password $userPassword

            # Construct the JSON request
            $jsonRequest = @{
                Type = "UserAuthentication"
                Data = $encryptedTimestamp
            } | ConvertTo-Json

            # Convert the JSON message to bytes
            $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonRequest)

            # Get the network stream
            $stream = $tcpClient.GetStream()

            # Send the JSON message to bytes
            $stream.Write($jsonBytes, 0, $jsonBytes.Length)
            Write-Output "JSON message sent successfully."

            # Read the JSON message as bytes
            $buffer = New-Object byte[] 1024
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)

            # Convert the received bytes to a JSON string
            $jsonMessage = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $bytesRead)

            # Convert the JSON string to a PowerShell object
            $jsonObject = $jsonMessage | ConvertFrom-Json

            # Decrypt the session key using user password
            $encryptedSessionKey = $jsonObject.EncryptedSessionKey
            $sessionKey = -join (XORDecrypt -encryptedBytes $encryptedSessionKey -password $userPassword | ForEach-Object {[char]$_})
            Write-Output $sessionKey

            # Extract the TGT ticket
            $encryptedtgtTicket = $jsonObject.TGT
            Write-Output $encryptedtgtTicket

            # Send SQL service request
            $serviceReq = "SQLAuthentication"
            $encryptedServiceReq = XOREncrypt -plaintext $serviceReq -password $sessionKey

            $jsonServiceRequest = @{
                userTicket = $encryptedtgtTicket
                serviceType = $encryptedServiceReq
            } | ConvertTo-Json -Compress

            # Convert the JSON message to bytes
            $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonServiceRequest)

            # Send the JSON message to the domain controller
            $stream.Write($jsonBytes, 0, $jsonBytes.Length)
            Write-Output "SQL TICKET SENT SUCCESSFULLY"

            $is_true = $false
        }
    } else {
        Write-Error "Failed to connect to the domain controller."
    }
} catch {
    Write-Error "Error occurred while attempting to connect to the domain controller: $_"
} finally {
    # Close the TCP client
    $tcpClient.Close()
}

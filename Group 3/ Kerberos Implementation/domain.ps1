function Start-KerberosListener {
    param(
        [int]$Port = 10201
    )

    # Check if the port parameter is within valid range
    if ($Port -lt 1 -or $Port -gt 65535) {
        Write-Error "Port number is invalid. Please provide a port number between 1 and 65535."
        return
    }

    # User password saved
    $password = "group3"
    # Domain controller password saved
    $dcpassword = "goharder"

    # Create a TCP listener object
    $tcpListener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Any, $Port)

    try {
        # Start listening for incoming connections
        $tcpListener.Start()

        Write-Output "Kerberos listener started. Waiting for connections on port $Port..."

        $is_true = $true
        # Accept connections indefinitely
        while ($is_true) {
            $tcpClient = $tcpListener.AcceptTcpClient()
            Write-Output "Connection accepted from $($tcpClient.Client.RemoteEndPoint)"

            # Get the network stream
            $stream = $tcpClient.GetStream()

            # Read the JSON message as bytes
            $buffer = New-Object byte[] 1024
            $bytesRead = $stream.Read($buffer, 0, $buffer.Length)

            # Convert the received bytes to a JSON string
            $jsonMessage = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $bytesRead)

            # Convert the JSON string to a PowerShell object
            $jsonObject = $jsonMessage | ConvertFrom-Json

            # Picking out the message
            $requestType = $jsonObject.Type
            $encryptedData = $jsonObject.Data

            # Write-Output $requestType
                         

            # Decrypt based on the request type
            if ($requestType -eq "UserAuthentication") {
                # Import the decryption module
                Import-Module C:\Users\abioy\Desktop\CyberSOC\Keberos\utils.psm1

                Write-Output $requestType
                # Decrypt the data
                $decryptedData = -join (XORDecrypt -encryptedBytes $encryptedData -password $password | ForEach-Object {[char]$_})

                # Display the decrypted data
                Write-Output "Decrypted data: $decryptedData"

                # Generate a random session token
                $sessionKey = [System.Guid]::NewGuid().ToString()

                # Encrypt the session key with the user password
                $encryptedSessionKey = XOREncrypt -plaintext $sessionKey -password $password

                # Create a JSON message for the user
                $userTicket = @{
                    user = "user1"
                    Auth = "allow"
                    sessionkey = $sessionKey
                }
                $jsonUserTicket = @{
                    Type = "UserTicket"
                    EncryptedSessionKey = $encryptedSessionKey
                    TGT = XOREncrypt -plaintext ($userTicket | ConvertTo-Json -Compress) -password $dcpassword
                } | ConvertTo-Json -Compress

                # Convert the JSON message to bytes
                $jsonBytes = [System.Text.Encoding]::UTF8.GetBytes($jsonUserTicket)

                # Send the JSON message to the user script
                $stream.Write($jsonBytes, 0, $jsonBytes.Length)
                Write-Output "User ticket sent successfully."

                # For the SQL Service!!!!

                # Read the JSON message as bytes
                $sqlbuffer = New-Object byte[] 1024
                $sqlbytesRead = $stream.Read($sqlbuffer, 0, $sqlbuffer.Length)

                # Convert the received bytes to a JSON string
                $sqljsonMessage = [System.Text.Encoding]::UTF8.GetString($sqlbuffer, 0, $sqlbytesRead)

                # Convert the JSON string to a PowerShell object
                $sqljsonObject = $sqljsonMessage  | ConvertFrom-Json

                # Picking out the message
                $encryptedtgtTicket = $sqljsonObject.userTicket
                $encryptedServiceReq = $sqljsonObject.serviceType
                

                #Working the tgt backward
                $decryptedtgt = -join (XORDecrypt -encryptedBytes $encryptedtgtTicket -password $dcpassword | ForEach-Object {[char]$_})

                # Create a from JSON file
                $sqljsonObject = $decryptedtgt | ConvertFrom-Json
                $sessionKey = $sqljsonObject.sessionkey

                Write-Out $sessionKey


                # Decrypt the $encryptedServiceReq
                $requestType =  -join (XOREncrypt -plaintext $encryptedServiceReq -password $sessionKey)
                Write-Out $requestType
                # Prep for SQL service
                if ($requestType -eq "SQLServiceRequest"){
                    Write-Output "Yes we got here and ready to Create new session key and sql TGT Thanks!!!"

                }

            }               

            } else {
                Write-Error "Unknown request type: $requestType"
            }
 
    } catch {
        Write-Error "Error occurred while starting Kerberos listener: $_"
    } finally {
        # Stop the TCP listener if it's still running
        $tcpListener.Stop()
    }
}

Start-KerberosListener

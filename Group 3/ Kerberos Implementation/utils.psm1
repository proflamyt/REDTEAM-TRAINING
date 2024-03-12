function EncryptOrDecrypt($plaintextBytes, $passwordBytes)
{
 
    # Convert the plaintext and password to byte arrays
    $encryptedBytes = @()
 
    # Perform the XOR operation
    for ($i = 0; $i -lt $plaintextBytes.Length; $i++) {
        $encryptedByte = $plaintextBytes[$i] -bxor $passwordBytes[$i % $passwordBytes.Length]
        $encryptedBytes += $encryptedByte
    }
 
    return $encryptedBytes
 
    
}

#$encryptext = EncryptOrDecrypt $plaintextBytes $passwordBytes
#Write-Output $encryptext

#$encryptext = -join (EncryptOrDecrypt $plaintextBytes $passwordBytes)

#echo $encryptext

#EncryptOrDecrypt $encryptext $passwordBytes

#$DecryptedText = -join (EncryptOrDecrypt $encryptext $passwordBytes | %{[char]$_})
#Write-Output $DecryptedText




# XOR encryption function
function XOREncrypt {
    param(
        [string]$plaintext,
        [string]$password
    )

    $plaintextBytes = [System.Text.Encoding]::UTF8.GetBytes($plaintext)
    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($password)

    $encryptedBytes = @()
    for ($i = 0; $i -lt $plaintextBytes.Length; $i++) {
        $encryptedByte = $plaintextBytes[$i] -bxor $keyBytes[$i % $keyBytes.Length]
        $encryptedBytes += $encryptedByte
    }

    return $encryptedBytes
}

$plaintext = "I am abioye"
$password = "group3"

#XOREncrypt -plaintext $plaintext -password $password

$encryptedBytes = XOREncrypt -plaintext $plaintext -password $password
#Write-Output $encryptedBytes

# Note: The encryptedBytes is the one to pass into the decrytion function
# because it comes out as iteration and not as joined format where the decryption 
# might not know what to do with it!!!


# This give a better look but not for decryptin
# Convert encrypted password bytes to a string for display
#$new_encryptedBytes = $encryptedBytes -join ' '
#Write-Output $new_encryptedBytes



# XOR decryption function
function XORDecrypt {
    param(
        [byte[]]$encryptedBytes,
        [string]$password
    )

    $keyBytes = [System.Text.Encoding]::UTF8.GetBytes($password)

    $decryptedBytes = @()
    for ($i = 0; $i -lt $encryptedBytes.Length; $i++) {
        $decryptedByte = $encryptedBytes[$i] -bxor $keyBytes[$i % $keyBytes.Length]
        $decryptedBytes += $decryptedByte
    }

    #$decryptedText = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    return $decryptedBytes
}


#$decryptedtext = -join (XORDecrypt -encryptedBytes $encryptedBytes -password $password | %{[char]$_})

#Write-Output $decryptedtext 


function StartKerberosListener {
    param(
        [int]$Port = 10200
    )

    # Check if the port parameter is within valid range
    if ($Port -lt 1 -or $Port -gt 65535) {
        Write-Error "Port number is invalid. Please provide a port number between 1 and 65535."
        return
    }

    # Create a TCP listener object
    $tcpListener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Any, $Port)

    try {
        # Start listening for incoming connections
        $tcpListener.Start()

        Write-Output "Kerberos listener started. Waiting for connections on port $Port..."

        # Accept connections indefinitely
        while ($true) {
            $tcpClient = $tcpListener.AcceptTcpClient()
            Write-Output "Connection accepted from $($tcpClient.Client.RemoteEndPoint)"
            $tcpClient.Close()
        }
    } catch {
        Write-Error "Error occurred while starting Kerberos listener: $_"
    } finally {
        # Stop the TCP listener
        $tcpListener.Stop()
    }
}

function TestKerberosAuthentication {
    param(
        [string]$DomainController
    )

    # Check if the domain controller parameter is provided
    if (-not $DomainController) {
        Write-Error "DomainController parameter is required."
        return
    }

    # Create a TCP client object
    $tcpClient = New-Object System.Net.Sockets.TcpClient

    try {
        # Attempt to connect to the domain controller on port 10200
        $tcpClient.Connect($DomainController, 10200)

        # If connection is successful, return success message
        if ($tcpClient.Connected) {
            Write-Output "Kerberos authentication successful. Connected to $DomainController on port 10200."
        } else {
            Write-Error "Failed to connect to $DomainController on port 10200."
        }
    } catch {
        Write-Error "Error occurred while attempting to connect to $DomainController on port 10200: $_"
    } finally {
        # Close the TCP client
        $tcpClient.Close()
    }
}





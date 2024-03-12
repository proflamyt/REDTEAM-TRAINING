function Start-KerberosListener {
    param(
        [int]$Port = 10201
    )

    # Check if the port parameter is within valid range
    if ($Port -lt 1 -or $Port -gt 65535) {
        Write-Error "Port number is invalid. Please provide a port number between 1 and 65535."
        return
    }

    # Start the TCP listener
    $tcpListener = Start-TcpListener -Port $Port

    try {
        Write-Output "Kerberos listener started. Waiting for connections on port $Port..."
        # Accept connections indefinitely
        while ($true) {
            $tcpClient = $tcpListener.AcceptTcpClient()
            Process-ClientConnection -TcpClient $tcpClient
        }
    } catch {
        Write-Error "Error occurred while starting Kerberos listener: $_"
    } finally {
        # Stop the TCP listener if it's still running
        $tcpListener.Stop()
    }
}

function Process-ClientConnection {
    param(
        [System.Net.Sockets.TcpClient]$TcpClient
    )

    try {
        Write-Output "Connection accepted from $($TcpClient.Client.RemoteEndPoint)"
        # Get the network stream
        $stream = $TcpClient.GetStream()
        # Process client requests here
    } catch {
        Write-Error "Error occurred while processing client connection: $_"
    } finally {
        $TcpClient.Close()
    }
}

# Other utility functions or variables can be defined here

# Start the Kerberos listener
Start-KerberosListener

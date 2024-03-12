# Import Encryption Module
Import-Module .\encrypt-decrypt.psm1 -Force

$USERHOST = "127.0.0.1"
$USERPORT = 12346

# Establish TCP connection
$socket = [System.Net.Sockets.TcpClient]::new()
$socket.Connect($USERHOST, $USERPORT)

# Create a network stream for writing
$stream = $socket.GetStream()
$writer = [System.IO.StreamWriter]::new($stream)


# Simulated User Password
$UserPassword = "password1"

# Simulated SQL Server Password
$SQLPassword = "iloveyou"

# Simulated Timestamp
$Timestamp = (Get-Date).ToString()

# Authentication request
$Request = "Authenticate to the SQL server"


#authentication info to be sent
$userauth= @{
    "Heading" = "Authentication Request"
    "Timestamp" = xorEncDec $Timestamp.ToCharArray() $UserPassword
} | ConvertTo-Json






# Write output to the TCP port
$writer.WriteLine($userauth.Length)
$writer.Flush()


# Close the writer and the socket
$writer.Close()
$socket.Close()







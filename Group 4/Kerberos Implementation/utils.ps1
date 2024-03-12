#Function for Encryption and Decryption
function Encrypt-Or-Decrypt {
    param (
        [byte[]]$data,
        [byte[]]$key
    )

    $encryptedData = @()

    for ($i = 0; $i -lt $data.Count; $i++) {
        $encryptedData += $data[$i] -bxor $key[$i % $key.Count]
    }

    return $encryptedData
}


#Function to generate a session key
function Generate-SessionKey {
    $sessionKey = New-Guid
    return $sessionKey
}

Add-Type -AssemblyName System.Security


function Get-EncData {
    param (
        [string]$password
    )
    $key = [System.Convert]::FromBase64String($password);

    $encryptedPassdata = $key[5..$key.Count]

    
    # Decrypt the sync metadata using DPAPI
    $decryptedPassdata = [System.Security.Cryptography.ProtectedData]::Unprotect($encryptedPassdata, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)

    # Convert the decrypted data from bytes to a string
    # $decryptedPassString = [System.Text.Encoding]::UTF8.GetString($decryptedPassdata)
    return $decryptedPassdata
    
}

function Get-DecryptPassword {
    param (
        [byte[]]$AesKey,
        [byte[]]$password
    )
    try {
        $iv = $password[3..15]
        $password =  $password[15..$password.Count]


        $aesGcm = [System.Security.Cryptography.AesGcm]::new()

        # Decrypt the message
        $decryptedMessageBytes = New-Object byte[] $password.Length
        $aesGcm.Decrypt($key, $iv, $password, $null, $null, [ref]$decryptedMessageBytes)

        # Convert decrypted bytes to string
        $decryptedMessage = [System.Text.Encoding]::UTF8.GetString($decryptedMessageBytes)

        # Output the decrypted message
        Write-Output $decryptedMessage


    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Error "Error decrypting password: $_"
        return $null
    }
}

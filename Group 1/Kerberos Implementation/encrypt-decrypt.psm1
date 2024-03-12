function xorEncDec {
    param (
        [string]$cleartext,
        [string]$password
    )

    $ciphertext = @()

    for ($i = 0; $i -lt $cleartext.Length; $i++) {
        $encryptedChar = $cleartext[$i] -bxor $password[$i % $password.Length]
        $rot13Char = [char]([byte]$encryptedChar -bxor 13)
        $ciphertext += $rot13Char
    }

    return -join $ciphertext
}
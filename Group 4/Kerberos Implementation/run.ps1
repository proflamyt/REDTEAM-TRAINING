# Run Sqlservice.ps1
Write-Host "Running Sqlservice.ps1..."
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -NoExit -File Sqlservice.ps1"

# Run Domain.ps1
Write-Host "Running Domain.ps1..."
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -NoExit -File Domain.ps1"

# Run User.ps1
Write-Host "Running User.ps1..."
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -NoExit -File User.ps1"

Write-Host "All scripts started successfully."

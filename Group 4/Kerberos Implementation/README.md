# Kerberos Authentication Simulation for SQL Service

This repository contains PowerShell scripts to simulate Kerberos authentication for an SQL service. Kerberos authentication is a widely used protocol for network authentication, particularly in Windows environments.

## Description

The scripts provided in this repository are designed to run in a specific order to simulate the Kerberos authentication process for an SQL service. The scripts are:

1. **Sqlservice.ps1**: Simulates the SQL service.
2. **Domain.ps1**: Simulates the domain environment.
3. **User.ps1**: Simulates the user authentication.
4. **Utils.ps1**: Contains utilities necessary for the scripts

These scripts should be executed in the following order for an efficient simulation:

1. Sqlservice
2. Domain
3. User

## Getting Started

To run the simulation, follow these steps:

1. Clone this repository to your local machine.
2. Open a PowerShell terminal.
3. Navigate to the directory where the scripts are located.
4. Run the `run.ps1` script using the following command:
   
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File run.ps1

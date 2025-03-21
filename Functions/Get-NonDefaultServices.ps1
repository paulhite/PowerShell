<#
.SYNOPSIS
Enumerates services on multiple Windows computers from a CSV file and identifies services using accounts other than "Local System", "Local Service", or "Network Service".

.DESCRIPTION
This script accepts input and output file paths as parameters. It connects to the computers listed in the input CSV file, enumerates their services, 
and filters services that don't use the default system accounts. The results are saved to an output CSV file and displayed in the console.

.PARAMETER InputCsv
Path to the input CSV file with a "name" column containing the list of computers.

.PARAMETER OutputCsv
Path to the output CSV file where results will be saved.

.NOTES
Requires administrative privileges on the target computers and remote management capabilities (WMI).
The input CSV should be properly formatted with a "name" column.

.EXAMPLE
Get-NonDefaultServices -InputCsv "computers.csv" -OutputCsv "NonDefaultServices.csv"

.NOTES
    Author: Paul Hite (AI Assisted)
    Date: January 3, 2025
#>

function Get-NonDefaultServices {
    param (
        [string]$InputCsv,  # Input file path for the list of computers
        [string]$OutputCsv  # Output file path for the results
    )

    # Initialize an empty array to store results
    $results = @()

    # Import the CSV file and get the list of computers
    $computers = Import-Csv -Path $InputCsv

    foreach ($computer in $computers) {
        $computerName = $computer.name

        Write-Host "Connecting to $computerName..."
        
        # Check if the computer is reachable
        if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
            Write-Host "Connected to $computerName."
            Write-Host "Enumerating services running under non-default accounts on $computerName..."

            # Get the services remotely
            try {
                $services = Get-WmiObject -Class Win32_Service -ComputerName $computerName -ErrorAction Stop

                # Filter services not running as "Local System", "Local Service", or "Network Service"
                $nonDefaultAccounts = $services | Where-Object {
                    $_.StartName -notlike "*LocalSystem" -and
                    $_.StartName -notlike "*LocalService" -and
                    $_.StartName -notlike "*NetworkService" -and
                    $_.StartName -notlike "*NETWORK SERVICE" -and
                    $_.StartName -notlike "*LOCAL SERVICE" -and
                    $_.StartName -notlike "*System" -and
                    $_.StartName -ne $null
                }

                # Collect results and output to console
                foreach ($service in $nonDefaultAccounts) {
                    $result = [PSCustomObject]@{
                        Computer    = $computerName
                        ServiceName = $service.Name
                        DisplayName = $service.DisplayName
                        StartName   = $service.StartName
                    }

                    $results += $result # Add the result to the array
                    Write-Output "Computer: $($result.Computer), Service: $($result.ServiceName), Display Name: $($result.DisplayName), Start Name: $($result.StartName)"
                }
            } catch {
                Write-Host "Error: Unable to enumerate services on $computerName. $_"
            }
        } else {
            Write-Host "Error: Unable to reach $computerName."
        }
    }

    # Export the results to the specified output CSV file
    if ($results.Count -gt 0) {
        $results | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
        Write-Host "Results have been exported to $OutputCsv."
    } else {
        Write-Host "No services with non-default accounts were found on the listed computers."
    }

    Write-Host "Function execution complete."
}

# Example usage:
# Get-NonDefaultServices -InputCsv "computers.csv" -OutputCsv "NonDefaultServices.csv"
<#
.SYNOPSIS
    Generates a passphrase using random words from a word list.

.DESCRIPTION
    This function generates a passphrase by selecting a specified number of random words from a word list.
    It allows options to add a random number, capitalize the first letter of each word, and specify a delimiter.
    The word list should be a tab-delimited file with each line containing a six-digit number and a word.

.PARAMETER FilePath
    The path to the word list file. If not specified, retrieves the word list from the EFF website.

.PARAMETER WordCount
    The number of words to include in the passphrase. Default is 3.

.PARAMETER AddNumber
    Switch to add a random number to one of the words in the passphrase.

.PARAMETER AddCapital
    Switch to capitalize the first letter of each word in the passphrase.

.PARAMETER Delimiter
    The delimiter to use between words in the passphrase. Default is '-'.

.EXAMPLE
    Get-Passphrase -WordCount 4 -AddNumber -AddCapital -Delimiter '.'

.NOTES
    Author: Paul Hite (AI Assisted)
    Date: January 3, 2025
#>

function Get-Passphrase {
    param (
        [string]$FilePath,
        [int]$WordCount = 3,
        [switch]$AddNumber,
        [switch]$AddCapital,
        [string]$Delimiter = '-'
    )

    # Retrieve the word list from the EFF website if FilePath is not specified
    if (-not $FilePath) {
        $FilePath = "$env:TEMP\eff_large_wordlist.txt"
        if (-not (Test-Path -Path $FilePath)) {
            Invoke-WebRequest -Uri 'https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt' -OutFile $FilePath
        }
    }

    # Function to get a random word based on a random number
    function Get-RandomWord {
        param (
            [int]$RandomNumber,
            [string]$FilePath
        )
        $pattern = "^$RandomNumber\t"
        $line = Select-String -Path $FilePath -Pattern $pattern | Select-Object -First 1
        if ($line) {
            return ($line -split "`t")[1]
        } else {
            return $null
        }
    }

    # Function to generate a random five-digit number with each digit between 1 and 6
    function Get-DiceRoll {
        return (1..5 | ForEach-Object { Get-Random -Minimum 1 -Maximum 6 }) -join ''
    }

    # Generate the specified number of random five-digit numbers
    $DiceRolls = 1..$WordCount | ForEach-Object { Get-DiceRoll }

    # Get the corresponding words
    $SelectedWords = $DiceRolls | ForEach-Object { Get-RandomWord -RandomNumber $_ -FilePath $FilePath }

    # Check if Delimiter is empty and set it to '-' if it is
    if ([string]::IsNullOrEmpty($Delimiter)) {
        $Delimiter = '-'
    }

    # Create the passphrase
    $Passphrase = $SelectedWords -join $Delimiter

    # Add a random number to a random word if specified
    if ($AddNumber) {
        $RandomIndex = Get-Random -Minimum 0 -Maximum ($SelectedWords.Count - 1)
        $RandomNumber = Get-Random -Minimum 0 -Maximum 9
        $SelectedWords[$RandomIndex] += $RandomNumber
        $Passphrase = $SelectedWords -join $Delimiter
    }

    # Capitalize the first letter of each word if specified
    if ($AddCapital) {
        $SelectedWords = $SelectedWords | ForEach-Object { $_.Substring(0, 1).ToUpper() + $_.Substring(1) }
        $Passphrase = $SelectedWords -join $Delimiter
    }

    return $Passphrase
}
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a small collection of reusable PowerShell utility functions. There is no build system, test runner, or dependency manager — each `.ps1` file in `Functions/` is a standalone function that can be dot-sourced or copied into any PowerShell session.

## Loading Functions

Dot-source a function to load it into the current session:

```powershell
. .\Functions\Get-RandomPassphrase.ps1
. .\Functions\Get-NonDefaultServices.ps1
```

Get built-in help for any function:

```powershell
Get-Help Get-Passphrase -Full
Get-Help Get-NonDefaultServices -Full
```

## Function Conventions

- Each `.ps1` file in `Functions/` defines exactly one function using comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.NOTES`).
- Author attribution goes in the `.NOTES` block as `Author: <name>`.
- Warning/error messages to the console use `Write-Host` with `-ForegroundColor Yellow`.
- Output objects use `[PSCustomObject]` with named properties rather than raw hashtables or formatted strings.
- `Export-Csv` calls always include `-NoTypeInformation -Encoding UTF8`.

## Runtime Dependencies

- **`Get-RandomPassphrase`**: Downloads the EFF large wordlist from `https://www.eff.org/files/2016/07/18/eff_large_wordlist.txt` to `$env:TEMP` on first run if no `-FilePath` is provided. Subsequent calls reuse the cached file.
- **`Get-NonDefaultServices`**: Requires WMI access (`Get-WmiObject`) and administrative privileges on each target computer. The input CSV must have a `name` column containing hostnames.

## License

GNU General Public License v3.

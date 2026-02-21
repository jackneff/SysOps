<#
.SYNOPSIS
    Finds locked out user accounts in Active Directory.

.EXAMPLE
    .\Get-ADLockedAccounts.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

$LockedUsers = Search-ADAccount -LockedOut -UsersOnly -ErrorAction Stop

$Results = $LockedUsers | Select-Object Name, SamAccountName, DistinguishedName, LastLogonDate, LockedOut, PasswordExpired

Write-Host "Locked Accounts: $($Results.Count)" -ForegroundColor Yellow
$Results | Format-Table -AutoSize

return $Results

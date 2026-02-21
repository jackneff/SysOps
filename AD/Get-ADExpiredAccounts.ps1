<#
.SYNOPSIS
    Finds expired user accounts in Active Directory.

.PARAMETER DaysUntilExpiration
    Find accounts expiring within specified days.

.EXAMPLE
    .\Get-ADExpiredAccounts.ps1

.EXAMPLE
    .\Get-ADExpiredAccounts.ps1 -DaysUntilExpiration 30
#>

[CmdletBinding()]
param(
    [int]$DaysUntilExpiration = 0
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

if ($DaysUntilExpiration -gt 0) {
    $ExpirationDate = (Get-Date).AddDays($DaysUntilExpiration)
    $ExpiredUsers = Search-ADAccount -AccountExpiring -WithinDays $DaysUntilExpiration -UsersOnly -ErrorAction Stop
}
else {
    $ExpiredUsers = Search-ADAccount -AccountExpired -UsersOnly -ErrorAction Stop
}

$Results = $ExpiredUsers | Select-Object Name, SamAccountName, DistinguishedName, AccountExpirationDate, Enabled

Write-Host "Expired Accounts: $($Results.Count)" -ForegroundColor Yellow
$Results | Format-Table -AutoSize

return $Results

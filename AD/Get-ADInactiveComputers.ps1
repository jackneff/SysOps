<#
.SYNOPSIS
    Finds inactive computer accounts.

.PARAMETER InactiveDays
    Number of days of inactivity (default: 90).

.EXAMPLE
    .\Get-ADInactiveComputers.ps1 -InactiveDays 90
#>

[CmdletBinding()]
param(
    [int]$InactiveDays = 90
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

$InactiveComputers = Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan "$InactiveDays.00:00:00" -ErrorAction Stop

$Results = $InactiveComputers | Select-Object Name, DNSHostName, OperatingSystem, LastLogonDate, DistinguishedName

Write-Host "Inactive Computers (>$InactiveDays days): $($Results.Count)" -ForegroundColor Yellow
$Results | Format-Table -AutoSize

return $Results

<#
.SYNOPSIS
    Gets disk space report with threshold alerts.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER ThresholdPercent
    Alert threshold percentage (default: 80).

.EXAMPLE
    .\Get-DiskSpaceThresholdReport.ps1 -ThresholdPercent 80
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$ComputerName,
    [int]$ThresholdPercent = 80
)

$ErrorActionPreference = "Stop"

$AllResults = & "$PSScriptRoot\Get-DiskSpace.ps1" -ComputerName $ComputerName

$Alerts = $AllResults | Where-Object { $_.PercentUsed -ge $ThresholdPercent }

Write-Host "=== All Drives ===" -ForegroundColor Cyan
$AllResults | Format-Table -AutoSize

if ($Alerts) {
    Write-Host "`n=== Drives Above Threshold ($ThresholdPercent%) ===" -ForegroundColor Red
    $Alerts | Format-Table -AutoSize
}

return @{
    AllDrives = $AllResults
    Alerts = $Alerts
}

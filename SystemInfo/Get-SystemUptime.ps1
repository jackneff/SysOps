<#
.SYNOPSIS
    Gets system uptime.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-SystemUptime.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
}
else {
    $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
}

$LastBootTime = $OS.LastBootUpTime
$Uptime = (Get-Date) - $LastBootTime

$Result = [PSCustomObject]@{
    ComputerName   = $ComputerName
    LastBootTime   = $LastBootTime
    UptimeDays    = $Uptime.Days
    UptimeHours   = $Uptime.Hours
    UptimeMinutes = $Uptime.Minutes
    UptimeString  = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
}

Write-Host "=== System Uptime: $ComputerName ===" -ForegroundColor Cyan
$result | Format-List

return $Result

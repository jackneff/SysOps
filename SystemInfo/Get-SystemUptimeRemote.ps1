<#
.SYNOPSIS
    Gets uptime from multiple remote servers.

.PARAMETER ComputerName
    Target server(s).

.EXAMPLE
    .\Get-SystemUptimeRemote.ps1 -ComputerName "Server01","Server02"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$ComputerName
)

$ErrorActionPreference = "Stop"

$Results = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking: $Computer" -ForegroundColor Cyan
    
    try {
        $OS = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $Computer -OperationTimeoutSec 10 -ErrorAction Stop
        
        $LastBootTime = $OS.LastBootUpTime
        $Uptime = (Get-Date) - $LastBootTime
        
        $Results += [PSCustomObject]@{
            ComputerName  = $Computer
            LastBootTime  = $LastBootTime
            UptimeDays    = $Uptime.Days
            UptimeHours   = $Uptime.Hours
            UptimeMinutes = $Uptime.Minutes
            UptimeString  = "$($Uptime.Days)d $($Uptime.Hours)h $($Uptime.Minutes)m"
        }
    }
    catch {
        $Results += [PSCustomObject]@{
            ComputerName  = $Computer
            LastBootTime  = "N/A"
            UptimeDays    = 0
            UptimeHours   = 0
            UptimeMinutes = 0
            UptimeString  = "Error"
            Error         = $_.Exception.Message
        }
    }
}

Write-Host "`n=== System Uptime ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

<#
.SYNOPSIS
    Retrieves error and warning events from Windows Event Logs.

.DESCRIPTION
    Queries Windows Event Logs for errors and warnings within a specified time window.

.PARAMETER ComputerName
    Target computer name(s). Defaults to localhost.

.PARAMETER LogName
    Event log name (Application, System, Security).

.PARAMETER Hours
    Number of hours to look back. Default: 24.

.PARAMETER MaxEvents
    Maximum number of events to retrieve.

.EXAMPLE
    .\Get-EventLogErrors.ps1 -LogName System -Hours 12

.EXAMPLE
    .\Get-EventLogErrors.ps1 -ComputerName "Server01" -LogName Application -MaxEvents 50
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [string]$LogName = "Application",
    
    [int]$Hours = 24,
    
    [int]$MaxEvents = 100
)

$ErrorActionPreference = "Stop"

$StartTime = (Get-Date).AddHours(-$Hours)

$AllEvents = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Querying $LogName log on $Computer..." -ForegroundColor Cyan
    
    try {
        $Events = Get-WinEvent -ComputerName $Computer -FilterHashtable @{
            LogName   = $LogName
            Level     = 1, 2, 3
            StartTime = $StartTime
        } -MaxEvents $MaxEvents -ErrorAction Stop
        
        foreach ($Event in $Events) {
            $AllEvents += [PSCustomObject]@{
                ComputerName   = $Computer
                TimeCreated   = $Event.TimeCreated
                Id            = $Event.Id
                Level         = $Event.LevelDisplayName
                Source        = $Event.ProviderName
                Message       = ($Event.Message -split "`n")[0]
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

Write-Host "`n=== Event Log Errors and Warnings ===" -ForegroundColor Cyan
$AllEvents | Format-Table -AutoSize

return $AllEvents

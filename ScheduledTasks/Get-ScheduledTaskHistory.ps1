<#
.SYNOPSIS
    Gets scheduled task history/results.

.PARAMETER TaskName
    Name of the task.

.PARAMETER TaskPath
    Path to task.

.PARAMETER MaxEvents
    Number of events to retrieve.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-ScheduledTaskHistory.ps1 -TaskName "DailyBackup" -MaxEvents 10
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [string]$TaskPath = "\",
    [int]$MaxEvents = 10,
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$TaskFullName = "$TaskPath$TaskName"

if ($TaskPath -ne "\") {
    $TaskFullName = "$TaskPath$TaskName"
}
else {
    $TaskFullName = $TaskName
}

$FilterHashtable = @{
    LogName   = 'Microsoft-Windows-TaskScheduler/Operational'
    Id        = 102, 103, 107, 110, 111, 112, 117, 118, 119, 200, 201
    TaskName  = $TaskName
}

if ($ComputerName -ne "localhost" -and $ComputerName -ne $env:COMPUTERNAME) {
    $FilterHashtable.ComputerName = $ComputerName
}

$Events = Get-WinEvent -FilterHashtable $FilterHashtable -MaxEvents $MaxEvents -ErrorAction SilentlyContinue

$Results = @()
foreach ($Event in $Events) {
    $Results += [PSCustomObject]@{
        TimeCreated = $Event.TimeCreated
        Id          = $Event.Id
        Message     = ($Event.Message -split "`n")[0]
        UserId      = $Event.UserId
    }
}

Write-Host "=== Task History: $TaskName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

<#
.SYNOPSIS
    Enables a scheduled task.

.PARAMETER TaskName
    Name of the task.

.PARAMETER TaskPath
    Path to task.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Enable-ScheduledTask.ps1 -TaskName "DailyBackup"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [string]$TaskPath = "\",
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$Params = @{
    TaskName = $TaskName
    TaskPath = $TaskPath
}

if ($ComputerName -ne "localhost" -and $ComputerName -ne $env:COMPUTERNAME) {
    $Params.ComputerName = $ComputerName
}

Enable-ScheduledTask @Params -ErrorAction Stop

Write-Host "Task '$TaskName' enabled successfully" -ForegroundColor Green

$Task = Get-ScheduledTask @Params
return $Task

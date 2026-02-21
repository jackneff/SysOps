<#
.SYNOPSIS
    Removes a scheduled task.

.PARAMETER TaskName
    Name of the task to remove.

.PARAMETER TaskPath
    Path to task.

.PARAMETER ComputerName
    Target server.

.PARAMETER Confirm
    Confirm deletion.

.EXAMPLE
    .\Remove-ScheduledTask.ps1 -TaskName "OldTask"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [string]$TaskPath = "\",
    [string]$ComputerName = "localhost",
    [switch]$Confirm
)

$ErrorActionPreference = "Stop"

$Params = @{
    TaskName = $TaskName
    TaskPath = $TaskPath
    Confirm  = $false
}

if ($ComputerName -ne "localhost" -and $ComputerName -ne $env:COMPUTERNAME) {
    $Params.ComputerName = $ComputerName
}

if (-not $Confirm) {
    $Response = Read-Host "Are you sure you want to delete task '$TaskName'? (Y/N)"
    if ($Response -ne "Y" -and $Response -ne "y") {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        exit 0
    }
}

Unregister-ScheduledTask @Params -ErrorAction Stop

Write-Host "Task '$TaskName' removed successfully" -ForegroundColor Green

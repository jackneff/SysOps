<#
.SYNOPSIS
    Lists scheduled tasks.

.PARAMETER ComputerName
    Target server.

.PARAMETER TaskName
    Specific task name (wildcard).

.PARAMETER Folder
    Task folder path.

.EXAMPLE
    .\Get-ScheduledTask.ps1 -TaskName "Daily*"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [string]$TaskName = "*",
    [string]$Folder = "\"
)

$ErrorActionPreference = "Stop"

$Params = @{
    TaskName = $TaskName
}

if ($ComputerName -ne "localhost" -and $ComputerName -ne $env:COMPUTERNAME) {
    $Params.ComputerName = $ComputerName
}

if ($Folder -ne "\") {
    $Params.TaskPath = $Folder
}

$Tasks = Get-ScheduledTask @Params -ErrorAction SilentlyContinue

$Results = @()
foreach ($Task in $Tasks) {
    $Info = Get-ScheduledTaskInfo -TaskName $Task.TaskName -TaskPath $Task.TaskPath -ErrorAction SilentlyContinue
    
    $Results += [PSCustomObject]@{
        TaskName      = $Task.TaskName
        TaskPath      = $Task.TaskPath
        State         = $Task.State
        Description   = $Task.Description
        LastRunTime   = if ($Info) { $Info.LastRunTime } else { "N/A" }
        LastResult    = if ($Info) { $Info.LastTaskResult } else { "N/A" }
        NextRunTime   = if ($Info) { $Info.NextRunTime } else { "N/A" }
    }
}

Write-Host "=== Scheduled Tasks on $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

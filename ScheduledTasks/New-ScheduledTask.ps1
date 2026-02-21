<#
.SYNOPSIS
    Creates a new scheduled task.

.PARAMETER TaskName
    Name of the task.

.PARAMETER TaskPath
    Path to create task in.

.PARAMETER Description
    Task description.

.PARAMETER Action
    Action to execute (script path or command).

.PARAMETER TriggerType
    Trigger type: Daily, Weekly, AtStartup, AtLogOn.

.PARAMETER TriggerValue
    Trigger value (time for Daily/Weekly, interval for AtStartup/AtLogOn).

.PARAMETER RunAsUser
    User to run task as.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\New-ScheduledTask.ps1 -TaskName "DailyBackup" -Action "C:\Scripts\Backup.ps1" -TriggerType Daily -TriggerValue "03:00"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$TaskName,
    [string]$TaskPath = "\",
    [string]$Description = "",
    [Parameter(Mandatory = $true)]
    [string]$Action,
    [ValidateSet("Daily", "Weekly", "AtStartup", "AtLogOn")]
    [string]$TriggerType = "Daily",
    [string]$TriggerValue = "09:00",
    [string]$RunAsUser = "SYSTEM",
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ActionObj = New-ScheduledTaskAction -Execute $Action

switch ($TriggerType) {
    "Daily" {
        $Trigger = New-ScheduledTaskTrigger -Daily -At $TriggerValue
    }
    "Weekly" {
        $Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At $TriggerValue
    }
    "AtStartup" {
        $Trigger = New-ScheduledTaskTrigger -AtStartup
    }
    "AtLogOn" {
        $Trigger = New-ScheduledTaskTrigger -AtLogOn
    }
}

if ($RunAsUser -eq "SYSTEM") {
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
}
else {
    $Settings = New-ScheduledTaskSettingsSet
}

$Principal = New-ScheduledTaskPrincipal -UserId $RunAsUser -LogonType ServiceAccount -RunLevel Highest

$Params = @{
    TaskName    = $TaskName
    TaskPath    = $TaskPath
    Action      = $ActionObj
    Trigger     = $Trigger
    Settings   = $Settings
    Principal   = $Principal
    Description = $Description
}

if ($ComputerName -ne "localhost" -and $ComputerName -ne $env:COMPUTERNAME) {
    $Params.ComputerName = $ComputerName
}

Register-ScheduledTask @Params -ErrorAction Stop

Write-Host "Task '$TaskName' created successfully" -ForegroundColor Green

$Task = Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath
if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    return $Task
}
else {
    return Get-ScheduledTask -TaskName $TaskName -TaskPath $TaskPath -ComputerName $ComputerName
}

# Scheduled Tasks Examples

This folder contains scripts for managing Windows scheduled tasks.

## Get-ScheduledTask.ps1

List scheduled tasks.

```powershell
# Get all tasks
.\Get-ScheduledTask.ps1

# Get specific task
.\Get-ScheduledTask.ps1 -TaskName "DailyBackup"

# Get tasks in folder
.\Get-ScheduledTask.ps1 -Folder "\MyTasks\"

# Get from remote computer
.\Get-ScheduledTask.ps1 -ComputerName "Server01"
```

**Example Output:**
```
=== Scheduled Tasks on localhost ===
TaskName        TaskPath      State    LastRunTime           LastResult
--------        ---------     -----    ------------          ----------
DailyBackup     \             Ready    2024-01-15 03:00:00  0
HourlySync      \             Running  2024-01-15 10:30:00  0
```

## New-ScheduledTask.ps1

Create a new scheduled task.

```powershell
# Daily task at 3 AM
.\New-ScheduledTask.ps1 -TaskName "DailyBackup" -Action "C:\Scripts\Backup.ps1" -TriggerType Daily -TriggerValue "03:00"

# Weekly task
.\New-ScheduledTask.ps1 -TaskName "WeeklyReport" -Action "C:\Scripts\Report.ps1" -TriggerType Weekly -TriggerValue "09:00"

# Run at startup
.\New-ScheduledTask.ps1 -TaskName "StartService" -Action "net start MyService" -TriggerType AtStartup

# Run at logon
.\New-ScheduledTask.ps1 -TaskName "LogonScript" -Action "C:\Scripts\logon.ps1" -TriggerType AtLogOn -RunAsUser "DOMAIN\ServiceAccount"
```

**Example Output:**
Task 'DailyBackup' created successfully

## Remove-ScheduledTask.ps1

Delete a scheduled task.

```powershell
.\Remove-ScheduledTask.ps1 -TaskName "OldTask"

# With confirmation
.\Remove-ScheduledTask.ps1 -TaskName "OldTask" -Confirm

# From remote computer
.\Remove-ScheduledTask.ps1 -ComputerName "Server01" -TaskName "OldTask"
```

## Enable-ScheduledTask.ps1

Enable a disabled task.

```powershell
.\Enable-ScheduledTask.ps1 -TaskName "DailyBackup"
```

**Example Output:**
Task 'DailyBackup' enabled successfully

## Disable-ScheduledTask.ps1

Disable a task.

```powershell
.\Disable-ScheduledTask.ps1 -TaskName "DailyBackup"
```

**Example Output:**
Task 'DailyBackup' disabled successfully

## Get-ScheduledTaskHistory.ps1

View task run history.

```powershell
# Get history for a task
.\Get-ScheduledTaskHistory.ps1 -TaskName "DailyBackup"

# Get more events
.\Get-ScheduledTaskHistory.ps1 -TaskName "DailyBackup" -MaxEvents 20

# From remote computer
.\Get-ScheduledTaskHistory.ps1 -ComputerName "Server01" -TaskName "DailyBackup"
```

**Example Output:**
```
=== Task History: DailyBackup ===
TimeCreated           Id Message
-----------           -- -------
2024-01-15 03:00:01 102 Task started
2024-01-15 03:00:02 201 Task completed successfully
2024-01-14 03:00:01 102 Task started
2024-01-14 03:00:02 201 Task completed successfully
```

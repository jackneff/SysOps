<#
.SYNOPSIS
    Lists existing SQL Server backups.

.DESCRIPTION
    Retrieves backup history for a database or all databases.

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Database name (optional - lists all if not specified).

.PARAMETER BackupPath
    Filter by specific backup file path.

.PARAMETER Days
    Number of days to look back (default: 30).

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Get-DatabaseBackups.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    
    [string]$DatabaseName = "",
    
    [string]$BackupPath = "",
    
    [int]$Days = 30,
    
    [switch]$UseIntegratedSecurity,
    [string]$Username = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

if ($UseIntegratedSecurity) {
    $ConnectionString = "Server=$ServerName;Database=master;Integrated Security=True;"
}
else {
    $ConnectionString = "Server=$ServerName;Database=master;User Id=$Username;Password=$Password;"
}

$Query = @"
SELECT 
    bs.database_name AS DatabaseName,
    bs.backup_start_date AS BackupStartDate,
    bs.backup_finish_date AS BackupFinishDate,
    bf.physical_device_name AS BackupFilePath,
    bs.backup_size / 1024 / 1024 AS BackupSizeMB,
    bs.type AS BackupType,
    bs.recovery_model AS RecoveryModel,
    bs.server_name AS ServerName,
    bs.is_damaged AS IsDamaged,
    bs.is_copy_only AS IsCopyOnly
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bf ON bs.media_set_id = bf.media_set_id
WHERE bs.backup_start_date >= DATEADD(day, -$Days, GETDATE())
"@

if ($DatabaseName) {
    $Query += " AND bs.database_name = '$DatabaseName'"
}

if ($BackupPath) {
    $Query += " AND bf.physical_device_name LIKE '%$BackupPath%'"
}

$Query += " ORDER BY bs.backup_start_date DESC"

try {
    $Results = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    $Results = $Results | Select-Object *, @{
        Name       = "BackupTypeDescription"
        Expression = {
            switch ($_.BackupType) {
                "D" { "Full" }
                "I" { "Differential" }
                "L" { "Log" }
                "F" { "File" }
                "G" { "Filegroup" }
                default { $_.BackupType }
            }
        }
    }
    
    Write-Host "=== Database Backups ===" -ForegroundColor Cyan
    $Results | Format-Table -AutoSize
    
    return $Results
}
catch {
    Write-Error "Failed to retrieve backup history: $($_.Exception.Message)"
    exit 1
}

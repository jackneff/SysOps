<#
.SYNOPSIS
    Restores a SQL Server database from backup.

.DESCRIPTION
    Restores a database from a backup file.

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Target database name.

.PARAMETER BackupFilePath
    Path to backup file.

.PARAMETER RestoreType
    Full, Differential, or Log.

.PARAMETER TargetPath
    Target path for database files (optional).

.PARAMETER WithRecovery
    Leave database in recovering log state (for restores).

.PARAMETER Replace
    Replace existing database.

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Restore-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -BackupFilePath "C:\Backups\MyDB_Full_20240101.bak"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    
    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,
    
    [Parameter(Mandatory = $true)]
    [string]$BackupFilePath,
    
    [ValidateSet("Full", "Differential", "Log")]
    [string]$RestoreType = "Full",
    
    [string]$TargetPath = "",
    
    [switch]$WithRecovery,
    
    [switch]$Replace,
    
    [switch]$UseIntegratedSecurity,
    [string]$Username = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $BackupFilePath)) {
    Write-Error "Backup file not found: $BackupFilePath"
    exit 1
}

if ($UseIntegratedSecurity) {
    $ConnectionString = "Server=$ServerName;Database=master;Integrated Security=True;"
}
else {
    $ConnectionString = "Server=$ServerName;Database=master;User Id=$Username;Password=$Password;"
}

$RestoreOption = if ($Replace) { "REPLACE" } else { "NORECOVERY" }
$RecoveryOption = if ($WithRecovery) { "RECOVERY" } else { "NORECOVERY" }

if ($RestoreType -eq "Log" -or $RestoreType -eq "Differential") {
    $RestoreOption = "NORECOVERY"
}

$Query = switch ($RestoreType) {
    "Full" {
        if ($TargetPath) {
            "RESTORE DATABASE [$DatabaseName] FROM DISK = N'$BackupFilePath' WITH $RestoreOption, $RecoveryOption, MOVE N'$DatabaseName' TO N'$TargetPath\$DatabaseName.mdf', MOVE N'$DatabaseName`_log' TO N'$TargetPath\$DatabaseName`_log.ldf'"
        }
        else {
            "RESTORE DATABASE [$DatabaseName] FROM DISK = N'$BackupFilePath' WITH $RestoreOption, $RecoveryOption"
        }
    }
    "Differential" {
        "RESTORE DATABASE [$DatabaseName] FROM DISK = N'$BackupFilePath' WITH $RestoreOption, $RecoveryOption"
    }
    "Log" {
        "RESTORE LOG [$DatabaseName] FROM DISK = N'$BackupFilePath' WITH $RestoreOption, $RecoveryOption"
    }
}

Write-Host "Starting $RestoreType restore of '$DatabaseName'" -ForegroundColor Cyan
Write-Host "Backup file: $BackupFilePath" -ForegroundColor Cyan
Write-Host "This may take a few minutes..." -ForegroundColor Yellow

try {
    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    Write-Host "Restore completed successfully!" -ForegroundColor Green
    
    $VerifyQuery = "SELECT name, state_desc, recovery_model_desc FROM sys.databases WHERE name = '$DatabaseName'"
    $DbInfo = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $VerifyQuery -ErrorAction Stop
    
    $Result = [PSCustomObject]@{
        ServerName      = $ServerName
        DatabaseName    = $DatabaseName
        RestoreType     = $RestoreType
        BackupFilePath  = $BackupFilePath
        State           = $DbInfo.state_desc
        RecoveryModel  = $DbInfo.recovery_model_desc
        Timestamp       = Get-Date
        Success         = $true
    }
    
    Write-Host "`nDatabase Status:" -ForegroundColor Green
    $Result | Format-List
    
    return $Result
}
catch {
    Write-Error "Restore failed: $($_.Exception.Message)"
    exit 1
}

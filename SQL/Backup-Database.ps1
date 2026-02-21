<#
.SYNOPSIS
    Backs up a SQL Server database.

.DESCRIPTION
    Creates a full backup of a SQL Server database.

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Database name to backup.

.PARAMETER BackupPath
    Path to store backup file.

.PARAMETER BackupType
    Full, Differential, or Log.

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Backup-Database.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -BackupPath "C:\Backups"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    
    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,
    
    [Parameter(Mandatory = $true)]
    [string]$BackupPath,
    
    [ValidateSet("Full", "Differential", "Log")]
    [string]$BackupType = "Full",
    
    [switch]$UseIntegratedSecurity,
    [string]$Username = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$BackupFileName = "$DatabaseName`_$BackupType`_$Timestamp.bak"
$BackupFileFullPath = Join-Path -Path $BackupPath -ChildPath $BackupFileName

if ($UseIntegratedSecurity) {
    $ConnectionString = "Server=$ServerName;Database=master;Integrated Security=True;"
}
else {
    $ConnectionString = "Server=$ServerName;Database=master;User Id=$Username;Password=$Password;"
}

$BackupQuery = switch ($BackupType) {
    "Full" {
        "BACKUP DATABASE [$DatabaseName] TO DISK = N'$BackupFileFullPath' WITH NOFORMAT, NOINIT, NAME = N'$DatabaseName-$BackupType Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
    }
    "Differential" {
        "BACKUP DATABASE [$DatabaseName] TO DISK = N'$BackupFileFullPath' WITH DIFFERENTIAL, NOFORMAT, NOINIT, NAME = N'$DatabaseName-$BackupType Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
    }
    "Log" {
        "BACKUP LOG [$DatabaseName] TO DISK = N'$BackupFileFullPath' WITH NOFORMAT, NOINIT, NAME = N'$DatabaseName-$BackupType Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
    }
}

Write-Host "Starting $BackupType backup of '$DatabaseName' to $BackupFileFullPath" -ForegroundColor Cyan

try {
    Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $BackupQuery -ErrorAction Stop
    
    if (Test-Path -Path $BackupFileFullPath) {
        $BackupFile = Get-Item -Path $BackupFileFullPath
        $BackupSizeMB = [math]::Round($BackupFile.Length / 1MB, 2)
        
        Write-Host "Backup completed successfully!" -ForegroundColor Green
        Write-Host "Backup file: $BackupFileFullPath" -ForegroundColor Green
        Write-Host "Backup size: $BackupSizeMB MB" -ForegroundColor Green
        
        $Result = [PSCustomObject]@{
            ServerName    = $ServerName
            DatabaseName = $DatabaseName
            BackupType   = $BackupType
            BackupPath   = $BackupFileFullPath
            BackupSizeMB = $BackupSizeMB
            Timestamp    = Get-Date
            Success      = $true
        }
        
        return $Result
    }
}
catch {
    Write-Error "Backup failed: $($_.Exception.Message)"
    exit 1
}

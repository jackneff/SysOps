<#
.SYNOPSIS
    Lists active SQL connections (similar to sp_who2).

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Database name (optional - filters by database).

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Get-ActiveConnections.ps1 -ServerName "SQLServer01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$DatabaseName = "",
    [switch]$UseIntegratedSecurity,
    [string]$Username = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

if ($UseIntegratedSecurity) {
    $ConnectionString = "Server=$ServerName;Integrated Security=True;"
}
else {
    $ConnectionString = "Server=$ServerName;User Id=$Username;Password=$Password;"
}

$Query = @"
SELECT 
    s.session_id AS SPID,
    s.login_name AS LoginName,
    s.host_name AS HostName,
    s.program_name AS ProgramName,
    s.status AS Status,
    s.cpu_time AS CPUTime,
    s.memory_usage AS MemoryUsage,
    s.reads AS Reads,
    s.writes AS Writes,
    s.last_request_start_time AS LastStartTime,
    s.last_request_end_time AS LastEndTime,
    db.name AS DatabaseName
FROM sys.dm_exec_sessions s
LEFT JOIN sys.databases db ON s.database_id = db.database_id
WHERE s.session_id > 50
"@

if ($DatabaseName) {
    $Query += " AND db.name = '$DatabaseName'"
}

$Query += " ORDER BY s.cpu_time DESC"

try {
    $Data = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    Write-Host "=== Active Connections on $ServerName ===" -ForegroundColor Cyan
    $Data | Format-Table -AutoSize
    
    return $Data
}
catch {
    Write-Error "Failed to get active connections: $($_.Exception.Message)"
    exit 1
}

<#
.SYNOPSIS
    Lists blocked SQL processes (similar to sp_lock).

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Get-BlockedThreads.ps1 -ServerName "SQLServer01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
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
    blocked.session_id AS BlockedSPID,
    blocked.status AS BlockedStatus,
    blocked.login_name AS BlockedLogin,
    blocked.host_name AS BlockedHost,
    blocked.program_name AS BlockedProgram,
    blocked.last_batch AS BlockedLastBatch,
    blocked_req.session_id AS BlockingSPID,
    blocked_req.status AS BlockingStatus,
    blocked_req.login_name AS BlockingLogin,
    blocked_req.host_name AS BlockingHost,
    blocked_req.program_name AS BlockingProgram,
    blocked_req.last_batch AS BlockingLastBatch,
    wait.resource_description AS WaitResource
FROM sys.dm_exec_requests blocked
JOIN sys.dm_exec_requests blocked_req ON blocked.blocking_session_id = blocked_req.session_id
LEFT JOIN sys.dm_os_waiting_tasks wait ON blocked.session_id = wait.session_id
WHERE blocked.session_id > 50
ORDER BY blocked.blocking_session_id
"@

try {
    $Data = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    if ($Data) {
        Write-Host "=== Blocked Processes on $ServerName ===" -ForegroundColor Red
        $Data | Format-Table -AutoSize
    }
    else {
        Write-Host "No blocked processes found" -ForegroundColor Green
    }
    
    return $Data
}
catch {
    Write-Error "Failed to get blocked threads: $($_.Exception.Message)"
    exit 1
}

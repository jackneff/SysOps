<#
.SYNOPSIS
    Gets database schema (tables, views, stored procedures).

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Database name.

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username (if not using integrated security).

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Get-DatabaseSchema.ps1 -ServerName "SQLServer01" -DatabaseName "MyDatabase"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,
    [switch]$UseIntegratedSecurity,
    [string]$Username = "",
    [string]$Password = ""
)

$ErrorActionPreference = "Stop"

if ($UseIntegratedSecurity) {
    $ConnectionString = "Server=$ServerName;Database=$DatabaseName;Integrated Security=True;"
}
else {
    $ConnectionString = "Server=$ServerName;Database=$DatabaseName;User Id=$Username;Password=$Password;"
}

$Query = @"
SELECT 
    TABLE_TYPE,
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_TYPE, TABLE_NAME
"@

try {
    $Data = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    Write-Host "=== Database Schema: $DatabaseName ===" -ForegroundColor Cyan
    $Data | Format-Table -AutoSize
    
    return $Data
}
catch {
    Write-Error "Failed to connect to SQL Server: $($_.Exception.Message)"
    exit 1
}

<#
.SYNOPSIS
    Executes a SELECT query and returns results.

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Database name.

.PARAMETER Query
    SQL query to execute.

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Get-SQLData.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -Query "SELECT TOP 10 * FROM Customers"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$Query,
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

try {
    $Data = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    Write-Host "=== Query Results ===" -ForegroundColor Cyan
    $Data | Format-Table -AutoSize
    
    return $Data
}
catch {
    Write-Error "Failed to execute query: $($_.Exception.Message)"
    exit 1
}

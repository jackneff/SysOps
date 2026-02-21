<#
.SYNOPSIS
    Gets table schema (columns, data types, constraints).

.PARAMETER ServerName
    SQL Server instance.

.PARAMETER DatabaseName
    Database name.

.PARAMETER TableName
    Table name.

.PARAMETER UseIntegratedSecurity
    Use Windows Authentication.

.PARAMETER Username
    SQL username.

.PARAMETER Password
    SQL password.

.EXAMPLE
    .\Get-TableSchema.ps1 -ServerName "SQLServer01" -DatabaseName "MyDB" -TableName "Customers"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [Parameter(Mandatory = $true)]
    [string]$DatabaseName,
    [Parameter(Mandatory = $true)]
    [string]$TableName,
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
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    c.ORDINAL_POSITION,
    CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 'YES' ELSE 'NO' END AS IS_PRIMARY_KEY
FROM INFORMATION_SCHEMA.COLUMNS c
LEFT JOIN (
    SELECT ku.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
    WHERE tc.TABLE_NAME = '$TableName' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
) pk ON c.COLUMN_NAME = pk.COLUMN_NAME
WHERE c.TABLE_NAME = '$TableName'
ORDER BY c.ORDINAL_POSITION
"@

try {
    $Data = Invoke-Sqlcmd -ConnectionString $ConnectionString -Query $Query -ErrorAction Stop
    
    Write-Host "=== Table Schema: $TableName ===" -ForegroundColor Cyan
    $Data | Format-Table -AutoSize
    
    return $Data
}
catch {
    Write-Error "Failed to get table schema: $($_.Exception.Message)"
    exit 1
}

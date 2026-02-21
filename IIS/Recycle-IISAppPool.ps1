<#
.SYNOPSIS
    Recycles an IIS application pool.

.PARAMETER ComputerName
    Target server.

.PARAMETER AppPoolName
    Application pool name to recycle.

.EXAMPLE
    .\Recycle-IISAppPool.ps1 -AppPoolName "DefaultAppPool"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [Parameter(Mandatory = $true)]
    [string]$AppPoolName
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($AppPoolName)
    
    Import-Module WebAdministration -ErrorAction Stop
    
    Restart-WebAppPool -Name $AppPoolName -ErrorAction Stop
    
    $Pool = Get-WebAppPoolState -Name $AppPoolName -ErrorAction Stop
    
    [PSCustomObject]@{
        AppPoolName = $AppPoolName
        State       = $Pool.Value
        Success     = $true
    }
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Result = & $ScriptBlock $AppPoolName
}
else {
    $Result = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $AppPoolName
}

Write-Host "Application pool '$AppPoolName' recycled. State: $($Result.State)" -ForegroundColor Green

return $Result

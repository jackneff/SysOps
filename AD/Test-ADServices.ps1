<#
.SYNOPSIS
    Tests critical AD services on domain controllers.

.PARAMETER ComputerName
    Domain controller(s) to check.

.PARAMETER UseConfig
    Use domain controllers from config.

.EXAMPLE
    .\Test-ADServices.ps1 -UseConfig
#>

[CmdletBinding()]
param(
    [string[]]$ComputerName = @(),
    [switch]$UseConfig
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

$CriticalServices = @("NTDS", "DNS", "NetLogon", "W32Time", "DFS Replication", "Kerberos Key Distribution Center")

if ($UseConfig) {
    $Config = Get-Config
    $ComputerName = $Config.DomainControllers
}

if ($ComputerName.Count -eq 0) {
    $ComputerName = (Get-ADDomainController -Filter *).HostName
}

$Results = @()

foreach ($DC in $ComputerName) {
    Write-Host "Checking AD services on: $DC" -ForegroundColor Cyan
    
    foreach ($ServiceName in $CriticalServices) {
        $ServiceResult = Get-RemoteService -ComputerName $DC -ServiceName $ServiceName
        
        $Results += [PSCustomObject]@{
            ComputerName   = $DC
            ServiceName   = $ServiceResult.ServiceName
            DisplayName   = $ServiceResult.DisplayName
            Status        = $ServiceResult.Status
            IsHealthy     = ($ServiceResult.Status -eq "Running")
        }
    }
}

Write-Host "`n=== AD Service Status ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

$Stopped = $Results | Where-Object { -not $_.IsHealthy }
if ($Stopped) {
    Write-Host "`n=== Stopped Services ===" -ForegroundColor Red
    $Stopped | Format-Table -AutoSize
}

return $Results

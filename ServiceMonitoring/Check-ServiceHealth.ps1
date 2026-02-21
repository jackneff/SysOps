<#
.SYNOPSIS
    Monitors service health across multiple servers.

.DESCRIPTION
    Checks the status of critical services across multiple servers and generates
    an alert report for any services that are not running.

.PARAMETER ComputerName
    The target computer name(s).

.PARAMETER ServiceNames
    Array of service names to check.

.PARAMETER UseConfig
    Use services defined in settings.json config file.

.PARAMETER AlertOnStopped
    Generate alert output for stopped services.

.EXAMPLE
    .\Check-ServiceHealth.ps1 -UseConfig

.EXAMPLE
    .\Check-ServiceHealth.ps1 -ComputerName "Server01","Server02" -ServiceNames "W3SVC","MSSQLSERVER" -AlertOnStopped
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @(),
    
    [Parameter(Mandatory = $false)]
    [string[]]$ServiceNames = @(),
    
    [switch]$UseConfig,
    
    [switch]$AlertOnStopped
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

if ($UseConfig) {
    $Config = Get-Config
    
    if ($ComputerName.Count -eq 0) {
        $ComputerName = $Config.Servers
    }
    
    if ($ServiceNames.Count -eq 0) {
        $ServiceNames = $Config.CriticalServices
    }
}

$AllResults = @()
$Alerts = @()

foreach ($Computer in $ComputerName) {
    Write-Verbose "Checking services on computer: $Computer"
    
    $Reachability = Test-ServerReachability -ComputerName $Computer
    
    if (-not $Reachability.Reachable) {
        $Alerts += [PSCustomObject]@{
            ComputerName = $Computer
            AlertType    = "Unreachable"
            Message      = "Computer is not reachable"
            Details      = $Reachability.Error
        }
        continue
    }
    
    foreach ($ServiceName in $ServiceNames) {
        $ServiceResult = Get-RemoteService -ComputerName $Computer -ServiceName $ServiceName
        
        $AllResults += [PSCustomObject]@{
            ComputerName = $Computer
            ServiceName  = $ServiceResult.ServiceName
            DisplayName  = $ServiceResult.DisplayName
            Status       = $ServiceResult.Status
            StartType    = $ServiceResult.StartType
            IsHealthy    = ($ServiceResult.Status -eq "Running")
        }
        
        if ($ServiceResult.Status -ne "Running" -and $AlertOnStopped) {
            $Alerts += [PSCustomObject]@{
                ComputerName = $Computer
                AlertType    = "ServiceStopped"
                ServiceName  = $ServiceName
                Message      = "Service '$ServiceName' is not running"
                CurrentState = $ServiceResult.Status
            }
        }
    }
}

Write-Host "`n=== Service Health Check Results ===" -ForegroundColor Cyan
$AllResults | Format-Table -AutoSize

if ($Alerts.Count -gt 0) {
    Write-Host "`n=== Alerts ===" -ForegroundColor Red
    $Alerts | Format-Table -AutoSize
}

$Summary = [PSCustomObject]@{
    TotalChecks       = $AllResults.Count
    HealthyServices   = @($AllResults | Where-Object { $_.IsHealthy }).Count
    UnhealthyServices = @($AllResults | Where-Object { -not $_.IsHealthy }).Count
    Alerts            = $Alerts.Count
    Timestamp         = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

Write-Host "`n=== Summary ===" -ForegroundColor Green
$Summary | Format-List

return @{
    Results = $AllResults
    Alerts  = $Alerts
    Summary = $Summary
}

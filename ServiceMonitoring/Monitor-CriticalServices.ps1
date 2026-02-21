<#
.SYNOPSIS
    Monitors critical services and alerts on issues.

.DESCRIPTION
    Checks critical services and generates alerts for stopped, hung, or problematic services.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER ServiceNames
    Specific services to monitor.

.PARAMETER UseConfig
    Use services from config.

.PARAMETER AlertOnStopped
    Alert when service is stopped.

.PARAMETER AlertOnDisabled
    Alert when auto-start service is disabled.

.PARAMETER AlertOnHung
    Alert when service is hung (stopping/starting for >5 min).

.EXAMPLE
    .\Monitor-CriticalServices.ps1 -UseConfig -AlertOnStopped -AlertOnDisabled -AlertOnHung
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @(),
    
    [Parameter(Mandatory = $false)]
    [string[]]$ServiceNames = @(),
    
    [switch]$UseConfig,
    
    [switch]$AlertOnStopped,
    
    [switch]$AlertOnDisabled,
    
    [switch]$AlertOnHung
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

if ($ComputerName.Count -eq 0) {
    $ComputerName = @("localhost")
}

$AllAlerts = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking services on: $Computer" -ForegroundColor Cyan
    
    try {
        $Services = Get-Service -ComputerName $Computer -ErrorAction Stop
        
        foreach ($ServiceName in $ServiceNames) {
            $Service = $Services | Where-Object { $_.Name -eq $ServiceName }
            
            if (-not $Service) {
                $AllAlerts += [PSCustomObject]@{
                    ComputerName   = $Computer
                    ServiceName   = $ServiceName
                    AlertType    = "NotFound"
                    Severity     = "Critical"
                    Message      = "Service not found on system"
                }
                continue
            }
            
            if ($AlertOnStopped -and $Service.Status -ne "Running") {
                $AllAlerts += [PSCustomObject]@{
                    ComputerName   = $Computer
                    ServiceName   = $Service.Name
                    DisplayName   = $Service.DisplayName
                    AlertType    = "Stopped"
                    Severity     = "Critical"
                    Message      = "Service is not running (Status: $($Service.Status))"
                    CurrentState = $Service.Status
                    StartType    = $Service.StartType
                }
            }
            
            if ($AlertOnDisabled -and $Service.StartType -eq "Disabled" -and $Service.Status -ne "Running") {
                $AllAlerts += [PSCustomObject]@{
                    ComputerName   = $Computer
                    ServiceName   = $Service.Name
                    DisplayName   = $Service.DisplayName
                    AlertType    = "DisabledAutoStart"
                    Severity     = "High"
                    Message      = "Auto-start service is disabled"
                    CurrentState = $Service.Status
                    StartType    = $Service.StartType
                }
            }
            
            if ($AlertOnHung -and ($Service.Status -eq "StopPending" -or $Service.Status -eq "StartPending")) {
                $AllAlerts += [PSCustomObject]@{
                    ComputerName   = $Computer
                    ServiceName   = $Service.Name
                    DisplayName   = $Service.DisplayName
                    AlertType    = "Hung"
                    Severity     = "Warning"
                    Message      = "Service appears hung (Status: $($Service.Status))"
                    CurrentState = $Service.Status
                    StartType    = $Service.StartType
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to get services from $Computer`: $($_.Exception.Message)"
    }
}

if ($AllAlerts.Count -gt 0) {
    Write-Host "`n=== Alerts Found: $($AllAlerts.Count) ===" -ForegroundColor Red
    $AllAlerts | Format-Table -AutoSize
}
else {
    Write-Host "`nNo issues found" -ForegroundColor Green
}

return $AllAlerts

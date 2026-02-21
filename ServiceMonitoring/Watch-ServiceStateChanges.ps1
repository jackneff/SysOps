<#
.SYNOPSIS
    Monitors for service state changes.

.DESCRIPTION
    Tracks service state changes and alerts on unexpected changes from baseline.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER ServiceNames
    Services to monitor.

.PARAMETER UseConfig
    Use services from config.

.PARAMETER StateFile
    Path to store previous state for comparison.

.EXAMPLE
    .\Watch-ServiceStateChanges.ps1 -UseConfig
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @(),
    
    [Parameter(Mandatory = $false)]
    [string[]]$ServiceNames = @(),
    
    [switch]$UseConfig,
    
    [string]$StateFile = ""
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

if ($StateFile -eq "") {
    $StateFile = "$PSScriptRoot\..\ServiceMonitoring\ServiceState.json"
}

$CurrentState = @{}
$Changes = @()

foreach ($Computer in $ComputerName) {
    try {
        $Services = Get-Service -ComputerName $Computer -ErrorAction Stop
        
        foreach ($ServiceName in $ServiceNames) {
            $Service = $Services | Where-Object { $_.Name -eq $ServiceName }
            
            if ($Service) {
                $Key = "$Computer|$ServiceName"
                $CurrentState[$Key] = @{
                    ComputerName = $Computer
                    ServiceName = $Service.Name
                    DisplayName = $Service.DisplayName
                    Status     = $Service.Status.ToString()
                    StartType  = $Service.StartType.ToString()
                    Timestamp  = Get-Date -Format "o"
                }
                
                if (Test-Path $StateFile) {
                    $PreviousState = Get-Content $StateFile -Raw | ConvertFrom-Json
                    $Previous = $PreviousState.$Key
                    
                    if ($Previous) {
                        if ($Previous.Status -ne $Service.Status.ToString()) {
                            $Changes += [PSCustomObject]@{
                                ComputerName   = $Computer
                                ServiceName   = $Service.Name
                                DisplayName   = $Service.DisplayName
                                Property      = "Status"
                                PreviousValue = $Previous.Status
                                CurrentValue  = $Service.Status.ToString()
                                Timestamp     = Get-Date
                            }
                        }
                        
                        if ($Previous.StartType -ne $Service.StartType.ToString()) {
                            $Changes += [PSCustomObject]@{
                                ComputerName   = $Computer
                                ServiceName   = $Service.Name
                                DisplayName   = $Service.DisplayName
                                Property      = "StartType"
                                PreviousValue = $Previous.StartType
                                CurrentValue  = $Service.StartType.ToString()
                                Timestamp     = Get-Date
                            }
                        }
                    }
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

$CurrentState | ConvertTo-Json | Out-File -FilePath $StateFile -Encoding UTF8

if ($Changes.Count -gt 0) {
    Write-Host "`n=== Service State Changes Detected ===" -ForegroundColor Red
    $Changes | Format-Table -AutoSize
}
else {
    Write-Host "`nNo state changes detected" -ForegroundColor Green
}

return $Changes

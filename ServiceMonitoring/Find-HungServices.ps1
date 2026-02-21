<#
.SYNOPSIS
    Finds hung services (stuck in starting/stopping state).

.DESCRIPTION
    Identifies services that are stuck in Starting or Stopping state.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER ThresholdMinutes
    Consider service hung if in transition state for more than X minutes (default: 5).

.EXAMPLE
    .\Find-HungServices.ps1 -ComputerName "Server01" -ThresholdMinutes 5
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [int]$ThresholdMinutes = 5
)

$ErrorActionPreference = "Stop"

$AllResults = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking: $Computer" -ForegroundColor Cyan
    
    try {
        $Services = Get-Service -ComputerName $Computer -ErrorAction Stop
        
        $HungServices = $Services | Where-Object { 
            $_.Status -eq "StopPending" -or $_.Status -eq "StartPending"
        }
        
        if ($HungServices.Count -gt 0) {
            $WmiServiceParams = @{
                Class = "Win32_Service"
                ComputerName = $Computer
            }
            
            $WmiServices = Get-WmiObject @WmiServiceParams -ErrorAction SilentlyContinue
            
            foreach ($Service in $HungServices) {
                $WmiService = $WmiServices | Where-Object { $_.Name -eq $Service.Name }
                
                $StartTime = $WmiService.Started
                $WaitTime = if ($StartTime) { 
                    (Get-Date) - $StartTime 
                } else { 
                    New-TimeSpan -Minutes 0 
                }
                
                $IsHung = $WaitTime.TotalMinutes -gt $ThresholdMinutes
                
                $AllResults += [PSCustomObject]@{
                    ComputerName     = $Computer
                    ServiceName      = $Service.Name
                    DisplayName      = $Service.DisplayName
                    CurrentState    = $Service.Status
                    StartType       = $Service.StartType
                    WaitTimeMinutes = [math]::Round($WaitTime.TotalMinutes, 1)
                    IsHung          = $IsHung
                    ProcessId       = $WmiService.ProcessId
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

Write-Host "`n=== Hung Services ===" -ForegroundColor Yellow

if ($AllResults.Count -gt 0) {
    $AllResults | Format-Table -AutoSize
    
    $CriticalHung = $AllResults | Where-Object { $_.IsHung }
    if ($CriticalHung.Count -gt 0) {
        Write-Host "`nHung services (>$ThresholdMinutes min): $($CriticalHung.Count)" -ForegroundColor Red
    }
}
else {
    Write-Host "No hung services found" -ForegroundColor Green
}

return $AllResults

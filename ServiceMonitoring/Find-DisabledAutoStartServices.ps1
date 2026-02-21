<#
.SYNOPSIS
    Finds auto-start services that are currently disabled.

.DESCRIPTION
    Identifies services configured to start automatically but are currently disabled.

.PARAMETER ComputerName
    Target server(s).

.EXAMPLE
    .\Find-DisabledAutoStartServices.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost")
)

$ErrorActionPreference = "Stop"

$AllResults = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking: $Computer" -ForegroundColor Cyan
    
    try {
        $Services = Get-Service -ComputerName $Computer -ErrorAction Stop
        
        $DisabledAutoStart = $Services | Where-Object { 
            $_.StartType -eq "Disabled" -and $_.Status -ne "Running"
        }
        
        foreach ($Service in $DisabledAutoStart) {
            $AllResults += [PSCustomObject]@{
                ComputerName = $Computer
                ServiceName = $Service.Name
                DisplayName = $Service.DisplayName
                Status      = $Service.Status
                StartType  = $Service.StartType
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

Write-Host "`n=== Disabled Auto-Start Services ===" -ForegroundColor Yellow

if ($AllResults.Count -gt 0) {
    $AllResults | Format-Table -AutoSize
    Write-Host "Found $($AllResults.Count) disabled auto-start services" -ForegroundColor Red
}
else {
    Write-Host "No disabled auto-start services found" -ForegroundColor Green
}

return $AllResults

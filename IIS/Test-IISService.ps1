<#
.SYNOPSIS
    Tests IIS W3SVC service status.

.PARAMETER ComputerName
    Target server(s).

.EXAMPLE
    .\Test-IISService.ps1 -ComputerName "WebServer01"
#>

[CmdletBinding()]
param(
    [string[]]$ComputerName = @("localhost")
)

$ErrorActionPreference = "Stop"

$Results = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking IIS service on: $Computer" -ForegroundColor Cyan
    
    $ServiceResult = Get-RemoteService -ComputerName $Computer -ServiceName "W3SVC"
    
    $Results += [PSCustomObject]@{
        ComputerName = $Computer
        ServiceName  = $ServiceResult.ServiceName
        DisplayName  = $ServiceResult.DisplayName
        Status       = $ServiceResult.Status
        IsHealthy    = ($ServiceResult.Status -eq "Running")
    }
}

$Results | Format-Table -AutoSize
return $Results

<#
.SYNOPSIS
    Tests multiple web applications from config.

.DESCRIPTION
    Reads websites from config and tests each one, outputting a summary report.

.PARAMETER UseConfig
    Use websites defined in settings.json config file.

.PARAMETER Url
    Specific URL to test (overrides config).

.EXAMPLE
    .\Test-WebApplicationBatch.ps1 -UseConfig
#>

[CmdletBinding()]
param(
    [switch]$UseConfig,
    [string]$Url = ""
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

$Websites = @()

if ($UseConfig) {
    $Config = Get-Config
    $Websites = $Config.Websites
}
elseif ($Url) {
    $Websites = @(@{Name = "Custom"; Url = $Url})
}
else {
    Write-Error "Please specify -UseConfig or provide a -Url"
    exit 1
}

$Results = @()

foreach ($Website in $Websites) {
    Write-Host "Testing: $($Website.Url)" -ForegroundColor Cyan
    
    $TestResult = & "$PSScriptRoot\Test-WebApplication.ps1" -Url $Website.Url -IgnoreSSL
    
    $Results += [PSCustomObject]@{
        Name           = $Website.Name
        Url            = $Website.Url
        StatusCode     = $TestResult.StatusCode
        ResponseTimeMs = $TestResult.ResponseTimeMs
        IsHealthy      = $TestResult.IsHealthy
        Timestamp      = $TestResult.Timestamp
    }
}

Write-Host "`n=== Web Application Health Summary ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

$Unhealthy = $Results | Where-Object { -not $_.IsHealthy }
if ($Unhealthy) {
    Write-Host "`n=== Unhealthy Sites ===" -ForegroundColor Red
    $Unhealthy | Format-Table -AutoSize
}

return $Results

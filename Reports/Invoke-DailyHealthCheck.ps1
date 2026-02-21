<#
.SYNOPSIS
    Master script for daily health check.

.DESCRIPTION
    Combines all health checks into a single HTML report with optional email.

.PARAMETER UseConfig
    Use settings from config file.

.PARAMETER SendEmail
    Send report via email.

.PARAMETER OutputPath
    Path to save HTML report.

.EXAMPLE
    .\Invoke-DailyHealthCheck.ps1 -UseConfig -SendEmail
#>

[CmdletBinding()]
param(
    [switch]$UseConfig,
    [switch]$SendEmail,
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Continue"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

if ($UseConfig) {
    $Config = Get-Config
    $Servers = $Config.Servers
}
else {
    $Servers = @("localhost")
}

if (-not $OutputPath) {
    $OutputPath = "$PSScriptRoot\..\Reports\DailyHealthCheck-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
}

$ReportDir = Split-Path $OutputPath -Parent
if (-not (Test-Path $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

Write-Host "Generating Daily Health Check Report..." -ForegroundColor Cyan
Write-Host "Servers: $($Servers -join ', ')" -ForegroundColor Cyan

$HtmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Daily Health Check Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #333; border-bottom: 2px solid #007acc; padding-bottom: 10px; }
        h2 { color: #007acc; margin-top: 30px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; background-color: white; }
        th { background-color: #007acc; color: white; padding: 10px; text-align: left; }
        td { padding: 8px; border: 1px solid #ddd; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .healthy { color: green; font-weight: bold; }
        .unhealthy { color: red; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        .timestamp { color: #666; font-size: 12px; }
        .summary { background-color: #e8f4e8; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>Daily Health Check Report</h1>
    <p class="timestamp">Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
"@

$ServiceResults = & "$PSScriptRoot\..\ServiceMonitoring\Check-ServiceHealth.ps1" -ComputerName $Servers -UseConfig -ErrorAction SilentlyContinue

$HtmlReport += "<h2>Service Status</h2><table><tr><th>Server</th><th>Service</th><th>Status</th></tr>"
foreach ($Svc in $ServiceResults.Results) {
    $StatusClass = if ($Svc.IsHealthy) { "healthy" } else { "unhealthy" }
    $HtmlReport += "<tr><td>$($Svc.ComputerName)</td><td>$($Svc.ServiceName)</td><td class='$StatusClass'>$($Svc.Status)</td></tr>"
}
$HtmlReport += "</table>"

$DiskResults = & "$PSScriptRoot\..\DiskSpace\Get-DiskSpace.ps1" -ComputerName $Servers -ErrorAction SilentlyContinue

$HtmlReport += "<h2>Disk Space</h2><table><tr><th>Server</th><th>Drive</th><th>Used GB</th><th>Free GB</th><th>% Used</th></tr>"
foreach ($Disk in $DiskResults) {
    $PercentClass = if ($Disk.PercentUsed -ge 90) { "unhealthy" } elseif ($Disk.PercentUsed -ge 80) { "warning" } else { "healthy" }
    $HtmlReport += "<tr><td>$($Disk.ComputerName)</td><td>$($Disk.Drive)</td><td>$($Disk.UsedGB)</td><td>$($Disk.FreeGB)</td><td class='$PercentClass'>$($Disk.PercentUsed)%</td></tr>"
}
$HtmlReport += "</table>"

$UptimeResults = @()
foreach ($Server in $Servers) {
    $UptimeResults += & "$PSScriptRoot\..\SystemInfo\Get-SystemUptime.ps1" -ComputerName $Server -ErrorAction SilentlyContinue
}

$HtmlReport += "<h2>System Uptime</h2><table><tr><th>Server</th><th>Last Boot</th><th>Uptime</th></tr>"
foreach ($Uptime in $UptimeResults) {
    $HtmlReport += "<tr><td>$($Uptime.ComputerName)</td><td>$($Uptime.LastBootTime)</td><td>$($Uptime.UptimeString)</td></tr>"
}
$HtmlReport += "</table>"

$WebResults = @()
if ($UseConfig -and $Config.Websites) {
    $WebResults = & "$PSScriptRoot\..\WebMonitoring\Test-WebApplicationBatch.ps1" -UseConfig -ErrorAction SilentlyContinue
}

if ($WebResults) {
    $HtmlReport += "<h2>Web Application Status</h2><table><tr><th>Name</th><th>URL</th><th>Status</th><th>Response Time</th></tr>"
    foreach ($Web in $WebResults) {
        $StatusClass = if ($Web.IsHealthy) { "healthy" } else { "unhealthy" }
        $HtmlReport += "<tr><td>$($Web.Name)</td><td>$($Web.Url)</td><td class='$StatusClass'>$($Web.StatusCode)</td><td>$($Web.ResponseTimeMs)ms</td></tr>"
    }
    $HtmlReport += "</table>"
}

$Summary = $ServiceResults.Summary
$HtmlReport += @"
    <h2>Summary</h2>
    <div class="summary">
        <p>Total Service Checks: $($Summary.TotalChecks)</p>
        <p class="healthy">Healthy Services: $($Summary.HealthyServices)</p>
        <p class="unhealthy">Unhealthy Services: $($Summary.Unhealthy)</p>
        <p>Alerts: $($Summary.Alerts)</p>
    </div>
</body>
</html>
"@

$HtmlReport | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "`nReport saved to: $OutputPath" -ForegroundColor Green

if ($SendEmail -and $UseConfig) {
    $EmailBody = $HtmlReport
    
    Send-EmailReport -Subject "Daily Health Check Report - $(Get-Date -Format 'yyyy-MM-dd')" `
        -Body $EmailBody `
        -SmtpServer $Config.SmtpServer `
        -From $Config.FromEmail `
        -To $Config.ToEmail
}

return $OutputPath

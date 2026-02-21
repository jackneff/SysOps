<#
.SYNOPSIS
    Compares current server state against baseline.

.PARAMETER ComputerName
    Target server.

.PARAMETER BaselineFile
    Path to baseline JSON file.

.PARAMETER BaselinePath
    Path to baselines folder (will use latest if not specified).

.EXAMPLE
    .\Compare-Baseline.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [string]$BaselineFile = "",
    [string]$BaselinePath = ""
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

if (-not $BaselinePath) {
    $Config = Get-Config
    $BaselinePath = $Config.BaselinePath
}

if (-not $BaselinePath) {
    $BaselinePath = "$PSScriptRoot\..\Baselines"
}

if (-not $BaselineFile) {
    $Files = Get-ChildItem -Path $BaselinePath -Filter "$ComputerName*.json" | Sort-Object LastWriteTime -Descending
    
    if ($Files.Count -eq 0) {
        Write-Error "No baseline found for $ComputerName"
        exit 1
    }
    
    $BaselineFile = $Files[0].FullName
}

Write-Host "Loading baseline: $BaselineFile" -ForegroundColor Cyan

$Baseline = Get-Content $BaselineFile -Raw | ConvertFrom-Json

Write-Host "Recording current state..." -ForegroundColor Cyan

$Current = @{
    ComputerName = $ComputerName
    Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Services     = @()
    Ports        = @()
    DiskSpace    = @()
    Uptime       = $null
    Certificates = @()
    IIS          = @()
}

$Current.Services = & "$PSScriptRoot\..\ServiceMonitoring\Check-ServiceStatus.ps1" -ComputerName $ComputerName -UseConfig -ErrorAction SilentlyContinue

$ScriptBlock = {
    $Connections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
    foreach ($Conn in $Connections) {
        $Process = Get-Process -Id $Conn.OwningProcess -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Port        = $Conn.LocalPort
            Protocol    = "TCP"
            ProcessName = if ($Process) { $Process.ProcessName } else { "Unknown" }
            ProcessId   = $Conn.OwningProcess
        }
    }
}
if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Current.Ports = & $ScriptBlock
}
else {
    $Current.Ports = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

$Current.DiskSpace = & "$PSScriptRoot\..\DiskSpace\Get-DiskSpace.ps1" -ComputerName $ComputerName -ErrorAction SilentlyContinue
$Current.Uptime = & "$PSScriptRoot\..\SystemInfo\Get-SystemUptime.ps1" -ComputerName $ComputerName -ErrorAction SilentlyContinue

$ScriptBlock = {
    $CertStore = Get-ChildItem -Path Cert:\LocalMachine\My -ErrorAction SilentlyContinue
    foreach ($Cert in $CertStore) {
        [PSCustomObject]@{
            Subject        = $Cert.Subject
            Thumbprint     = $Cert.Thumbprint
            NotAfter       = $Cert.NotAfter.ToString("yyyy-MM-dd")
            DaysUntilExpiry = ($Cert.NotAfter - (Get-Date)).Days
        }
    }
}
if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Current.Certificates = & $ScriptBlock
}
else {
    $Current.Certificates = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

Write-Host "`n=== Comparing Current State vs Baseline ===" -ForegroundColor Cyan
Write-Host "Baseline: $($Baseline.Timestamp)" -ForegroundColor Yellow
Write-Host "Current:  $($Current.Timestamp)" -ForegroundColor Yellow

$Changes = @()

Write-Host "`n--- Service Changes ---" -ForegroundColor Cyan
foreach ($Svc in $Baseline.Services) {
    $CurrentSvc = $Current.Services | Where-Object { $_.ServiceName -eq $Svc.ServiceName }
    if ($CurrentSvc) {
        if ($CurrentSvc.Status -ne $Svc.Status) {
            $Changes += [PSCustomObject]@{
                Category   = "Service"
                Item       = $Svc.ServiceName
                Baseline   = $Svc.Status
                Current    = $CurrentSvc.Status
            }
            Write-Host "  $($Svc.ServiceName): $($Svc.Status) -> $($CurrentSvc.Status)" -ForegroundColor Yellow
        }
    }
}

$BaselinePorts = $Baseline.Ports | Select-Object -ExpandProperty Port
$CurrentPorts = $Current.Ports | Select-Object -ExpandProperty Port

$NewPorts = $CurrentPorts | Where-Object { $BaselinePorts -notContains $_ }
$RemovedPorts = $BaselinePorts | Where-Object { $CurrentPorts -notContains $_ }

if ($NewPorts) {
    Write-Host "`n--- New Ports ---" -ForegroundColor Cyan
    foreach ($Port in $NewPorts) {
        $Process = ($Current.Ports | Where-Object { $_.Port -eq $Port }).ProcessName
        $Changes += [PSCustomObject]@{
            Category = "Port"
            Item     = $Port
            Baseline = "N/A"
            Current  = "Open ($Process)"
        }
        Write-Host "  New Port: $Port ($Process)" -ForegroundColor Yellow
    }
}

if ($RemovedPorts) {
    Write-Host "`n--- Removed Ports ---" -ForegroundColor Cyan
    foreach ($Port in $RemovedPorts) {
        $Process = ($Baseline.Ports | Where-Object { $_.Port -eq $Port }).ProcessName
        $Changes += [PSCustomObject]@{
            Category = "Port"
            Item     = $Port
            Baseline = "Open ($Process)"
            Current  = "N/A"
        }
        Write-Host "  Removed Port: $Port ($Process)" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Comparison Complete ===" -ForegroundColor Green

return $Changes

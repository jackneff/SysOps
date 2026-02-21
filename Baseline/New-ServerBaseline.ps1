<#
.SYNOPSIS
    Records a baseline snapshot of a server.

.DESCRIPTION
    Captures a comprehensive baseline of server state including services,
    ports, IIS, disk space, uptime, and certificates.

.PARAMETER ComputerName
    Target server.

.PARAMETER OutputPath
    Path to save baseline file.

.PARAMETER UseConfig
    Use baseline path from config.

.EXAMPLE
    .\New-ServerBaseline.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [string]$OutputPath = "",
    [switch]$UseConfig
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

if ($UseConfig) {
    $Config = Get-Config
    $OutputPath = $Config.BaselinePath
}

if (-not $OutputPath) {
    $OutputPath = "$PSScriptRoot\..\Baselines"
}

if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

Write-Host "Recording baseline for: $ComputerName" -ForegroundColor Cyan

$Baseline = @{
    ComputerName = $ComputerName
    Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Services     = @()
    Ports        = @()
    DiskSpace    = @()
    Uptime       = $null
    Certificates = @()
    IIS          = @()
}

Write-Host "  - Checking services..." -ForegroundColor Yellow
$Baseline.Services = & "$PSScriptRoot\..\ServiceMonitoring\Check-ServiceStatus.ps1" -ComputerName $ComputerName -UseConfig -ErrorAction SilentlyContinue

Write-Host "  - Checking ports..." -ForegroundColor Yellow
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
    $Baseline.Ports = & $ScriptBlock
}
else {
    $Baseline.Ports = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

Write-Host "  - Checking disk space..." -ForegroundColor Yellow
$Baseline.DiskSpace = & "$PSScriptRoot\..\DiskSpace\Get-DiskSpace.ps1" -ComputerName $ComputerName -ErrorAction SilentlyContinue

Write-Host "  - Checking uptime..." -ForegroundColor Yellow
$Baseline.Uptime = & "$PSScriptRoot\..\SystemInfo\Get-SystemUptime.ps1" -ComputerName $ComputerName -ErrorAction SilentlyContinue

Write-Host "  - Checking certificates..." -ForegroundColor Yellow
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
    $Baseline.Certificates = & $ScriptBlock
}
else {
    $Baseline.Certificates = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

Write-Host "  - Checking IIS..." -ForegroundColor Yellow
$Baseline.IIS.Sites = & "$PSScriptRoot\..\IIS\Get-IISSiteStatus.ps1" -ComputerName $ComputerName -ErrorAction SilentlyContinue
$Baseline.IIS.AppPools = & "$PSScriptRoot\..\IIS\Get-IISAppPoolStatus.ps1" -ComputerName $ComputerName -ErrorAction SilentlyContinue

$FileName = "$OutputPath\$ComputerName-$((Get-Date).ToString('yyyyMMdd-HHmmss')).json"
$Baseline | ConvertTo-Json -Depth 10 | Out-File -FilePath $FileName -Encoding UTF8

Write-Host "`nBaseline saved to: $FileName" -ForegroundColor Green

return $FileName

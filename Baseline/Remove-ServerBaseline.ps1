<#
.SYNOPSIS
    Removes stored baseline files.

.PARAMETER ComputerName
    Filter by computer name.

.PARAMETER BaselinePath
    Path to baselines folder.

.PARAMETER Confirm
    Confirm deletion.

.EXAMPLE
    .\Remove-ServerBaseline.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "",
    [string]$BaselinePath = "",
    [switch]$Confirm
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

if (-not (Test-Path $BaselinePath)) {
    Write-Error "Baseline path not found: $BaselinePath"
    exit 1
}

$Files = Get-ChildItem -Path $BaselinePath -Filter "*.json"

if ($ComputerName) {
    $Files = $Files | Where-Object { $_.Name -like "$ComputerName*" }
}

if ($Files.Count -eq 0) {
    Write-Host "No baselines found" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($Files.Count) baseline(s):" -ForegroundColor Cyan
$Files | Select-Object Name, LastWriteTime | Format-Table -AutoSize

if (-not $Confirm) {
    $Response = Read-Host "Delete these $($Files.Count) baseline(s)? (Y/N)"
    if ($Response -ne "Y" -and $Response -ne "y") {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        exit 0
    }
}

foreach ($File in $Files) {
    Remove-Item -Path $File.FullName -Force
    Write-Host "Deleted: $($File.Name)" -ForegroundColor Green
}

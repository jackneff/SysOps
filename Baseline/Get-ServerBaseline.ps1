<#
.SYNOPSIS
    Retrieves stored baseline files.

.PARAMETER ComputerName
    Filter by computer name.

.PARAMETER BaselinePath
    Path to baselines folder.

.EXAMPLE
    .\Get-ServerBaseline.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "",
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

if (-not (Test-Path $BaselinePath)) {
    Write-Error "Baseline path not found: $BaselinePath"
    exit 1
}

$Files = Get-ChildItem -Path $BaselinePath -Filter "*.json"

if ($ComputerName) {
    $Files = $Files | Where-Object { $_.Name -like "$ComputerName*" }
}

$Results = @()
foreach ($File in $Files) {
    $Content = Get-Content $File.FullName -Raw | ConvertFrom-Json
    
    $Results += [PSCustomObject]@{
        ComputerName = $Content.ComputerName
        Timestamp    = $Content.Timestamp
        FilePath     = $File.FullName
        FileName     = $File.Name
    }
}

Write-Host "=== Available Baselines ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

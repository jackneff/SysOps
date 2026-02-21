<#
.SYNOPSIS
    Gets disk space information.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-DiskSpace.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string[]]$ComputerName = @("localhost")
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

$Results = @()

foreach ($Computer in $ComputerName) {
    if ($Computer -eq "localhost" -or $Computer -eq $env:COMPUTERNAME) {
        $Drives = Get-PSDrive -PSProvider FileSystem
    }
    else {
        $Drives = Invoke-Command -ComputerName $Computer -ScriptBlock { Get-PSDrive -PSProvider FileSystem }
    }
    
    foreach ($Drive in $Drives) {
        $UsedGB = [math]::Round($Drive.Used / 1GB, 2)
        $FreeGB = [math]::Round($Drive.Free / 1GB, 2)
        $TotalGB = $UsedGB + $FreeGB
        $PercentUsed = if ($TotalGB -gt 0) { [math]::Round(($UsedGB / $TotalGB) * 100, 1) } else { 0 }
        
        $Results += [PSCustomObject]@{
            ComputerName = $Computer
            Drive       = $Drive.Name
            UsedGB      = $UsedGB
            FreeGB      = $FreeGB
            TotalGB     = $TotalGB
            PercentUsed = $PercentUsed
        }
    }
}

Write-Host "=== Disk Space ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

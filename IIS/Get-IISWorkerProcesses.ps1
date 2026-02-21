<#
.SYNOPSIS
    Gets IIS worker processes (w3wp.exe).

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-IISWorkerProcesses.ps1 -ComputerName "WebServer01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    Import-Module WebAdministration -ErrorAction Stop
    
    $Processes = Get-Process -Name w3wp -ErrorAction SilentlyContinue
    
    $Results = @()
    foreach ($Process in $Processes) {
        $AppPoolName = ($Process.CommandLine -split "-ap ")[1]
        if ($AppPoolName) { $AppPoolName = $AppPoolName.Split(" ")[0] }
        
        $Results += [PSCustomObject]@{
            ProcessId      = $Process.Id
            AppPoolName    = $AppPoolName
            CPU            = $Process.CPU
            MemoryMB       = [math]::Round($Process.WorkingSet64 / 1MB, 2)
            StartTime      = $Process.StartTime
        }
    }
    $Results
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock
}
else {
    $Results = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

Write-Host "IIS Worker Processes on: $ComputerName" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

<#
.SYNOPSIS
    Finds process using a specific port.

.PARAMETER ComputerName
    Target server.

.PARAMETER Port
    Port number.

.EXAMPLE
    .\Get-ProcessOnPort.ps1 -Port 8080
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [Parameter(Mandatory = $true)]
    [int]$Port
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($Port)
    
    $Connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
    
    $Results = @()
    foreach ($Conn in $Connections) {
        $Process = Get-Process -Id $Conn.OwningProcess -ErrorAction SilentlyContinue
        
        $Results += [PSCustomObject]@{
            LocalAddress = $Conn.LocalAddress
            LocalPort    = $Conn.LocalPort
            State        = $Conn.State
            ProcessId    = $Conn.OwningProcess
            ProcessName  = if ($Process) { $Process.ProcessName } else { "Unknown" }
        }
    }
    $Results
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock $Port
}
else {
    $Results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $Port
}

Write-Host "=== Process on Port $Port ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

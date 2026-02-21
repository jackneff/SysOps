<#
.SYNOPSIS
    Lists all listening ports with associated processes.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-ListeningPorts.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    $Connections = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue
    
    $Results = @()
    foreach ($Conn in $Connections) {
        $Process = Get-Process -Id $Conn.OwningProcess -ErrorAction SilentlyContinue
        
        $Results += [PSCustomObject]@{
            LocalAddress = $Conn.LocalAddress
            LocalPort    = $Conn.LocalPort
            Protocol     = "TCP"
            ProcessId    = $Conn.OwningProcess
            ProcessName  = if ($Process) { $Process.ProcessName } else { "Unknown" }
        }
    }
    
    $UdpConnections = Get-NetUDPEndpoint -ErrorAction SilentlyContinue
    foreach ($Conn in $UdpConnections) {
        $Process = Get-Process -Id $Conn.OwningProcess -ErrorAction SilentlyContinue
        
        $Results += [PSCustomObject]@{
            LocalAddress = $Conn.LocalAddress
            LocalPort    = $Conn.LocalPort
            Protocol     = "UDP"
            ProcessId    = $Conn.OwningProcess
            ProcessName  = if ($Process) { $Process.ProcessName } else { "Unknown" }
        }
    }
    
    $Results | Sort-Object LocalPort
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock
}
else {
    $Results = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

Write-Host "=== Listening Ports on $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

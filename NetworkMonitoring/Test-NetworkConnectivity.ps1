<#
.SYNOPSIS
    Tests network connectivity (ping and port check).

.PARAMETER ComputerName
    Target server(s).

.PARAMETER TestPort
    Specific port to test.

.EXAMPLE
    .\Test-NetworkConnectivity.ps1 -ComputerName "Server01","Server02" -TestPort 443
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$ComputerName,
    [int]$TestPort = 0
)

$ErrorActionPreference = "Stop"

$Results = @()

foreach ($Computer in $ComputerName) {
    $PingResult = Test-Connection -ComputerName $Computer -Count 1 -ErrorAction SilentlyContinue
    
    $PingStatus = if ($PingResult) { $true } else { $false }
    $Latency = if ($PingResult) { $PingResult.Latency } else { $null }
    
    $PortStatus = $null
    if ($TestPort -gt 0) {
        try {
            $TcpClient = New-Object System.Net.Sockets.TcpClient
            $Connect = $TcpClient.BeginConnect($Computer, $TestPort, $null, $null)
            $Wait = $Connect.AsyncWaitHandle.WaitOne(2000, $false)
            
            $PortStatus = if ($Wait) { $true } else { $false }
            $TcpClient.Close()
        }
        catch {
            $PortStatus = $false
        }
    }
    
    $Results += [PSCustomObject]@{
        ComputerName = $Computer
        Pingable    = $PingStatus
        LatencyMs   = $Latency
        PortTested  = $TestPort
        PortOpen    = $PortStatus
    }
}

Write-Host "=== Network Connectivity ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

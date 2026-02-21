<#
.SYNOPSIS
    Checks if specific ports are listening.

.PARAMETER ComputerName
    Target server.

.PARAMETER Ports
    Port number(s) to check.

.EXAMPLE
    .\Get-PortStatus.ps1 -ComputerName "Server01" -Ports 80,443,1433
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [Parameter(Mandatory = $true)]
    [int[]]$Ports
)

$ErrorActionPreference = "Stop"

$Results = @()

foreach ($Port in $Ports) {
    try {
        $TcpClient = New-Object System.Net.Sockets.TcpClient
        $Connect = $TcpClient.BeginConnect($ComputerName, $Port, $null, $null)
        $Wait = $Connect.AsyncWaitHandle.WaitOne(2000, $false)
        
        if ($Wait) {
            $TcpClient.EndConnect($Connect)
            $IsListening = $true
            $TcpClient.Close()
        }
        else {
            $IsListening = $false
            $TcpClient.Close()
        }
    }
    catch {
        $IsListening = $false
    }
    
    $Results += [PSCustomObject]@{
        ComputerName = $ComputerName
        Port         = $Port
        IsListening  = $IsListening
        Service      = switch ($Port) { 
            80 {"HTTP"} 443 {"HTTPS"} 1433 {"MSSQL"} 3389 {"RDP"} 21 {"FTP"} 22 {"SSH"} 25 {"SMTP"} 53 {"DNS"} default {"Unknown"}
        }
    }
}

Write-Host "=== Port Status: $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

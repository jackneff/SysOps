<#
.SYNOPSIS
    Performs traceroute to target host.

.PARAMETER HostName
    Target hostname or IP.

.PARAMETER MaxHops
    Maximum number of hops (default: 30).

.EXAMPLE
    .\Test-Traceroute.ps1 -HostName "example.com"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [int]$MaxHops = 30
)

$ErrorActionPreference = "Stop"

$Results = @()
$HopNumber = 0

try {
    $Ping = New-Object System.Net.NetworkInformation.Ping
    
    for ($i = 1; $i -le $MaxHops; $i++) {
        $Options = New-Object System.Net.NetworkInformation.PingOptions($i, $true)
        $Buffer = New-Object byte[](32)
        
        $Reply = $Ping.Send($HostName, 1000, $Buffer, $Options)
        
        $HopNumber = $i
        
        if ($Reply.Status -eq "Success") {
            $Results += [PSCustomObject]@{
                HopNumber = $HopNumber
                Address   = $Reply.Address.ToString()
                Status    = $Reply.Status
                RoundTripTime = $Reply.RoundtripTime
            }
            break
        }
        elseif ($Reply.Status -eq "TtlExpired") {
            $Results += [PSCustomObject]@{
                HopNumber = $HopNumber
                Address   = $Reply.Address.ToString()
                Status    = $Reply.Status
                RoundTripTime = $Reply.RoundtripTime
            }
        }
        elseif ($Reply.Status -eq "TimedOut") {
            $Results += [PSCustomObject]@{
                HopNumber = $HopNumber
                Address   = "*"
                Status    = "TimedOut"
                RoundTripTime = 0
            }
        }
    }
}
catch {
    Write-Error "Traceroute failed: $($_.Exception.Message)"
}

Write-Host "=== Traceroute to $HostName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

<#
.SYNOPSIS
    Gets network adapter status.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-NetworkAdapterStatus.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
    
    $Results = @()
    foreach ($Adapter in $Adapters) {
        $IpConfig = Get-NetIPAddress -InterfaceIndex $Adapter.ifIndex -ErrorAction SilentlyContinue
        
        $Results += [PSCustomObject]@{
            Name         = $Adapter.Name
            Status       = $Adapter.Status
            LinkSpeed    = $Adapter.LinkSpeed
            MacAddress   = $Adapter.MacAddress
            IPAddress    = if ($IpConfig) { $IpConfig.IPAddress } else { "N/A" }
            PrefixLength = if ($IpConfig) { $IpConfig.PrefixLength } else { "N/A" }
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

Write-Host "=== Network Adapters on $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

<#
.SYNOPSIS
    Lists Windows Firewall rules.

.PARAMETER ComputerName
    Target server.

.PARAMETER Direction
    Inbound or Outbound.

.PARAMETER Enabled
    Only enabled rules.

.EXAMPLE
    .\Get-FirewallRules.ps1 -Direction Inbound -Enabled
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction = "",
    [switch]$Enabled
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($Direction, $Enabled)
    
    $Params = @{ }
    if ($Direction) { $Params.Direction = $Direction }
    if ($Enabled) { $Params.Enabled = "True" }
    
    $Rules = Get-NetFirewallRule @Params -ErrorAction SilentlyContinue | Select-Object -First 100
    
    $Results = @()
    foreach ($Rule in $Rules) {
        $PortFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $Rule -ErrorAction SilentlyContinue
        
        $Results += [PSCustomObject]@{
            Name        = $Rule.Name
            DisplayName = $Rule.DisplayName
            Direction   = $Rule.Direction
            Action      = $Rule.Action
            Enabled     = $Rule.Enabled
            LocalPort   = if ($PortFilter) { $PortFilter.LocalPort } else { "N/A" }
            RemotePort  = if ($PortFilter) { $PortFilter.RemotePort } else { "N/A" }
            Protocol    = if ($PortFilter) { $PortFilter.Protocol } else { "N/A" }
        }
    }
    $Results
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock $Direction $Enabled
}
else {
    $Results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $Direction $Enabled
}

Write-Host "=== Firewall Rules on $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

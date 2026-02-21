<#
.SYNOPSIS
    Lists firewall rules managed by Group Policy.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-GPOFirewallRules.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    $Rules = Get-NetFirewallRule -ErrorAction SilentlyContinue | Where-Object { $_.Profile -ne "NotConfigured" }
    
    $Results = @()
    foreach ($Rule in $Rules) {
        $GpoInfo = Get-NetFirewallRule -Name $Rule.Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty GPOSession
        
        if ($GpoInfo) {
            $PortFilter = Get-NetFirewallPortFilter -AssociatedNetFirewallRule $Rule -ErrorAction SilentlyContinue
            
            $Results += [PSCustomObject]@{
                Name        = $Rule.Name
                DisplayName = $Rule.DisplayName
                Direction   = $Rule.Direction
                Action      = $Rule.Action
                Enabled     = $Rule.Enabled
                Profile     = $Rule.Profile
                GPOSession  = $GpoInfo
                LocalPort   = if ($PortFilter) { $PortFilter.LocalPort } else { "N/A" }
            }
        }
    }
    
    $Results | Select-Object -First 50
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock
}
else {
    $Results = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock
}

Write-Host "=== GPO-Managed Firewall Rules on $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

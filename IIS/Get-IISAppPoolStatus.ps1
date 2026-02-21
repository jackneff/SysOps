<#
.SYNOPSIS
    Gets IIS application pool status.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-IISAppPoolStatus.ps1 -ComputerName "WebServer01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    Import-Module WebAdministration -ErrorAction Stop
    
    $AppPools = Get-ChildItem IIS:\AppPools
    
    $Results = @()
    foreach ($Pool in $AppPools) {
        $Results += [PSCustomObject]@{
            Name                  = $Pool.Name
            State                 = $Pool.State
            ManagedRuntimeVersion = $Pool.managedRuntimeVersion
            ManagedPipelineMode    = $Pool.managedPipelineMode
            StartMode             = $Pool.startMode
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

Write-Host "IIS Application Pools on: $ComputerName" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

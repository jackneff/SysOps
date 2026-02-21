<#
.SYNOPSIS
    Tests AD replication status between domain controllers.

.EXAMPLE
    .\Test-ADReplication.ps1
#>

[CmdletBinding()]
param(
    [string[]]$ComputerName = @()
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

if ($ComputerName.Count -eq 0) {
    $ComputerName = (Get-ADDomainController -Filter *).HostName
}

$Results = @()

foreach ($DC in $ComputerName) {
    Write-Host "Checking replication on: $DC" -ForegroundColor Cyan
    
    try {
        $ReplPartners = Get-ADReplicationPartnerMetadata -Target $DC -ErrorAction Stop
        
        foreach ($Partner in $ReplPartners) {
            $Results += [PSCustomObject]@{
                SourceServer      = $DC
                PartnerServer     = $Partner.PartnerServer
                LastReplication   = $Partner.LastReplicationSuccess
                FailureCount     = $Partner.NumberOfFailures
                LastError        = $Partner.LastReplicationResult
                IsHealthy        = ($Partner.NumberOfFailures -eq 0)
            }
        }
    }
    catch {
        Write-Warning "Failed to get replication info from $DC`: $($_.Exception.Message)"
    }
}

Write-Host "`n=== AD Replication Status ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

$Unhealthy = $Results | Where-Object { -not $_.IsHealthy }
if ($Unhealthy) {
    Write-Host "`n=== Replication Issues ===" -ForegroundColor Red
    $Unhealthy | Format-Table -AutoSize
}

return $Results

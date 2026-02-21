<#
.SYNOPSIS
    Finds certificates expiring within specified days.

.PARAMETER ComputerName
    Target server.

.PARAMETER Days
    Number of days to check (default: 30).

.EXAMPLE
    .\Get-ExpiringCertificates.ps1 -Days 30
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [int]$Days = 30
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($Days)
    
    $CertStore = Get-ChildItem -Path Cert:\LocalMachine\My -ErrorAction SilentlyContinue
    
    $Results = @()
    foreach ($Cert in $CertStore) {
        $DaysUntilExpiry = ($Cert.NotAfter - (Get-Date)).Days
        
        if ($DaysUntilExpiry -le $Days) {
            $Results += [PSCustomObject]@{
                Subject        = $Cert.Subject
                Issuer         = $Cert.Issuer
                Thumbprint    = $Cert.Thumbprint
                NotAfter       = $Cert.NotAfter
                DaysUntilExpiry = $DaysUntilExpiry
            }
        }
    }
    $Results | Sort-Object NotAfter
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Results = & $ScriptBlock $Days
}
else {
    $Results = Invoke-RemoteCommand -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $Days
}

Write-Host "=== Expiring Certificates (within $Days days) on $ComputerName ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

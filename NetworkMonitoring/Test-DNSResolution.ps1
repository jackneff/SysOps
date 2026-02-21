<#
.SYNOPSIS
    Tests DNS resolution (forward and reverse).

.PARAMETER HostName
    Hostname to resolve.

.PARAMETER IpAddress
    IP address for reverse lookup.

.EXAMPLE
    .\Test-DNSResolution.ps1 -HostName "example.com"

.EXAMPLE
    .\Test-DNSResolution.ps1 -IpAddress "192.168.1.1"
#>

[CmdletBinding()]
param(
    [string]$HostName = "",
    [string]$IpAddress = ""
)

$ErrorActionPreference = "Stop"

$Results = @()

if ($HostName) {
    try {
        $DnsResult = Resolve-DnsName -Name $HostName -ErrorAction Stop
        
        foreach ($Record in $DnsResult) {
            $Results += [PSCustomObject]@{
                QueryType   = "Forward"
                Input       = $HostName
                Result      = $Record.IPAddress
                RecordType  = $Record.Type
                Name        = $Record.Name
                Success     = $true
            }
        }
    }
    catch {
        $Results += [PSCustomObject]@{
            QueryType   = "Forward"
            Input       = $HostName
            Result      = "Failed"
            RecordType  = "N/A"
            Name        = $HostName
            Success     = $false
            Error       = $_.Exception.Message
        }
    }
}

if ($IpAddress) {
    try {
        $ReverseResult = Resolve-DnsName -Name $IpAddress -Type PTR -ErrorAction Stop
        
        foreach ($Record in $ReverseResult) {
            $Results += [PSCustomObject]@{
                QueryType   = "Reverse"
                Input       = $IpAddress
                Result      = $Record.NameHost
                RecordType  = $Record.Type
                Name        = $Record.Name
                Success     = $true
            }
        }
    }
    catch {
        $Results += [PSCustomObject]@{
            QueryType   = "Reverse"
            Input       = $IpAddress
            Result      = "Failed"
            RecordType  = "PTR"
            Name        = $IpAddress
            Success     = $false
            Error       = $_.Exception.Message
        }
    }
}

Write-Host "=== DNS Resolution ===" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

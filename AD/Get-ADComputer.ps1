<#
.SYNOPSIS
    Queries Active Directory for computers.

.DESCRIPTION
    Retrieves AD computer accounts with OS and last logon info.

.PARAMETER Filter
    LDAP filter string.

.PARAMETER SearchBase
    OU to search in.

.PARAMETER OperatingSystem
    Filter by operating system.

.PARAMETER InactiveDays
    Find computers inactive for specified days.

.EXAMPLE
    .\Get-ADComputer.ps1 -OperatingSystem "*Server*"

.EXAMPLE
    .\Get-ADComputer.ps1 -InactiveDays 90
#>

[CmdletBinding()]
param(
    [string]$Filter = "*",
    [string]$SearchBase = "",
    [string]$OperatingSystem = "",
    [int]$InactiveDays = 0
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

$Params = @{
    Filter = $Filter
    Properties = @("OperatingSystem", "OperatingSystemVersion", "LastLogonDate", "Enabled", "DNSHostName")
}

if ($SearchBase) {
    $Params.SearchBase = $SearchBase
}

if ($OperatingSystem) {
    $Params.Filter = "OperatingSystem -like '*$OperatingSystem*'"
}

$Computers = Get-ADComputer @Params -ErrorAction Stop

if ($InactiveDays -gt 0) {
    $CutoffDate = (Get-Date).AddDays(-$InactiveDays)
    $Computers = $Computers | Where-Object { $_.LastLogonDate -lt $CutoffDate -or -not $_.LastLogonDate }
}

$Results = $Computers | Select-Object Name, DNSHostName, OperatingSystem, OperatingSystemVersion, @{N = "LastLogonDate"; E = { $_.LastLogonDate }}, Enabled

$Results | Format-Table -AutoSize
return $Results

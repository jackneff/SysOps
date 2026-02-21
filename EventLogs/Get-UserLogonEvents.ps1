<#
.SYNOPSIS
    Lists all user login events from security logs.

.DESCRIPTION
    Retrieves user login events including interactive logons, network logons, and remote desktop sessions.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER Days
    Number of days to look back (default: 7).

.PARAMETER LogonType
    Filter by logon type (Interactive, Network, RemoteInteractive, Service).

.PARAMETER IncludeSuccessful
    Include only successful logins (default: true).

.PARAMETER IncludeFailed
    Include failed login attempts.

.EXAMPLE
    .\Get-UserLogonEvents.ps1

.EXAMPLE
    .\Get-UserLogonEvents.ps1 -Days 30
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [int]$Days = 7,
    
    [ValidateSet("Interactive", "Network", "RemoteInteractive", "Service", "All")]
    [string]$LogonType = "All",
    
    [switch]$IncludeSuccessful = $true,
    
    [switch]$IncludeFailed
)

$ErrorActionPreference = "Stop"

$StartTime = (Get-Date).AddDays(-$Days)

$EventIds = @{
    Successful = @(4624, 4625)
    Failed = @(4625)
}

$LogonTypeMap = @{
    2  = "Interactive"
    3  = "Network"
    4  = "Batch"
    5  = "Service"
    7  = "Unlock"
    8  = "NetworkCleartext"
    9  = "NewCredentials"
    10 = "RemoteInteractive"
    11 = "CachedInteractive"
}

$AllResults = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking: $Computer" -ForegroundColor Cyan
    
    try {
        $FilterHashTable = @{
            LogName   = 'Security'
            StartTime = $StartTime
        }
        
        if ($Computer -ne "localhost" -and $Computer -ne $env:COMPUTERNAME) {
            $FilterHashTable.ComputerName = $Computer
        }
        
        if ($IncludeFailed) {
            $FilterHashTable.Id = 4625
        }
        else {
            $FilterHashTable.Id = 4624
        }
        
        $Events = Get-WinEvent -FilterHashtable $FilterHashTable -MaxEvents 500 -ErrorAction SilentlyContinue
        
        foreach ($Event in $Events) {
            $Xml = [xml]$Event.ToXml()
            $EventData = $Xml.Event.EventData.Data
            
            $TargetUserName = ($EventData | Where-Object { $_.Name -eq "TargetUserName" }).'#text'
            $TargetDomainName = ($EventData | Where-Object { $_.Name -eq "TargetDomainName" }).'#text'
            $LogonTypeId = ($EventData | Where-Object { $_.Name -eq "LogonType" }).'#text'
            $IpAddress = ($EventData | Where-Object { $_.Name -eq "IpAddress" }).'#text'
            $ProcessName = ($EventData | Where-Object { $_.Name -eq "ProcessName" }).'#text'
            $IpAddress = if ($IpAddress -eq "-") { "Local" } else { $IpAddress }
            
            $LogonTypeName = if ($LogonTypeMap.ContainsKey([int]$LogonTypeId)) { 
                $LogonTypeMap[[int]$LogonTypeId] 
            } else { 
                "Type$LogonTypeId" 
            }
            
            $IsSuccess = $Event.Id -eq 4624
            
            if ($LogonType -ne "All" -and $LogonTypeName -ne $LogonType) {
                continue
            }
            
            if (-not $IncludeFailed -and -not $IsSuccess) {
                continue
            }
            
            $AllResults += [PSCustomObject]@{
                ComputerName   = $Computer
                TimeCreated   = $Event.TimeCreated
                EventId       = $Event.Id
                Status        = if ($IsSuccess) { "Success" } else { "Failed" }
                UserName      = "$TargetDomainName\$TargetUserName"
                LogonType     = $LogonTypeName
                IpAddress    = $IpAddress
                Process       = if ($ProcessName) { (Split-Path $ProcessName -Leaf) } else { "N/A" }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

$AllResults = $AllResults | Sort-Object TimeCreated -Descending

Write-Host "`n=== User Logon Events (Last $Days days) ===" -ForegroundColor Cyan

$SuccessCount = ($AllResults | Where-Object { $_.Status -eq "Success" }).Count
$FailedCount = ($AllResults | Where-Object { $_.Status -eq "Failed" }).Count

Write-Host "Successful: $SuccessCount | Failed: $FailedCount" -ForegroundColor Yellow
Write-Host ""

$AllResults | Format-Table -AutoSize

return $AllResults

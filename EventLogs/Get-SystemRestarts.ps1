<#
.SYNOPSIS
    Lists all system restarts from event logs.

.DESCRIPTION
    Retrieves system restart events and determines if they were expected (planned) or unexpected.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER Days
    Number of days to look back (default: 30).

.PARAMETER ExportUnexpectedOnly
    Only show unexpected/potential issue restarts.

.EXAMPLE
    .\Get-SystemRestarts.ps1

.EXAMPLE
    .\Get-SystemRestarts.ps1 -Days 7
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [int]$Days = 30,
    
    [switch]$ExportUnexpectedOnly
)

$ErrorActionPreference = "Stop"

$StartTime = (Get-Date).AddDays(-$Days)

$AllResults = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking: $Computer" -ForegroundColor Cyan
    
    try {
        $FilterHashTable = @{
            LogName   = 'System'
            Id        = 6008, 6006, 6005, 1074, 41
            StartTime = $StartTime
        }
        
        if ($Computer -ne "localhost" -and $Computer -ne $env:COMPUTERNAME) {
            $FilterHashTable.ComputerName = $Computer
        }
        
        $Events = Get-WinEvent -FilterHashtable $FilterHashTable -MaxEvents 100 -ErrorAction SilentlyContinue
        
        foreach ($Event in $Events) {
            $RestartType = "Unknown"
            $Expected = $false
            $Reason = ""
            
            switch ($Event.Id) {
                6008 {
                    $RestartType = "Unexpected"
                    $Expected = $false
                    $Reason = "Unexpected shutdown - Event ID 6008"
                }
                6006 {
                    $RestartType = "Expected"
                    $Expected = $true
                    $Reason = "Clean shutdown - Event ID 6006"
                }
                6005 {
                    $RestartType = "Expected"
                    $Expected = $true
                    $Reason = "System started - Event ID 6005"
                }
                1074 {
                    $RestartType = "Expected"
                    $Expected = $true
                    $Reason = "Process initiated restart - Event ID 1074"
                    
                    if ($Event.Message -match "reason:.*=(\d+)") {
                        $ReasonCode = $matches[1]
                        if ($ReasonCode -notin @(0, 6, 2)) {
                            $RestartType = "Expected (User Initiated)"
                        }
                    }
                }
                41 {
                    $RestartType = "Unexpected"
                    $Expected = $false
                    $Reason = "Kernel power loss / BSOD - Event ID 41"
                }
            }
            
            $UserName = "System"
            if ($Event.Message -match "User:\s*(\S+)") {
                $UserName = $matches[1]
            }
            
            if ($Event.Id -eq 1074 -and $Event.Message) {
                if ($Event.Message -match "started by") {
                    $splitParts = $Event.Message -split "started by"
                    if ($splitParts.Count -gt 1) {
                        $userPart = $splitParts[1] -split "`n"
                        if ($userPart.Count -gt 0) {
                            $UserName = $userPart[0].Trim()
                        }
                    }
                }
            }
            
            if (-not $ExportUnexpectedOnly -or ($ExportUnexpectedOnly -and -not $Expected)) {
                $AllResults += [PSCustomObject]@{
                    ComputerName = $Computer
                    TimeCreated = $Event.TimeCreated
                    EventId     = $Event.Id
                    RestartType = $RestartType
                    Expected   = $Expected
                    Reason     = $Reason
                    UserName   = $UserName
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

$AllResults = $AllResults | Sort-Object TimeCreated -Descending

Write-Host "`n=== System Restarts (Last $Days days) ===" -ForegroundColor Cyan

$ExpectedCount = ($AllResults | Where-Object { $_.Expected }).Count
$UnexpectedCount = ($AllResults | Where-Object { -not $_.Expected }).Count

Write-Host "Expected: $ExpectedCount | Unexpected: $UnexpectedCount" -ForegroundColor Yellow
Write-Host ""

$AllResults | Format-Table -AutoSize

return $AllResults

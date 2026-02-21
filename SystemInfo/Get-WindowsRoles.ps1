<#
.SYNOPSIS
    Lists all Windows Server roles and features installed.

.DESCRIPTION
    Retrieves all enabled roles, role services, and features on a Windows Server.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER ExportInstalled
    Only show installed/enabled items.

.PARAMETER ExportAvailable
    Only show available (not installed) items.

.EXAMPLE
    .\Get-WindowsRoles.ps1

.EXAMPLE
    .\Get-WindowsRoles.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [switch]$ExportInstalled,
    
    [switch]$ExportAvailable
)

$ErrorActionPreference = "Stop"

$AllResults = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking roles on: $Computer" -ForegroundColor Cyan
    
    if ($Computer -eq "localhost" -or $Computer -eq $env:COMPUTERNAME) {
        try {
            $Features = Get-WindowsFeature -ErrorAction Stop
        }
        catch {
            Write-Warning "Get-WindowsFeature not available. Trying Get-WindowsCapability..."
            $Features = Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Select-Object Name, State
        }
    }
    else {
        try {
            $Session = New-PSSession -ComputerName $Computer -ErrorAction Stop
            $Features = Invoke-Command -Session $Session -ScriptBlock {
                try { Get-WindowsFeature -ErrorAction Stop }
                catch { Get-WindowsCapability -Online -ErrorAction SilentlyContinue | Select-Object Name, State }
            }
            Remove-PSSession $Session
        }
        catch {
            Write-Warning "Failed to connect to $Computer`: $($_.Exception.Message)"
            continue
        }
    }
    
    foreach ($Feature in $Features) {
        if ($ExportInstalled -and $Feature.InstallState -eq "Installed") {
            $AllResults += [PSCustomObject]@{
                ComputerName = $Computer
                Name        = $Feature.Name
                DisplayName = $Feature.DisplayName
                State       = if ($Feature.State) { $Feature.State } else { $Feature.InstallState }
            }
        }
        elseif ($ExportAvailable -and $Feature.InstallState -eq "Available") {
            $AllResults += [PSCustomObject]@{
                ComputerName = $Computer
                Name        = $Feature.Name
                DisplayName = $Feature.DisplayName
                State       = $Feature.InstallState
            }
        }
        elseif (-not $ExportInstalled -and -not $ExportAvailable) {
            $AllResults += [PSCustomObject]@{
                ComputerName = $Computer
                Name        = $Feature.Name
                DisplayName = $Feature.DisplayName
                State       = if ($Feature.State) { $Feature.State } else { $Feature.InstallState }
            }
        }
    }
}

$Installed = $AllResults | Where-Object { $_.State -eq "Installed" -or $_.State -eq "Installed" }
$Available = $AllResults | Where-Object { $_.State -eq "Available" -or $_.State -eq "NotInstalled" }

Write-Host "`n=== Installed Roles/Features ===" -ForegroundColor Green
$Installed | Sort-Object DisplayName | Format-Table -AutoSize

Write-Host "`nTotal Installed: $($Installed.Count)" -ForegroundColor Cyan
Write-Host "Total Available: $($Available.Count)" -ForegroundColor Cyan

return $AllResults

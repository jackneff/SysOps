<#
.SYNOPSIS
    Gets disk space from remote servers via CIM.

.PARAMETER ComputerName
    Target server(s).

.EXAMPLE
    .\Get-DiskSpaceRemote.ps1 -ComputerName "Server01","Server02"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$ComputerName
)

$ErrorActionPreference = "Stop"

$Results = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking: $Computer" -ForegroundColor Cyan
    
    try {
        $Cim = New-CimSession -ComputerName $Computer -OperationTimeoutSec 10 -ErrorAction Stop
        
        $Disks = Get-CimInstance -CimSession $Cim -ClassName Win32_LogicalDisk -Filter "DriveType=3"
        
        foreach ($Disk in $Disks) {
            $UsedGB = [math]::Round(($Disk.Size - $Disk.FreeSpace) / 1GB, 2)
            $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
            $TotalGB = [math]::Round($Disk.Size / 1GB, 2)
            $PercentUsed = if ($TotalGB -gt 0) { [math]::Round(($UsedGB / $TotalGB) * 100, 1) } else { 0 }
            
            $Results += [PSCustomObject]@{
                ComputerName = $Computer
                Drive       = $Disk.DeviceID
                UsedGB      = $UsedGB
                FreeGB      = $FreeGB
                TotalGB     = $TotalGB
                PercentUsed = $PercentUsed
            }
        }
        
        Remove-CimSession -CimSession $Cim
    }
    catch {
        Write-Warning "Failed to get disk info from $Computer`: $($_.Exception.Message)"
    }
}

$Results | Format-Table -AutoSize
return $Results

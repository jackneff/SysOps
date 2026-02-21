<#
.SYNOPSIS
    Checks the status of a specific service on local or remote computers.

.DESCRIPTION
    Retrieves the status of a Windows service and returns an object with service details.

.PARAMETER ComputerName
    The target computer name(s). Defaults to localhost.

.PARAMETER ServiceName
    The name of the service to check.

.PARAMETER UseConfig
    Use services defined in settings.json config file.

.EXAMPLE
    .\Check-ServiceStatus.ps1 -ServiceName W3SVC

.EXAMPLE
    .\Check-ServiceStatus.ps1 -ComputerName "Server01","Server02" -ServiceName "MSSQLSERVER"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [Parameter(Mandatory = $false)]
    [string]$ServiceName = "",
    
    [switch]$UseConfig
)

$ErrorActionPreference = "Stop"

Import-Module "$PSScriptRoot\..\Modules\AdminTools.psm1" -Force

if ($UseConfig) {
    $Config = Get-Config
    $ComputerName = $Config.Servers
    $ServiceNameToCheck = $Config.CriticalServices
}
else {
    $ServiceNameToCheck = @($ServiceName)
}

$Results = @()

foreach ($Computer in $ComputerName) {
    foreach ($Service in $ServiceNameToCheck) {
        Write-Verbose "Checking service '$Service' on computer '$Computer'..."
        
        try {
            $ServiceObj = Get-Service -Name $Service -ComputerName $Computer -ErrorAction Stop
            
            $Results += [PSCustomObject]@{
                ComputerName = $Computer
                ServiceName  = $ServiceObj.Name
                DisplayName  = $ServiceObj.DisplayName
                Status       = $ServiceObj.Status
                StartType    = $ServiceObj.StartType
            }
        }
        catch {
            $Results += [PSCustomObject]@{
                ComputerName = $Computer
                ServiceName  = $Service
                DisplayName  = "N/A"
                Status       = "NotFound"
                StartType    = "N/A"
                Error        = $_.Exception.Message
            }
        }
    }
}

$Results | Format-Table -AutoSize
$Results

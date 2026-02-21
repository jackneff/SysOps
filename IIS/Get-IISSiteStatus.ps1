<#
.SYNOPSIS
    Gets IIS site status.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-IISSiteStatus.ps1 -ComputerName "WebServer01"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost"
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    Import-Module WebAdministration -ErrorAction Stop
    
    $Sites = Get-Website
    
    $Results = @()
    foreach ($Site in $Sites) {
        $Results += [PSCustomObject]@{
            Name         = $Site.Name
            Id           = $Site.Id
            State        = $Site.State
            PhysicalPath = $Site.physicalPath
            Bindings     = ($Site.bindings.Collection | ForEach-Object { $_.protocol + "://" + $_.bindingInformation }) -join ", "
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

Write-Host "IIS Sites on: $ComputerName" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

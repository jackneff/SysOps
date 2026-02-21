<#
.SYNOPSIS
    Gets IIS site bindings.

.PARAMETER ComputerName
    Target server.

.EXAMPLE
    .\Get-IISBindings.ps1 -ComputerName "WebServer01"
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
        foreach ($Binding in $Site.bindings.Collection) {
            $BindingInfo = $Binding.bindingInformation
            $Parts = $BindingInfo -split ":"
            
            $Results += [PSCustomObject]@{
                SiteName       = $Site.Name
                Protocol       = $Binding.protocol
                Port           = $Parts[1]
                IPAddress      = $Parts[0]
                HostHeader     = $Parts[2]
                Certificate    = $Binding.certificateHash
            }
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

Write-Host "IIS Bindings on: $ComputerName" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

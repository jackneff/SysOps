<#
.SYNOPSIS
    Starts an IIS site.

.PARAMETER ComputerName
    Target server.

.PARAMETER SiteName
    IIS site name to start.

.EXAMPLE
    .\Start-IISSite.ps1 -SiteName "Default Web Site"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [Parameter(Mandatory = $true)]
    [string]$SiteName
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($SiteName)
    
    Import-Module WebAdministration -ErrorAction Stop
    
    Start-Website -Name $SiteName -ErrorAction Stop
    
    $Site = Get-Website -Name $SiteName
    
    [PSCustomObject]@{
        SiteName = $Site.Name
        State    = $Site.State
        Success  = ($Site.State -eq "Started")
    }
}

if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
    $Result = & $ScriptBlock $SiteName
}
else {
    $Result = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $SiteName
}

if ($Result.Success) {
    Write-Host "Site '$SiteName' started successfully" -ForegroundColor Green
}
else {
    Write-Warning "Site '$SiteName' failed to start. Current state: $($Result.State)"
}

return $Result

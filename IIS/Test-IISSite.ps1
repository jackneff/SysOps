<#
.SYNOPSIS
    Tests IIS site availability via HTTP.

.PARAMETER ComputerName
    Target server.

.PARAMETER SiteName
    IIS site name to test.

.EXAMPLE
    .\Test-IISSite.ps1 -ComputerName "WebServer01" -SiteName "Default Web Site"
#>

[CmdletBinding()]
param(
    [string]$ComputerName = "localhost",
    [string]$SiteName = ""
)

$ErrorActionPreference = "Stop"

$ScriptBlock = {
    param($SiteName)
    
    Import-Module WebAdministration -ErrorAction Stop
    
    if ($SiteName) {
        $Sites = @((Get-Website -Name $SiteName))
    }
    else {
        $Sites = Get-Website
    }
    
    $Results = @()
    
    foreach ($Site in $Sites) {
        $Binding = $Site.bindings.Collection[0]
        $Protocol = $Binding.protocol
        $BindingInfo = $Binding.bindingInformation
        
        $HostHeader = ($BindingInfo -split ":")[2]
        $Port = ($BindingInfo -split ":")[1]
        
        if (-not $HostHeader) { $HostHeader = "localhost" }
        if (-not $Port) { $Port = 80 }
        
        $Url = "$Protocol`://$HostHeader`:$Port"
        
        try {
            $Response = Invoke-WebRequest -Uri $Url -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
            $StatusCode = [int]$Response.StatusCode
            $IsHealthy = ($StatusCode -eq 200)
        }
        catch {
            $StatusCode = 0
            $IsHealthy = $false
        }
        
        $Results += [PSCustomObject]@{
            SiteName    = $Site.Name
            Url         = $Url
            State       = $Site.State
            StatusCode  = $StatusCode
            IsHealthy   = $IsHealthy
        }
    }
    
    $Results
}

$Params = @{ ComputerName = $ComputerName }
if ($SiteName) {
    $Params.ScriptBlock = $ScriptBlock
    $Params.Arguments = $SiteName
    
    if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
        $Results = & $ScriptBlock $SiteName
    }
    else {
        $Results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock -ArgumentList $SiteName
    }
}
else {
    $Params.ScriptBlock = $ScriptBlock
    
    if ($ComputerName -eq "localhost" -or $ComputerName -eq $env:COMPUTERNAME) {
        $Results = & $ScriptBlock ""
    }
    else {
        $Results = Invoke-Command -ComputerName $ComputerName -ScriptBlock $ScriptBlock
    }
}

Write-Host "IIS Site Tests on: $ComputerName" -ForegroundColor Cyan
$Results | Format-Table -AutoSize

return $Results

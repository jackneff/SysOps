<#
.SYNOPSIS
    Tests web application availability.

.DESCRIPTION
    Performs HTTP HEAD/GET request to check if a web application is responding
    and returns status code, response time, and SSL certificate info.

.PARAMETER Url
    The URL to test.

.PARAMETER ExpectedStatusCode
    Expected HTTP status code (default: 200).

.PARAMETER TimeoutSeconds
    Request timeout in seconds.

.PARAMETER IgnoreSSL
    Ignore SSL certificate errors.

.EXAMPLE
    .\Test-WebApplication.ps1 -Url "https://example.com"

.EXAMPLE
    .\Test-WebApplication.ps1 -Url "https://intranet.company.com" -IgnoreSSL
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    
    [int]$ExpectedStatusCode = 200,
    
    [int]$TimeoutSeconds = 30,
    
    [switch]$IgnoreSSL
)

$ErrorActionPreference = "Stop"

if ($IgnoreSSL) {
    add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}

$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

try {
    $WebRequest = [System.Net.WebRequest]::Create($Url)
    $WebRequest.Method = "GET"
    $WebRequest.Timeout = ($TimeoutSeconds * 1000)
    $WebRequest.UserAgent = "SysOps-WebMonitor/1.0"
    
    $Response = $WebRequest.GetResponse()
    $Stopwatch.Stop()
    
    $StatusCode = [int]$Response.StatusCode
    $StatusDescription = $Response.StatusDescription
    $ResponseTime = $Stopwatch.ElapsedMilliseconds
    
    $Result = [PSCustomObject]@{
        Url             = $Url
        StatusCode      = $StatusCode
        StatusDescription = $StatusDescription
        ResponseTimeMs  = $ResponseTime
        IsHealthy       = ($StatusCode -eq $ExpectedStatusCode)
        Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    
    if ($Response -is [System.Net.HttpWebResponse]) {
        $Response.Close()
    }
}
catch [System.Net.WebException] {
    $Stopwatch.Stop()
    $Exception = $_.Exception.Response
    
    $StatusCode = 0
    $StatusDescription = "Error"
    
    if ($Exception) {
        $StatusCode = [int]$Exception.StatusCode
        $StatusDescription = $Exception.StatusDescription
    }
    
    $Result = [PSCustomObject]@{
        Url             = $Url
        StatusCode      = $StatusCode
        StatusDescription = $StatusDescription
        ResponseTimeMs  = $Stopwatch.ElapsedMilliseconds
        IsHealthy       = $false
        ErrorMessage    = $_.Exception.Message
        Timestamp       = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

if ($Result.IsHealthy) {
    Write-Host "OK" -ForegroundColor Green -NoNewline
    Write-Host " - $Url returned $StatusCode in ${ResponseTime}ms"
}
else {
    Write-Host "FAIL" -ForegroundColor Red -NoNewline
    Write-Host " - $Url returned $StatusCode ($StatusDescription)"
}

return $Result

<#
.SYNOPSIS
    Tests SOAP API endpoints.

.DESCRIPTION
    Tests SOAP (Simple Object Access Protocol) XML web services.
    Supports SOAP 1.1 and 1.2, custom namespaces, and authentication.
    Can load endpoints from settings.json or accept inline parameters.

.PARAMETER Name
    Display name for the endpoint (used in logging).

.PARAMETER Url
    Full URL of the SOAP service.

.PARAMETER Action
    SOAP action/operation name.

.PARAMETER Namespace
    XML namespace for the action.

.PARAMETER BodyParams
    Parameters for the SOAP body as a hashtable.

.PARAMETER Envelope
    Pre-built SOAP envelope (alternative to BodyParams).

.PARAMETER Version
    SOAP version: 1.1 or 1.2. Default: 1.1.

.PARAMETER Username
    Username for Basic or WS-Security authentication.

.PARAMETER Password
    Password for Basic or WS-Security authentication.

.PARAMETER TimeoutSeconds
    Request timeout in seconds. Default: 30.

.PARAMETER EnableRetry
    Enable retry on failure.

.PARAMETER SkipSslValidation
    Skip SSL certificate validation.

.PARAMETER ExpectedStatusCode
    Expected HTTP status code. Default: 200.

.PARAMETER UseConfig
    Load endpoints from settings.json.

.PARAMETER PassThru
    Return detailed result object.

.EXAMPLE
    .\Test-SoapEndpoint.ps1 -Url "https://weather.example.com/soap" -Action "GetWeather" -BodyParams @{city="New York"}

.EXAMPLE
    .\Test-SoapEndpoint.ps1 -Url "https://example.com/soap" -Action "GetUser" -Envelope $xml -Username "admin" -Password "pass"

.EXAMPLE
    .\Test-SoapEndpoint.ps1 -UseConfig
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Name,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Inline")]
    [string]$Url,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Inline")]
    [string]$Action,
    
    [string]$Namespace,
    
    [hashtable]$BodyParams = @{},
    
    [string]$Envelope,
    
    [ValidateSet("1.1", "1.2")]
    [string]$Version = "1    [string]$.1",
    
Username,
    
    [string]$Password,
    
    [int]$TimeoutSeconds = 30,
    
    [switch]$EnableRetry,
    
    [int]$RetryCount = 3,
    
    [int]$RetryDelayMs = 1000,
    
    [switch]$SkipSslValidation,
    
    [int]$ExpectedStatusCode = 200,
    
    [switch]$UseConfig,
    
    [switch]$PassThru,
    
    [switch]$LogToConsoleOnly,
    
    [switch]$LogToFileOnly
)

$ErrorActionPreference = "Stop"

$ModulePath = "$PSScriptRoot\Modules\WebTestTools.psm1"
if (-not (Test-Path $ModulePath)) {
    $ModulePath = "$PSScriptRoot\..\Modules\WebTestTools.psm1"
}
Import-Module $ModulePath -Force

$defaults = Get-WebTestConfig
if ($defaults) {
    $logPath = $defaults.Defaults.logPath
}
else {
    $logPath = "$PSScriptRoot\..\..\Logs\WebTests"
}

function Write-TestLog {
    param([string]$Message, [string]$Level = "Info")
    $params = @{
        Message = $Message
        Level = $Level
        LogPath = $logPath
    }
    if ($LogToConsoleOnly) { $params.LogToConsoleOnly = $true }
    if ($LogToFileOnly) { $params.LogToFileOnly = $true }
    Write-WebTestLog @params
}

function New-SoapRequestEnvelope {
    param(
        [string]$Action,
        [hashtable]$Params,
        [string]$NS,
        [string]$Ver
    )
    
    $soapNS = if ($Ver -eq "1.2") { "http://www.w3.org/2003/05/soap-envelope" } else { "http://schemas.xmlsoap.org/soap/envelope/" }
    
    $bodyContent = ""
    foreach ($key in $Params.Keys) {
        $bodyContent += "<$key>$($Params[$key])</$key>"
    }
    
    $nsAttr = if ($NS) { " xmlns:ns=`"$NS`"" } else { "" }
    
    $envelope = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="$soapNS"$nsAttr>
  <soap:Header/>
  <soap:Body>
    <$Action>
      $bodyContent
    </$Action>
  </soap:Body>
</soap:Envelope>
"@
    return $envelope
}

function Test-SingleSoapEndpoint {
    param(
        [string]$EndpointName,
        [string]$EndpointUrl,
        [string]$EndpointAction,
        [string]$EndpointNamespace,
        [hashtable]$EndpointBodyParams,
        [string]$EndpointEnvelope,
        [string]$EndpointVersion,
        [string]$EndpointUser,
        [string]$EndpointPass,
        [int]$EndpointExpectedStatus
    )
    
    $testName = if ($EndpointName) { $EndpointName } else { $EndpointAction }
    Write-TestLog "Testing SOAP endpoint: $testName" -Level "Info"
    Write-TestLog "  URL: $EndpointUrl" -Level "Info"
    Write-TestLog "  Action: $EndpointAction" -Level "Info"
    Write-TestLog "  Version: $EndpointVersion" -Level "Info"
    
    $contentType = if ($EndpointVersion -eq "1.2") { "application/soap+xml" } else { "text/xml; charset=utf-8" }
    
    $headers = @{
        "Content-Type" = $contentType
        "SOAPAction" = "`"$EndpointAction`""
    }
    
    if ($EndpointUser -and $EndpointPass) {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$EndpointUser`:$EndpointPass"))
        $headers["Authorization"] = "Basic $encoded"
    }
    
    $soapEnvelope = if ($EndpointEnvelope) { $EndpointEnvelope } else {
        New-SoapRequestEnvelope -Action $EndpointAction -Params $EndpointBodyParams -NS $EndpointNamespace -Ver $EndpointVersion
    }
    
    Write-TestLog "  SOAP Envelope: $($soapEnvelope.Substring(0, [Math]::Min(200, $soapEnvelope.Length)))..." -Level "Info"
    
    $params = @{
        Url = $EndpointUrl
        Method = "POST"
        Headers = $headers
        Body = $soapEnvelope
        ContentType = $contentType
        TimeoutSeconds = $TimeoutSeconds
        EnableRetry = $EnableRetry
        RetryCount = $RetryCount
        RetryDelayMs = $RetryDelayMs
        SkipSslValidation = $SkipSslValidation
        PassThru = $true
    }
    
    $result = Invoke-WebRequestEx @params
    
    $statusIcon = if ($result.Success) { "[OK]" } else { "[FAIL]" }
    $statusLevel = if ($result.Success) { "Success" } else { "Error" }
    Write-TestLog "$statusIcon $testName - Status: $($result.StatusCode) ($($result.StatusDescription)) in $($result.ResponseTimeMs)ms" -Level $statusLevel
    
    if ($result.Error) {
        Write-TestLog "  Error: $($result.Error)" -Level "Error"
    }
    
    if ($result.Success -and $result.Content) {
        try {
            [xml]$xmlResponse = $result.Content
            $fault = $xmlResponse.SelectSingleNode("//soap:Fault", @{"soap"="http://schemas.xmlsoap.org/soap/envelope/"})
            if ($fault -or $xmlResponse.SelectSingleNode("//Fault")) {
                Write-TestLog "  SOAP Fault detected in response" -Level "Error"
            }
            else {
                Write-TestLog "  SOAP Response: Valid XML" -Level "Success"
            }
        }
        catch {
            Write-TestLog "  Response parsing: Could not parse as XML" -Level "Warning"
        }
    }
    
    return @{
        Name = $testName
        Result = $result
        ExpectedStatusCode = $EndpointExpectedStatus
        Success = ($result.StatusCode -eq $EndpointExpectedStatus)
    }
}

$results = @()

if ($UseConfig) {
    Write-TestLog "=== Loading SOAP endpoints from config ===" -Level "Info"
    
    if (-not $defaults) {
        Write-TestLog "Could not load config. Use inline parameters." -Level "Error"
        exit 1
    }
    
    if (-not $defaults.Endpoints.soapEndpoints) {
        Write-TestLog "No soapEndpoints defined in config." -Level "Error"
        exit 1
    }
    
    foreach ($endpoint in $defaults.Endpoints.soapEndpoints) {
        $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
        
        $epName = if ($endpoint.name) { $endpoint.name } else { $null }
        $epUrl = if ($endpoint.url) { $endpoint.url } else { $null }
        $epAction = if ($endpoint.action) { $endpoint.action } else { $null }
        $epNS = if ($endpoint.namespace) { $endpoint.namespace } else { $null }
        $epBody = if ($endpoint.bodyParams) { $endpoint.bodyParams } else { @{} }
        $epEnv = if ($endpoint.envelope) { $endpoint.envelope } else { $null }
        $epVer = if ($endpoint.version) { $endpoint.version } else { "1.1" }
        $epUser = if ($endpoint.username) { $endpoint.username } else { $null }
        $epPass = if ($endpoint.password) { $endpoint.password } else { $null }
        $epExpected = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
        
        if ($epUrl -and $epAction) {
            $result = Test-SingleSoapEndpoint `
                -EndpointName $epName `
                -EndpointUrl $epUrl `
                -EndpointAction $epAction `
                -EndpointNamespace $epNS `
                -EndpointBodyParams $epBody `
                -EndpointEnvelope $epEnv `
                -EndpointVersion $epVer `
                -EndpointUser $epUser `
                -EndpointPass $epPass `
                -EndpointExpectedStatus $epExpected
            
            $results += $result
        }
    }
}
else {
    if (-not $Name) {
        $Name = $Action
    }
    
    $result = Test-SingleSoapEndpoint `
        -EndpointName $Name `
        -EndpointUrl $Url `
        -EndpointAction $Action `
        -EndpointNamespace $Namespace `
        -EndpointBodyParams $BodyParams `
        -EndpointEnvelope $Envelope `
        -EndpointVersion $Version `
        -EndpointUser $Username `
        -EndpointPass $Password `
        -EndpointExpectedStatus $ExpectedStatusCode
    
    $results += $result
}

Write-TestLog "=== SOAP Endpoint Test Summary ===" -Level "Info"
$passed = ($results | Where-Object { $_.Success }).Count
$failed = ($results | Where-Object { -not $_.Success }).Count
Write-TestLog "Total: $($results.Count) | Passed: $passed | Failed: $failed" -Level $(if ($failed -eq 0) { "Success" } else { "Warning" })

if ($PassThru) {
    return $results
}

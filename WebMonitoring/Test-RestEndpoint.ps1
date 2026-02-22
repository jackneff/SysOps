<#
.SYNOPSIS
    Tests REST API endpoints with various HTTP methods.

.DESCRIPTION
    Tests REST API endpoints supporting GET, POST, PATCH, PUT, and DELETE operations.
    Supports multiple authentication methods including API Key, Bearer Token, and Basic Auth.
    Can load endpoints from settings.json or accept inline parameters.

.PARAMETER Name
    Display name for the endpoint (used in logging).

.PARAMETER Url
    Full URL of the REST endpoint.

.PARAMETER Method
    HTTP method to use: GET, POST, PATCH, PUT, or DELETE. Default: GET.

.PARAMETER Headers
    Additional headers as a hashtable.

.PARAMETER Body
    Request body. Can be a hashtable, PSCustomObject, or JSON string.

.PARAMETER ContentType
    Content-Type header. Default: application/json.

.PARAMETER ApiKey
    API Key for authentication.

.PARAMETER ApiKeyHeader
    Header name for API Key. Default: X-API-Key.

.PARAMETER BearerToken
    Bearer token for authentication.

.PARAMETER Username
    Username for Basic authentication.

.PARAMETER Password
    Password for Basic authentication.

.PARAMETER TimeoutSeconds
    Request timeout in seconds. Default: 30.

.PARAMETER EnableRetry
    Enable retry on failure.

.PARAMETER RetryCount
    Number of retry attempts. Default: 3.

.PARAMETER SkipSslValidation
    Skip SSL certificate validation.

.PARAMETER ValidateJson
    Validate response is valid JSON.

.PARAMETER ExpectedStatusCode
    Expected HTTP status code. Default: 200.

.PARAMETER UseConfig
    Load endpoints from settings.json.

.PARAMETER PassThru
    Return detailed result object.

.EXAMPLE
    .\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -Method GET

.EXAMPLE
    .\Test-RestEndpoint.ps1 -Url "https://api.example.com/users" -Method POST -Body @{name="John";email="john@example.com"}

.EXAMPLE
    .\Test-RestEndpoint.ps1 -Url "https://api.example.com/users/1" -Method PATCH -Body @{name="Jane"} -BearerToken "xxx"

.EXAMPLE
    .\Test-RestEndpoint.ps1 -UseConfig

.EXAMPLE
    .\Test-RestEndpoint.ps1 -Url "https://api.example.com/users/1" -Method DELETE -ApiKey "secret" -ExpectedStatusCode 204
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Name,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Inline")]
    [string]$Url,
    
    [ValidateSet("GET", "POST", "PATCH", "PUT", "DELETE", "HEAD", "OPTIONS")]
    [string]$Method = "GET",
    
    [hashtable]$Headers = @{},
    
    [object]$Body,
    
    [string]$ContentType = "application/json",
    
    [string]$ApiKey,
    
    [string]$ApiKeyHeader = "X-API-Key",
    
    [string]$BearerToken,
    
    [string]$Username,
    
    [string]$Password,
    
    [int]$TimeoutSeconds = 30,
    
    [switch]$EnableRetry,
    
    [int]$RetryCount = 3,
    
    [int]$RetryDelayMs = 1000,
    
    [switch]$SkipSslValidation,
    
    [switch]$ValidateJson,
    
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

function Test-SingleEndpoint {
    param(
        [string]$EndpointName,
        [string]$EndpointUrl,
        [string]$EndpointMethod,
        [object]$EndpointBody,
        [string]$EndpointAuth,
        [int]$EndpointExpectedStatus
    )
    
    $testName = if ($EndpointName) { $EndpointName } else { $EndpointUrl }
    Write-TestLog "Testing REST endpoint: $testName" -Level "Info"
    Write-TestLog "  URL: $EndpointUrl" -Level "Info"
    Write-TestLog "  Method: $EndpointMethod" -Level "Info"
    
    $headers = @{}
    
    if ($EndpointAuth -eq "apikey" -and $ApiKey) {
        $headers[$ApiKeyHeader] = $ApiKey
    }
    elseif ($EndpointAuth -eq "bearer" -and $BearerToken) {
        $headers["Authorization"] = "Bearer $BearerToken"
    }
    elseif ($EndpointAuth -eq "basic" -and $Username -and $Password) {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password"))
        $headers["Authorization"] = "Basic $encoded"
    }
    
    foreach ($key in $Headers.Keys) {
        $headers[$key] = $Headers[$key]
    }
    
    $params = @{
        Url = $EndpointUrl
        Method = $EndpointMethod
        Headers = $headers
        TimeoutSeconds = $TimeoutSeconds
        EnableRetry = $EnableRetry
        RetryCount = $RetryCount
        RetryDelayMs = $RetryDelayMs
        SkipSslValidation = $SkipSslValidation
        PassThru = $true
    }
    
    if ($EndpointBody -and $EndpointMethod -ne "GET") {
        $params.Body = $EndpointBody
        $params.ContentType = $ContentType
    }
    
    $result = Invoke-WebRequestEx @params
    
    $statusIcon = if ($result.Success) { "[OK]" } else { "[FAIL]" }
    $statusLevel = if ($result.Success) { "Success" } else { "Error" }
    Write-TestLog "$statusIcon $testName - Status: $($result.StatusCode) ($($result.StatusDescription)) in $($result.ResponseTimeMs)ms" -Level $statusLevel
    
    if ($result.StatusCode -ne $EndpointExpectedStatus) {
        Write-TestLog "  WARNING: Expected status $EndpointExpectedStatus but got $($result.StatusCode)" -Level "Warning"
    }
    
    if ($ValidateJson -and $result.Success -and $result.Content) {
        if (Test-JsonValid -JsonString $result.Content) {
            Write-TestLog "  JSON Validation: Valid" -Level "Success"
        }
        else {
            Write-TestLog "  JSON Validation: Invalid" -Level "Error"
        }
    }
    
    if ($result.Error) {
        Write-TestLog "  Error: $($result.Error)" -Level "Error"
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
    Write-TestLog "=== Loading REST endpoints from config ===" -Level "Info"
    
    if (-not $defaults) {
        Write-TestLog "Could not load config. Use inline parameters." -Level "Error"
        exit 1
    }
    
    if (-not $defaults.Endpoints.restEndpoints) {
        Write-TestLog "No restEndpoints defined in config." -Level "Error"
        exit 1
    }
    
    foreach ($endpoint in $defaults.Endpoints.restEndpoints) {
        $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
        
        $epName = if ($endpoint.name) { $endpoint.name } else { $null }
        $epUrl = if ($endpoint.url) { $endpoint.url } else { $null }
        $epMethod = if ($endpoint.method) { $endpoint.method } else { "GET" }
        $epBody = if ($endpoint.body) { $endpoint.body } else { $null }
        $epAuth = if ($endpoint.auth) { $endpoint.auth } else { $null }
        $epExpected = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
        
        if ($epUrl) {
            $result = Test-SingleEndpoint `
                -EndpointName $epName `
                -EndpointUrl $epUrl `
                -EndpointMethod $epMethod `
                -EndpointBody $epBody `
                -EndpointAuth $epAuth `
                -EndpointExpectedStatus $epExpected
            
            $results += $result
        }
    }
}
else {
    if (-not $Name) {
        $Name = $Url
    }
    
    $result = Test-SingleEndpoint `
        -EndpointName $Name `
        -EndpointUrl $Url `
        -EndpointMethod $Method `
        -EndpointBody $Body `
        -EndpointAuth $null `
        -EndpointExpectedStatus $ExpectedStatusCode
    
    $results += $result
}

Write-TestLog "=== REST Endpoint Test Summary ===" -Level "Info"
$passed = ($results | Where-Object { $_.Success }).Count
$failed = ($results | Where-Object { -not $_.Success }).Count
Write-TestLog "Total: $($results.Count) | Passed: $passed | Failed: $failed" -Level $(if ($failed -eq 0) { "Success" } else { "Warning" })

if ($PassThru) {
    return $results
}

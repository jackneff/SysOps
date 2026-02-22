<#
.SYNOPSIS
    Tests Microsoft Graph API endpoints.

.DESCRIPTION
    Tests Microsoft Graph API endpoints with OAuth2 client credentials flow.
    Supports token acquisition and refresh, common Graph endpoints.
    Can load endpoints from settings.json or accept inline parameters.

.PARAMETER Name
    Display name for the endpoint (used in logging).

.PARAMETER Endpoint
    Graph endpoint path (e.g., "/users", "/groups", "/me").

.PARAMETER Url
    Full URL of the Graph endpoint (alternative to Endpoint).

.PARAMETER Method
    HTTP method: GET, POST, PATCH, PUT, DELETE. Default: GET.

.PARAMETER Body
    Request body for POST/PATCH requests.

.PARAMETER TenantId
    Azure AD tenant ID.

.PARAMETER ClientId
    Azure AD application (client) ID.

.PARAMETER ClientSecret
    Azure AD application client secret.

.PARAMETER AccessToken
    Pre-existing access token (skip token acquisition).

.PARAMETER Scope
    OAuth2 scope. Default: https://graph.microsoft.com/.default

.PARAMETER TimeoutSeconds
    Request timeout in seconds. Default: 30.

.PARAMETER EnableRetry
    Enable retry on failure.

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
    .\Test-GraphEndpoint.ps1 -TenantId "xxx" -ClientId "xxx" -ClientSecret "xxx" -Endpoint "/users"

.EXAMPLE
    .\Test-GraphEndpoint.ps1 -Endpoint "/users" -Method POST -Body @{displayName="Test User";mail="test@example.com"} -TenantId "xxx" -ClientId "xxx" -ClientSecret "xxx"

.EXAMPLE
    .\Test-GraphEndpoint.ps1 -Url "https://graph.microsoft.com/v1.0/users" -AccessToken "xxx"

.EXAMPLE
    .\Test-GraphEndpoint.ps1 -UseConfig
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Name,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Endpoint")]
    [string]$Endpoint,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Url")]
    [string]$Url,
    
    [ValidateSet("GET", "POST", "PATCH", "PUT", "DELETE")]
    [string]$Method = "GET",
    
    [object]$Body,
    
    [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
    [string]$TenantId,
    
    [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
    [string]$ClientId,
    
    [Parameter(Mandatory = $true, ParameterSetName = "OAuth")]
    [string]$ClientSecret,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Token")]
    [string]$AccessToken,
    
    [string]$Scope = "https://graph.microsoft.com/.default",
    
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

function Get-MicrosoftGraphToken {
    param(
        [string]$Tid,
        [string]$Cid,
        [string]$Csec,
        [string]$Scope
    )
    
    Write-TestLog "Acquiring Microsoft Graph access token..." -Level "Info"
    
    $tokenUrl = "https://login.microsoftonline.com/$Tid/oauth2/v2.0/token"
    
    $body = @{
        client_id = $Cid
        scope = $Scope
        client_secret = $Csec
        grant_type = "client_credentials"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
        
        Write-TestLog "Access token acquired successfully" -Level "Success"
        
        return @{
            Success = $true
            AccessToken = $response.access_token
            ExpiresIn = $response.expires_in
        }
    }
    catch {
        Write-TestLog "Failed to acquire access token: $($_.Exception.Message)" -Level "Error"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Test-SingleGraphEndpoint {
    param(
        [string]$EndpointName,
        [string]$EndpointUrl,
        [string]$EndpointMethod,
        [object]$EndpointBody,
        [string]$Token,
        [string]$Tid,
        [string]$Cid,
        [string]$Csec,
        [string]$EpScope,
        [int]$EndpointExpectedStatus
    )
    
    $testName = if ($EndpointName) { $EndpointName } else { $EndpointUrl }
    Write-TestLog "Testing Microsoft Graph endpoint: $testName" -Level "Info"
    Write-TestLog "  URL: $EndpointUrl" -Level "Info"
    Write-TestLog "  Method: $EndpointMethod" -Level "Info"
    
    if (-not $Token -and $Tid -and $Cid -and $Csec) {
        $tokenResult = Get-MicrosoftGraphToken -Tid $Tid -Cid $Cid -Csec $Csec -Scope $EpScope
        
        if (-not $tokenResult.Success) {
            return @{
                Name = $testName
                Result = @{Success = $false; Error = $tokenResult.Error}
                ExpectedStatusCode = $EndpointExpectedStatus
                Success = $false
            }
        }
        
        $Token = $tokenResult.AccessToken
    }
    
    $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $Token"
        "Accept" = "application/json"
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
        if ($EndpointBody -is [hashtable] -or $EndpointBody -is [PSCustomObject]) {
            $params.Body = $EndpointBody | ConvertTo-Json -Depth 10
        }
        else {
            $params.Body = $EndpointBody.ToString()
        }
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
    Write-TestLog "=== Loading Graph endpoints from config ===" -Level "Info"
    
    if (-not $defaults) {
        Write-TestLog "Could not load config. Use inline parameters." -Level "Error"
        exit 1
    }
    
    if (-not $defaults.Endpoints.graphEndpoints) {
        Write-TestLog "No graphEndpoints defined in config." -Level "Error"
        exit 1
    }
    
    foreach ($endpoint in $defaults.Endpoints.graphEndpoints) {
        $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
        
        $epName = if ($endpoint.name) { $endpoint.name } else { $null }
        $epUrl = if ($endpoint.url) { $endpoint.url } else { $null }
        $epMethod = if ($endpoint.method) { $endpoint.method } else { "GET" }
        $epBody = if ($endpoint.body) { $endpoint.body } else { $null }
        $epToken = if ($endpoint.accessToken) { $endpoint.accessToken } else { $null }
        $epTid = if ($endpoint.tenantId) { $endpoint.tenantId } else { $null }
        $epCid = if ($endpoint.clientId) { $endpoint.clientId } else { $null }
        $epCsec = if ($endpoint.clientSecret) { $endpoint.clientSecret } else { $null }
        $epScope = if ($endpoint.scope) { $endpoint.scope } else { "https://graph.microsoft.com/.default" }
        $epExpected = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
        
        if ($epUrl) {
            $result = Test-SingleGraphEndpoint `
                -EndpointName $epName `
                -EndpointUrl $epUrl `
                -EndpointMethod $epMethod `
                -EndpointBody $epBody `
                -Token $epToken `
                -Tid $epTid `
                -Cid $epCid `
                -Csec $epCsec `
                -EpScope $epScope `
                -EndpointExpectedStatus $epExpected
            
            $results += $result
        }
    }
}
else {
    if (-not $Url) {
        $Url = "https://graph.microsoft.com/v1.0$Endpoint"
    }
    
    if (-not $Name) {
        $Name = $Endpoint
    }
    
    $result = Test-SingleGraphEndpoint `
        -EndpointName $Name `
        -EndpointUrl $Url `
        -EndpointMethod $Method `
        -EndpointBody $Body `
        -Token $AccessToken `
        -Tid $TenantId `
        -Cid $ClientId `
        -Csec $ClientSecret `
        -EpScope $Scope `
        -EndpointExpectedStatus $ExpectedStatusCode
    
    $results += $result
}

Write-TestLog "=== Microsoft Graph Endpoint Test Summary ===" -Level "Info"
$passed = ($results | Where-Object { $_.Success }).Count
$failed = ($results | Where-Object { -not $_.Success }).Count
Write-TestLog "Total: $($results.Count) | Passed: $passed | Failed: $failed" -Level $(if ($failed -eq 0) { "Success" } else { "Warning" })

if ($PassThru) {
    return $results
}

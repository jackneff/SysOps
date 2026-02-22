<#
.SYNOPSIS
    Tests GraphQL API endpoints.

.DESCRIPTION
    Tests GraphQL API endpoints with queries, mutations, and variables.
    Supports Bearer token and API key authentication.
    Can load endpoints from settings.json or accept inline parameters.

.PARAMETER Name
    Display name for the endpoint (used in logging).

.PARAMETER Url
    Full URL of the GraphQL endpoint.

.PARAMETER Query
    GraphQL query string.

.PARAMETER Variables
    GraphQL variables as a hashtable.

.PARAMETER OperationName
    GraphQL operation name (for multiple operations).

.PARAMETER Method
    HTTP method: POST or GET. Default: POST.

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
    .\Test-GraphQlEndpoint.ps1 -Url "https://api.example.com/graphql" -Query "{ users { id name email } }"

.EXAMPLE
    .\Test-GraphQlEndpoint.ps1 -Url "https://api.example.com/graphql" -Query "mutation CreateUser($name: String!) { createUser(name: $name) { id } }" -Variables @{name="John"}

.EXAMPLE
    .\Test-GraphQlEndpoint.ps1 -Url "https://api.github.com/graphql" -Query "{ viewer { login } }" -BearerToken "xxx"

.EXAMPLE
    .\Test-GraphQlEndpoint.ps1 -UseConfig
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Name,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Inline")]
    [string]$Url,
    
    [Parameter(Mandatory = $true, ParameterSetName = "Inline")]
    [string]$Query,
    
    [hashtable]$Variables = @{},
    
    [string]$OperationName,
    
    [ValidateSet("POST", "GET")]
    [string]$Method = "POST",
    
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

function New-GraphQlPayload {
    param(
        [string]$Query,
        [hashtable]$Vars,
        [string]$OpName
    )
    
    $payload = @{
        query = $Query
    }
    
    if ($Vars.Count -gt 0) {
        $payload.variables = $Vars
    }
    
    if ($OpName) {
        $payload.operationName = $OpName
    }
    
    return $payload
}

function Test-SingleGraphQlEndpoint {
    param(
        [string]$EndpointName,
        [string]$EndpointUrl,
        [string]$EndpointQuery,
        [hashtable]$EndpointVariables,
        [string]$EndpointOperationName,
        [string]$EndpointMethod,
        [string]$EpApiKey,
        [string]$EpApiKeyHeader,
        [string]$EpBearerToken,
        [string]$EpUsername,
        [string]$EpPassword,
        [int]$EndpointExpectedStatus
    )
    
    $testName = if ($EndpointName) { $EndpointName } else { "GraphQL Query" }
    Write-TestLog "Testing GraphQL endpoint: $testName" -Level "Info"
    Write-TestLog "  URL: $EndpointUrl" -Level "Info"
    Write-TestLog "  Method: $EndpointMethod" -Level "Info"
    Write-TestLog "  Query: $($EndpointQuery.Substring(0, [Math]::Min(100, $EndpointQuery.Length)))..." -Level "Info"
    
    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }
    
    if ($EpApiKey) {
        $headerName = if ($EpApiKeyHeader) { $EpApiKeyHeader } else { "X-API-Key" }
        $headers[$headerName] = $EpApiKey
    }
    
    if ($EpBearerToken) {
        $headers["Authorization"] = "Bearer $EpBearerToken"
    }
    
    if ($EpUsername -and $EpPassword) {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$EpUsername`:$EpPassword"))
        $headers["Authorization"] = "Basic $encoded"
    }
    
    $payload = New-GraphQlPayload -Query $EndpointQuery -Vars $EndpointVariables -OpName $EndpointOperationName
    $bodyString = $payload | ConvertTo-Json -Depth 10
    
    if ($EndpointMethod -eq "GET") {
        $encodedQuery = [System.Web.HttpUtility]::UrlEncode($EndpointQuery)
        $encodedVars = [System.Web.HttpUtility]::UrlEncode(($EndpointVariables | ConvertTo-Json -Depth 10))
        $finalUrl = "$EndpointUrl`?query=$encodedQuery&variables=$encodedVars"
        
        $params = @{
            Url = $finalUrl
            Method = "GET"
            Headers = $headers
            TimeoutSeconds = $TimeoutSeconds
            EnableRetry = $EnableRetry
            RetryCount = $RetryCount
            RetryDelayMs = $RetryDelayMs
            SkipSslValidation = $SkipSslValidation
            PassThru = $true
        }
    }
    else {
        $params = @{
            Url = $EndpointUrl
            Method = "POST"
            Headers = $headers
            Body = $bodyString
            ContentType = "application/json"
            TimeoutSeconds = $TimeoutSeconds
            EnableRetry = $EnableRetry
            RetryCount = $RetryCount
            RetryDelayMs = $RetryDelayMs
            SkipSslValidation = $SkipSslValidation
            PassThru = $true
        }
    }
    
    $result = Invoke-WebRequestEx @params
    
    $statusIcon = if ($result.Success) { "[OK]" } else { "[FAIL]" }
    $statusLevel = if ($result.Success) { "Success" } else { "Error" }
    Write-TestLog "$statusIcon $testName - Status: $($result.StatusCode) ($($result.StatusDescription)) in $($result.ResponseTimeMs)ms" -Level $statusLevel
    
    if ($result.StatusCode -ne $EndpointExpectedStatus) {
        Write-TestLog "  WARNING: Expected status $EndpointExpectedStatus but got $($result.StatusCode)" -Level "Warning"
    }
    
    if ($result.Success -and $result.Content) {
        try {
            $jsonResponse = $result.Content | ConvertFrom-Json
            
            if ($jsonResponse.errors) {
                Write-TestLog "  GraphQL Errors detected:" -Level "Error"
                foreach ($err in $jsonResponse.errors) {
                    Write-TestLog "    - $($err.message)" -Level "Error"
                }
            }
            elseif ($jsonResponse.data) {
                Write-TestLog "  GraphQL Response: Valid with data" -Level "Success"
            }
        }
        catch {
            Write-TestLog "  Response parsing: Could not parse as JSON" -Level "Warning"
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
    Write-TestLog "=== Loading GraphQL endpoints from config ===" -Level "Info"
    
    if (-not $defaults) {
        Write-TestLog "Could not load config. Use inline parameters." -Level "Error"
        exit 1
    }
    
    if (-not $defaults.Endpoints.graphqlEndpoints) {
        Write-TestLog "No graphqlEndpoints defined in config." -Level "Error"
        exit 1
    }
    
    foreach ($endpoint in $defaults.Endpoints.graphqlEndpoints) {
        $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
        
        $epName = if ($endpoint.name) { $endpoint.name } else { $null }
        $epUrl = if ($endpoint.url) { $endpoint.url } else { $null }
        $epQuery = if ($endpoint.query) { $endpoint.query } else { $null }
        $epVars = if ($endpoint.variables) { $endpoint.variables } else { @{} }
        $epOpName = if ($endpoint.operationName) { $endpoint.operationName } else { $null }
        $epMethod = if ($endpoint.method) { $endpoint.method } else { "POST" }
        $epApiKey = if ($endpoint.apiKey) { $endpoint.apiKey } else { $null }
        $epApiKeyHeader = if ($endpoint.apiKeyHeader) { $endpoint.apiKeyHeader } else { "X-API-Key" }
        $epBearer = if ($endpoint.bearerToken) { $endpoint.bearerToken } else { $null }
        $epUser = if ($endpoint.username) { $endpoint.username } else { $null }
        $epPass = if ($endpoint.password) { $endpoint.password } else { $null }
        $epExpected = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
        
        if ($epUrl -and $epQuery) {
            $result = Test-SingleGraphQlEndpoint `
                -EndpointName $epName `
                -EndpointUrl $epUrl `
                -EndpointQuery $epQuery `
                -EndpointVariables $epVars `
                -EndpointOperationName $epOpName `
                -EndpointMethod $epMethod `
                -EpApiKey $epApiKey `
                -EpApiKeyHeader $epApiKeyHeader `
                -EpBearerToken $epBearer `
                -EpUsername $epUser `
                -EpPassword $epPass `
                -EndpointExpectedStatus $epExpected
            
            $results += $result
        }
    }
}
else {
    if (-not $Name) {
        $Name = "GraphQL Query"
    }
    
    $result = Test-SingleGraphQlEndpoint `
        -EndpointName $Name `
        -EndpointUrl $Url `
        -EndpointQuery $Query `
        -EndpointVariables $Variables `
        -EndpointOperationName $OperationName `
        -EndpointMethod $Method `
        -EpApiKey $ApiKey `
        -EpApiKeyHeader $ApiKeyHeader `
        -EpBearerToken $BearerToken `
        -EpUsername $Username `
        -EpPassword $Password `
        -EndpointExpectedStatus $ExpectedStatusCode
    
    $results += $result
}

Write-TestLog "=== GraphQL Endpoint Test Summary ===" -Level "Info"
$passed = ($results | Where-Object { $_.Success }).Count
$failed = ($results | Where-Object { -not $_.Success }).Count
Write-TestLog "Total: $($results.Count) | Passed: $passed | Failed: $failed" -Level $(if ($failed -eq 0) { "Success" } else { "Warning" })

if ($PassThru) {
    return $results
}

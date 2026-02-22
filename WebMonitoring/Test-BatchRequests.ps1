<#
.SYNOPSIS
    Runs batch tests for all configured endpoints.

.DESCRIPTION
    Loads all endpoint configurations from settings.json and runs tests for:
    - REST endpoints
    - SOAP endpoints
    - Microsoft Graph endpoints
    - GraphQL endpoints
    
    Generates a comprehensive summary report.

.PARAMETER Type
    Filter by endpoint type: REST, SOAP, Graph, GraphQL, or ALL.

.PARAMETER Name
    Run only specific endpoint by name.

.PARAMETER EnableRetry
    Enable retry for all requests.

.PARAMETER SkipSslValidation
    Skip SSL certificate validation for all requests.

.PARAMETER PassThru
    Return detailed result object.

.PARAMETER OutputPath
    Save results to JSON file.

.EXAMPLE
    .\Test-BatchRequests.ps1

.EXAMPLE
    .\Test-BatchRequests.ps1 -Type REST

.EXAMPLE
    .\Test-BatchRequests.ps1 -Name "Users API"

.EXAMPLE
    .\Test-BatchRequests.ps1 -OutputPath "C:\Reports\webtests.json"
#>

[CmdletBinding()]
param(
    [ValidateSet("REST", "SOAP", "Graph", "GraphQL", "ALL")]
    [string]$Type = "ALL",
    
    [string]$Name,
    
    [switch]$EnableRetry,
    
    [switch]$SkipSslValidation,
    
    [switch]$PassThru,
    
    [string]$OutputPath,
    
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
if (-not $defaults) {
    Write-Error "Could not load configuration from settings.json"
    exit 1
}

$logPath = $defaults.Defaults.logPath

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

Write-TestLog "=== Starting Batch Web Endpoint Tests ===" -Level "Info"
Write-TestLog "Type Filter: $Type" -Level "Info"
Write-TestLog "Name Filter: $(if ($Name) { $Name } else { 'All' })" -Level "Info"

$allResults = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Type = $Type
    NameFilter = $Name
    Results = @()
}

$totalPassed = 0
$totalFailed = 0

if ($Type -eq "ALL" -or $Type -eq "REST") {
    Write-TestLog "`n=== Testing REST Endpoints ===" -Level "Info"
    
    if ($defaults.Endpoints.restEndpoints) {
        foreach ($endpoint in $defaults.Endpoints.restEndpoints) {
            $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
            
            if ($Name -and $endpoint.name -ne $Name) { continue }
            
            Write-TestLog "Running: $($endpoint.name)" -Level "Info"
            
            $params = @{
                Url = $endpoint.url
                Method = if ($endpoint.method) { $endpoint.method } else { "GET" }
                ExpectedStatusCode = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
                EnableRetry = $EnableRetry
                SkipSslValidation = $SkipSslValidation
                PassThru = $true
                LogToConsoleOnly = $LogToConsoleOnly
                LogToFileOnly = $LogToFileOnly
            }
            
            if ($endpoint.apiKey) { $params.ApiKey = $endpoint.apiKey }
            if ($endpoint.apiKeyHeader) { $params.ApiKeyHeader = $endpoint.apiKeyHeader }
            if ($endpoint.bearerToken) { $params.BearerToken = $endpoint.bearerToken }
            if ($endpoint.username) { $params.Username = $endpoint.username }
            if ($endpoint.password) { $params.Password = $endpoint.password }
            if ($endpoint.body) { $params.Body = $endpoint.body }
            
            try {
                $result = & "$PSScriptRoot\Test-RestEndpoint.ps1" @params
                
                if ($result.Success) { $totalPassed++ } else { $totalFailed++ }
                
                $allResults.Results += @{
                    Type = "REST"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $result.Success
                    StatusCode = $result.Result.StatusCode
                    ResponseTimeMs = $result.Result.ResponseTimeMs
                    Error = $result.Result.Error
                }
            }
            catch {
                Write-TestLog "Error running REST endpoint: $($_.Exception.Message)" -Level "Error"
                $totalFailed++
                $allResults.Results += @{
                    Type = "REST"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
        }
    }
    else {
        Write-TestLog "No REST endpoints configured" -Level "Warning"
    }
}

if ($Type -eq "ALL" -or $Type -eq "SOAP") {
    Write-TestLog "`n=== Testing SOAP Endpoints ===" -Level "Info"
    
    if ($defaults.Endpoints.soapEndpoints) {
        foreach ($endpoint in $defaults.Endpoints.soapEndpoints) {
            $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
            
            if ($Name -and $endpoint.name -ne $Name) { continue }
            
            Write-TestLog "Running: $($endpoint.name)" -Level "Info"
            
            $params = @{
                Url = $endpoint.url
                Action = $endpoint.action
                ExpectedStatusCode = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
                EnableRetry = $EnableRetry
                SkipSslValidation = $SkipSslValidation
                PassThru = $true
                LogToConsoleOnly = $LogToConsoleOnly
                LogToFileOnly = $LogToFileOnly
            }
            
            if ($endpoint.namespace) { $params.Namespace = $endpoint.namespace }
            if ($endpoint.version) { $params.Version = $endpoint.version }
            if ($endpoint.username) { $params.Username = $endpoint.username }
            if ($endpoint.password) { $params.Password = $endpoint.password }
            if ($endpoint.bodyParams) { $params.BodyParams = $endpoint.bodyParams }
            
            try {
                $result = & "$PSScriptRoot\Test-SoapEndpoint.ps1" @params
                
                if ($result.Success) { $totalPassed++ } else { $totalFailed++ }
                
                $allResults.Results += @{
                    Type = "SOAP"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Action = $endpoint.action
                    Success = $result.Success
                    StatusCode = $result.Result.StatusCode
                    ResponseTimeMs = $result.Result.ResponseTimeMs
                    Error = $result.Result.Error
                }
            }
            catch {
                Write-TestLog "Error running SOAP endpoint: $($_.Exception.Message)" -Level "Error"
                $totalFailed++
                $allResults.Results += @{
                    Type = "SOAP"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
        }
    }
    else {
        Write-TestLog "No SOAP endpoints configured" -Level "Warning"
    }
}

if ($Type -eq "ALL" -or $Type -eq "Graph") {
    Write-TestLog "`n=== Testing Microsoft Graph Endpoints ===" -Level "Info"
    
    if ($defaults.Endpoints.graphEndpoints) {
        foreach ($endpoint in $defaults.Endpoints.graphEndpoints) {
            $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
            
            if ($Name -and $endpoint.name -ne $Name) { continue }
            
            Write-TestLog "Running: $($endpoint.name)" -Level "Info"
            
            $params = @{
                Url = $endpoint.url
                ExpectedStatusCode = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
                EnableRetry = $EnableRetry
                SkipSslValidation = $SkipSslValidation
                PassThru = $true
                LogToConsoleOnly = $LogToConsoleOnly
                LogToFileOnly = $LogToFileOnly
            }
            
            if ($endpoint.tenantId) { $params.TenantId = $endpoint.tenantId }
            if ($endpoint.clientId) { $params.ClientId = $endpoint.clientId }
            if ($endpoint.clientSecret) { $params.ClientSecret = $endpoint.clientSecret }
            if ($endpoint.accessToken) { $params.AccessToken = $endpoint.accessToken }
            if ($endpoint.scope) { $params.Scope = $endpoint.scope }
            if ($endpoint.method) { $params.Method = $endpoint.method }
            if ($endpoint.body) { $params.Body = $endpoint.body }
            
            try {
                $result = & "$PSScriptRoot\Test-GraphEndpoint.ps1" @params
                
                if ($result.Success) { $totalPassed++ } else { $totalFailed++ }
                
                $allResults.Results += @{
                    Type = "Graph"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $result.Success
                    StatusCode = $result.Result.StatusCode
                    ResponseTimeMs = $result.Result.ResponseTimeMs
                    Error = $result.Result.Error
                }
            }
            catch {
                Write-TestLog "Error running Graph endpoint: $($_.Exception.Message)" -Level "Error"
                $totalFailed++
                $allResults.Results += @{
                    Type = "Graph"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
        }
    }
    else {
        Write-TestLog "No Graph endpoints configured" -Level "Warning"
    }
}

if ($Type -eq "ALL" -or $Type -eq "GraphQL") {
    Write-TestLog "`n=== Testing GraphQL Endpoints ===" -Level "Info"
    
    if ($defaults.Endpoints.graphqlEndpoints) {
        foreach ($endpoint in $defaults.Endpoints.graphqlEndpoints) {
            $endpoint = Resolve-EnvironmentVariables -InputObject $endpoint
            
            if ($Name -and $endpoint.name -ne $Name) { continue }
            
            Write-TestLog "Running: $($endpoint.name)" -Level "Info"
            
            $params = @{
                Url = $endpoint.url
                Query = $endpoint.query
                ExpectedStatusCode = if ($endpoint.expectedStatusCode) { $endpoint.expectedStatusCode } else { 200 }
                EnableRetry = $EnableRetry
                SkipSslValidation = $SkipSslValidation
                PassThru = $true
                LogToConsoleOnly = $LogToConsoleOnly
                LogToFileOnly = $LogToFileOnly
            }
            
            if ($endpoint.variables) { $params.Variables = $endpoint.variables }
            if ($endpoint.operationName) { $params.OperationName = $endpoint.operationName }
            if ($endpoint.method) { $params.Method = $endpoint.method }
            if ($endpoint.apiKey) { $params.ApiKey = $endpoint.apiKey }
            if ($endpoint.bearerToken) { $params.BearerToken = $endpoint.bearerToken }
            if ($endpoint.username) { $params.Username = $endpoint.username }
            if ($endpoint.password) { $params.Password = $endpoint.password }
            
            try {
                $result = & "$PSScriptRoot\Test-GraphQlEndpoint.ps1" @params
                
                if ($result.Success) { $totalPassed++ } else { $totalFailed++ }
                
                $allResults.Results += @{
                    Type = "GraphQL"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $result.Success
                    StatusCode = $result.Result.StatusCode
                    ResponseTimeMs = $result.Result.ResponseTimeMs
                    Error = $result.Result.Error
                }
            }
            catch {
                Write-TestLog "Error running GraphQL endpoint: $($_.Exception.Message)" -Level "Error"
                $totalFailed++
                $allResults.Results += @{
                    Type = "GraphQL"
                    Name = $endpoint.name
                    Url = $endpoint.url
                    Success = $false
                    Error = $_.Exception.Message
                }
            }
        }
    }
    else {
        Write-TestLog "No GraphQL endpoints configured" -Level "Warning"
    }
}

Write-TestLog "`n=== Batch Test Summary ===" -Level "Info"
Write-TestLog "Total: $($totalPassed + $totalFailed) | Passed: $totalPassed | Failed: $totalFailed" -Level $(if ($totalFailed -eq 0) { "Success" } else { "Warning" })

$allResults.TotalPassed = $totalPassed
$allResults.TotalFailed = $totalFailed

if ($OutputPath) {
    $allResults | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-TestLog "Results saved to: $OutputPath" -Level "Info"
}

if ($PassThru) {
    return $allResults
}

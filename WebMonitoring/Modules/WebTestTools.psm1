function Get-WebTestConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$ConfigPath = "$PSScriptRoot\..\..\Config\settings.json"
    )
    
    if (-not (Test-Path $ConfigPath)) {
        Write-Warning "Config file not found: $ConfigPath"
        return $null
    }
    
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    
    if (-not $config.webTests) {
        Write-Warning "No webTests section found in config"
        return $null
    }
    
    $defaults = @{
        timeoutSeconds = 30
        retryEnabled = $false
        retryCount = 3
        retryDelayMs = 1000
        validateSsl = $true
        logToFile = $true
        logPath = "$PSScriptRoot\..\..\Logs\WebTests"
    }
    
    if ($config.webTestDefaults) {
        foreach ($key in $config.webTestDefaults.PSObject.Properties.Name) {
            $defaults[$key] = $config.webTestDefaults.$key
        }
    }
    
    return @{
        Endpoints = $config.webTests
        Defaults = $defaults
    }
}

function Resolve-EnvironmentVariables {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject
    )
    
    if ($InputObject -is [string]) {
        $str = $InputObject
        $pattern = '\$\{([^}]+)\}'
        
        if ($str -match $pattern) {
            $varName = $matches[1]
            $envValue = [Environment]::GetEnvironmentVariable($varName)
            if ($null -ne $envValue) {
                return $str -replace [regex]::Escape($matches[0]), $envValue
            }
        }
        return $str
    }
    
    if ($InputObject -is [hashtable]) {
        $result = @{}
        foreach ($key in $InputObject.Keys) {
            $result[$key] = Resolve-EnvironmentVariables -InputObject $InputObject[$key]
        }
        return $result
    }
    
    if ($InputObject -is [PSCustomObject]) {
        $result = [PSCustomObject]@{}
        foreach ($prop in $InputObject.PSObject.Properties) {
            $result | Add-Member -NotePropertyName $prop.Name -NotePropertyValue (Resolve-EnvironmentVariables -InputObject $prop.Value)
        }
        return $result
    }
    
    return $InputObject
}

function Invoke-WebRequestEx {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        
        [ValidateSet("GET", "POST", "PATCH", "PUT", "DELETE", "HEAD", "OPTIONS")]
        [string]$Method = "GET",
        
        [hashtable]$Headers = @{},
        
        [object]$Body,
        
        [string]$ContentType = "application/json",
        
        [int]$TimeoutSeconds = 30,
        
        [switch]$EnableRetry,
        
        [int]$RetryCount = 3,
        
        [int]$RetryDelayMs = 1000,
        
        [switch]$SkipSslValidation,
        
        [switch]$PassThru
    )
    
    $startTime = Get-Date
    $result = @{
        Url = $Url
        Method = $Method
        Success = $false
        StatusCode = $null
        StatusDescription = $null
        ResponseTimeMs = $null
        ResponseHeaders = $null
        Content = $null
        Error = $null
        Timestamp = $startTime
    }
    
    if ($Body -and $Method -ne "GET") {
        if ($Body -is [hashtable] -or $Body -is [PSCustomObject]) {
            $Headers["Content-Type"] = $ContentType
            $bodyString = $Body | ConvertTo-Json -Depth 10
        }
        elseif ($Body -is [string]) {
            $bodyString = $Body
        }
        else {
            $bodyString = $Body.ToString()
        }
    }
    
    $sslHandler = if ($SkipSslValidation) {
        [System.Net.Security.RemoteCertificateValidationCallback]{ return $true }
    }
    
    try {
        $params = @{
            Uri = $Url
            Method = $Method
            TimeoutSec = $TimeoutSeconds
        }
        
        if ($Headers.Count -gt 0) {
            $params.Headers = $Headers
        }
        
        if ($bodyString) {
            $params.Body = $bodyString
        }
        
        if ($SkipSslValidation) {
            $params.SkipCertificateCheck = $true
        }
        
        $attempt = 0
        $maxAttempts = if ($EnableRetry) { $RetryCount } else { 1 }
        
        while ($attempt -lt $maxAttempts) {
            $attempt++
            
            try {
                if ($attempt -gt 1) {
                    Write-Host "Retry attempt $attempt of $maxAttempts..." -ForegroundColor Yellow
                    Start-Sleep -Milliseconds $RetryDelayMs
                }
                
                $response = Invoke-WebRequest @params -ErrorAction Stop
                
                $result.Success = $true
                $result.StatusCode = [int]$response.StatusCode
                $result.StatusDescription = $response.StatusDescription
                $result.ResponseTimeMs = [int](((Get-Date) - $startTime).TotalMilliseconds)
                $result.ResponseHeaders = $response.Headers
                $result.Content = $response.Content
                
                break
            }
            catch {
                if ($attempt -ge $maxAttempts) {
                    throw $_
                }
            }
        }
    }
    catch {
        $result.Success = $false
        $result.Error = $_.Exception.Message
        $result.ResponseTimeMs = [int](((Get-Date) - $startTime).TotalMilliseconds)
    }
    
    if ($PassThru) {
        return [PSCustomObject]$result
    }
    
    return $result
}

function New-SoapEnvelope {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Action,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$BodyParams,
        
        [string]$Namespace,
        
        [string]$NamespacePrefix = "ns"
    )
    
    $bodyXml = ""
    foreach ($key in $BodyParams.Keys) {
        $bodyXml += "<$key>$($BodyParams[$key])</$key>"
    }
    
    if ($Namespace) {
        $nsAttr = " xmlns:$NamespacePrefix=`"$Namespace`""
    }
    
    $envelope = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"$nsAttr>
  <soap:Header/>
  <soap:Body>
    <$Action>
      $bodyXml
    </$Action>
  </soap:Body>
</soap:Envelope>
"@
    
    return $envelope
}

function New-GraphQlQuery {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Query,
        
        [hashtable]$Variables = @{},
        
        [string]$OperationName
    )
    
    $queryObj = @{
        query = $Query
    }
    
    if ($Variables.Count -gt 0) {
        $queryObj.variables = $Variables
    }
    
    if ($OperationName) {
        $queryObj.operationName = $OperationName
    }
    
    return $queryObj | ConvertTo-Json -Depth 10
}

function ConvertTo-GraphHeaders {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AccessToken,
        
        [string]$ContentType = "application/json"
    )
    
    return @{
        "Content-Type" = $ContentType
        "Authorization" = "Bearer $AccessToken"
        "Accept" = "application/json"
    }
}

function Get-GraphToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TenantId,
        
        [Parameter(Mandatory = $true)]
        [string]$ClientId,
        
        [Parameter(Mandatory = $true)]
        [string]$ClientSecret,
        
        [string]$Scope = "https://graph.microsoft.com/.default"
    )
    
    $tokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    
    $body = @{
        client_id = $ClientId
        scope = $Scope
        client_secret = $ClientSecret
        grant_type = "client_credentials"
    }
    
    try {
        $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -ContentType "application/x-www-form-urlencoded" -ErrorAction Stop
        
        return @{
            Success = $true
            AccessToken = $response.access_token
            ExpiresIn = $response.expires_in
            TokenType = $response.token_type
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Write-WebTestLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Level = "Info",
        
        [string]$LogPath = "$PSScriptRoot\..\..\Logs\WebTests",
        
        [switch]$LogToFileOnly,
        
        [switch]$LogToConsoleOnly
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "White" }
    }
    
    if (-not $LogToFileOnly) {
        Write-Host $logEntry -ForegroundColor $color
    }
    
    if (-not $LogToConsoleOnly) {
        if (-not (Test-Path $LogPath)) {
            New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        }
        
        $logFile = Join-Path $LogPath "webtests_$(Get-Date -Format 'yyyyMMdd').log"
        Add-Content -Path $logFile -Value $logEntry
    }
}

function Test-JsonValid {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$JsonString
    )
    
    try {
        $null = $JsonString | ConvertFrom-Json
        return $true
    }
    catch {
        return $false
    }
}

function Get-AuthorizationHeader {
    [CmdletBinding()]
    param(
        [string]$ApiKey,
        [string]$ApiKeyHeader,
        [string]$BearerToken,
        [string]$Username,
        [string]$Password
    )
    
    $headers = @{}
    
    if ($ApiKey) {
        $headerName = if ($ApiKeyHeader) { $ApiKeyHeader } else { "X-API-Key" }
        $headers[$headerName] = $ApiKey
    }
    
    if ($BearerToken) {
        $headers["Authorization"] = "Bearer $BearerToken"
    }
    
    if ($Username -and $Password) {
        $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$Username`:$Password"))
        $headers["Authorization"] = "Basic $encoded"
    }
    
    return $headers
}

Export-ModuleMember -Function @(
    'Get-WebTestConfig',
    'Resolve-EnvironmentVariables',
    'Invoke-WebRequestEx',
    'New-SoapEnvelope',
    'New-GraphQlQuery',
    'ConvertTo-GraphHeaders',
    'Get-GraphToken',
    'Write-WebTestLog',
    'Test-JsonValid',
    'Get-AuthorizationHeader'
)

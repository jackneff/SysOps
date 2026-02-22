<#
.SYNOPSIS
    Extracts and displays text content from web pages.

.DESCRIPTION
    Fetches web page content and extracts readable text for console display or file output.
    Supports HTML, plain text, and JSON responses. Useful for scraping, searching, and analyzing web content.

.PARAMETER Url
    The URL of the web page to fetch.

.PARAMETER OutputFormat
    Output format: Console, Text, Html, or Json. Default: Console.

.PARAMETER OutputPath
    Path to save output file. If not specified, displays to console.

.PARAMETER SearchPattern
    Regex pattern to search for in the content. Highlights matches.

.PARAMETER SearchNotPattern
    Exclude lines matching this pattern.

.PARAMETER ContextLines
    Number of lines to show before and after matches. Default: 2.

.PARAMETER ShowUrls
    Extract and display all URLs found in the page.

.PARAMETER ShowEmails
    Extract and display all email addresses found in the page.

.PARAMETER TimeoutSeconds
    Request timeout in seconds. Default: 30.

.PARAMETER SkipSslValidation
    Skip SSL certificate validation.

.PARAMETER UserAgent
    Custom User-Agent string. Default: Mozilla/5.0 compatible.

.PARAMETER Headers
    Additional headers as a hashtable.

.EXAMPLE
    .\Get-WebContent.ps1 -Url "https://www.example.com"

.EXAMPLE
    .\Get-WebContent.ps1 -Url "https://www.example.com" -OutputFormat Text -OutputPath "page.txt"

.EXAMPLE
    .\Get-WebContent.ps1 -Url "https://www.example.com" -SearchPattern "error|warning" -ContextLines 3

.EXAMPLE
    .\Get-WebContent.ps1 -Url "https://www.example.com" -ShowUrls

.EXAMPLE
    .\Get-WebContent.ps1 -Url "https://api.example.com/data" -OutputFormat Json -OutputPath "data.json"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Url,
    
    [ValidateSet("Console", "Text", "Html", "Json")]
    [string]$OutputFormat = "Console",
    
    [string]$OutputPath,
    
    [string]$SearchPattern,
    
    [string]$SearchNotPattern,
    
    [int]$ContextLines = 2,
    
    [switch]$ShowUrls,
    
    [switch]$ShowEmails,
    
    [int]$TimeoutSeconds = 30,
    
    [switch]$SkipSslValidation,
    
    [string]$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    
    [hashtable]$Headers = @{}
)

$ErrorActionPreference = "Stop"

function Get-WebContent {
    param(
        [string]$TargetUrl,
        [string]$UA,
        [hashtable]$ReqHeaders,
        [int]$Timeout,
        [bool]$SkipSsl
    )
    
    $params = @{
        Uri = $TargetUrl
        Method = "GET"
        TimeoutSec = $Timeout
        UserAgent = $UA
    }
    
    if ($ReqHeaders.Count -gt 0) {
        $params.Headers = $ReqHeaders
    }
    
    if ($SkipSsl) {
        $params.SkipCertificateCheck = $true
    }
    
    try {
        $response = Invoke-WebRequest @params -ErrorAction Stop
        return @{
            Success = $true
            StatusCode = $response.StatusCode
            StatusDescription = $response.StatusDescription
            Content = $response.Content
            Headers = $response.Headers
            RawContent = $response.RawContent
        }
    }
    catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function ConvertTo-PlainText {
    param([string]$HtmlContent)
    
    $html = $HtmlContent
    
    $html = $html -replace '(?s)<script[^>]*>.*?</script>', ''
    $html = $html -replace '(?s)<style[^>]*>.*?</style>', ''
    $html = $html -replace '(?s)<!--.*?-->', ''
    $html = $html -replace '<br[^>]*>', "`n"
    $html = $html -replace '</p>', "`n`n"
    $html = $html -replace '</div>', "`n"
    $html = $html -replace '</h[1-6]>', "`n`n"
    $html = $html -replace '</li>', "`n"
    $html = $html -replace '</tr>', "`n"
    $html = $html -replace '<[^>]+>', ''
    $html = $html -replace '&nbsp;', ' '
    $html = $html -replace '&amp;', '&'
    $html = $html -replace '&lt;', '<'
    $html = $html -replace '&gt;', '>'
    $html = $html -replace '&quot;', '"'
    $html = $html -replace '&#39;', "'"
    $html = $html -replace '\s+', ' '
    
    $lines = $html -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    
    return ($lines -join "`n").Trim()
}

function Find-Urls {
    param([string]$Content)
    
    $pattern = '(https?://[^\s<>"{}|\\^`\[\]]+)'
    $matches = [regex]::Matches($Content, $pattern)
    
    $urls = @()
    foreach ($match in $matches) {
        $url = $match.Value.TrimEnd('.', ',', ';', ')', ']')
        if ($urls -notcontains $url) {
            $urls += $url
        }
    }
    
    return $urls
}

function Find-Emails {
    param([string]$Content)
    
    $pattern = '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    $matches = [regex]::Matches($Content, $pattern)
    
    $emails = @()
    foreach ($match in $matches) {
        if ($emails -notcontains $match.Value) {
            $emails += $match.Value
        }
    }
    
    return $emails
}

function Search-Content {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$NotPattern,
        [int]$Context
    )
    
    $lines = $Content -split "`n"
    $results = @()
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $include = $true
        
        if ($NotPattern -and $line -match $NotPattern) {
            $include = $false
        }
        
        if ($Pattern) {
            if ($line -match $Pattern) {
                if ($Context -gt 0) {
                    $start = [Math]::Max(0, $i - $Context)
                    $end = [Math]::Min($lines.Count - 1, $i + $Context)
                    
                    for ($j = $start; $j -le $end; $j++) {
                        $contextLine = $lines[$j]
                        if ($j -eq $i) {
                            $results += ">>> $($contextLine)"
                        }
                        else {
                            $results += "    $($contextLine)"
                        }
                    }
                    $results += ""
                }
                else {
                    $results += $line
                }
            }
        }
        elseif ($include) {
            $results += $line
        }
    }
    
    return $results
}

function Write-ColoredOutput {
    param(
        [string[]]$Lines,
        [string]$HighlightPattern
    )
    
    foreach ($line in $Lines) {
        if ($HighlightPattern -and $line -match $HighlightPattern) {
            $highlighted = $line -replace "($HighlightPattern)", '$1'
            Write-Host $highlighted -ForegroundColor Yellow
        }
        else {
            Write-Host $line
        }
    }
}

Write-Host "Fetching: $Url" -ForegroundColor Cyan

$webResult = Get-WebContent -TargetUrl $Url -UA $UserAgent -ReqHeaders $Headers -Timeout $TimeoutSeconds -SkipSsl $SkipSslValidation

if (-not $webResult.Success) {
    Write-Error "Failed to fetch URL: $($webResult.Error)"
    exit 1
}

Write-Host "Status: $($webResult.StatusCode) $($webResult.StatusDescription)" -ForegroundColor Green

$contentType = $webResult.Headers["Content-Type"]
$content = $webResult.Content

if ($contentType -match 'application/json') {
    try {
        $jsonObj = $content | ConvertFrom-Json
        $content = $jsonObj | ConvertTo-Json -Depth 10
    }
    catch {
        Write-Warning "Could not parse as JSON"
    }
}

$plainText = if ($contentType -match 'text/html') {
    ConvertTo-PlainText -HtmlContent $content
}
else {
    $content
}

$output = $null

if ($SearchPattern -or $SearchNotPattern) {
    $output = Search-Content -Content $plainText -Pattern $SearchPattern -NotPattern $SearchNotPattern -Context $ContextLines
    
    if ($SearchPattern) {
        Write-Host "`n=== Search Results for: $SearchPattern ===" -ForegroundColor Cyan
        $matchCount = ($output | Where-Object { $_ -match '>>>' }).Count
        Write-Host "Matches found: $matchCount" -ForegroundColor Yellow
    }
}
else {
    $output = $plainText -split "`n"
}

if ($ShowUrls) {
    $urls = Find-Urls -Content $content
    Write-Host "`n=== URLs Found ($($urls.Count)) ===" -ForegroundColor Cyan
    $urls | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
}

if ($ShowEmails) {
    $emails = Find-Emails -Content $content
    Write-Host "`n=== Email Addresses Found ($($emails.Count)) ===" -ForegroundColor Cyan
    $emails | ForEach-Object { Write-Host $_ -ForegroundColor Gray }
}

switch ($OutputFormat) {
    "Console" {
        Write-Host "`n=== Page Content ===" -ForegroundColor Cyan
        Write-ColoredOutput -Lines $output -HighlightPattern $SearchPattern
    }
    "Text" {
        if ($OutputPath) {
            $output -join "`n" | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "Saved to: $OutputPath" -ForegroundColor Green
        }
        else {
            $output | Out-File -Encoding UTF8
        }
    }
    "Html" {
        $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Web Content - $Url</title>
    <style>
        body { font-family: Consolas, monospace; padding: 20px; max-width: 1200px; margin: 0 auto; }
        .highlight { background-color: yellow; }
        .url { color: #0066cc; }
        h1 { color: #333; }
        pre { white-space: pre-wrap; word-wrap: break-word; }
    </style>
</head>
<body>
    <h1>Source: $Url</h1>
    <p>Fetched: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    <pre>$([System.Web.HttpUtility]::HtmlEncode($output -join "`n"))</pre>
</body>
</html>
"@
        
        if ($OutputPath) {
            $htmlContent | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "Saved to: $OutputPath" -ForegroundColor Green
        }
        else {
            $htmlContent | Out-File -Encoding UTF8
        }
    }
    "Json" {
        $jsonOutput = @{
            url = $Url
            fetchedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            statusCode = $webResult.StatusCode
            contentType = $contentType
            content = $plainText
            urls = if ($ShowUrls) { Find-Urls -Content $content } else { @() }
            emails = if ($ShowEmails) { Find-Emails -Content $content } else { @() }
            searchMatches = if ($SearchPattern) { $output } else { @() }
        } | ConvertTo-Json -Depth 10
        
        if ($OutputPath) {
            $jsonOutput | Out-File -FilePath $OutputPath -Encoding UTF8
            Write-Host "Saved to: $OutputPath" -ForegroundColor Green
        }
        else {
            $jsonOutput | ConvertTo-Json -Depth 10
        }
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "Total lines: $($output.Count)"
Write-Host "Content length: $($plainText.Length) characters"

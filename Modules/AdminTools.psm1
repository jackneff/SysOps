function Get-Config {
    [CmdletBinding()]
    param(
        [string]$ConfigPath = "$PSScriptRoot\..\Config\settings.json"
    )
    
    if (Test-Path $ConfigPath) {
        return Get-Content $ConfigPath -Raw | ConvertFrom-Json
    }
    else {
        Write-Warning "Config file not found at: $ConfigPath"
        return $null
    }
}

function Test-ServerReachability {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [int]$Timeout = 5000
    )
    
    try {
        $Ping = Test-Connection -ComputerName $ComputerName -Count 1 -TimeoutSeconds ($Timeout / 1000) -ErrorAction Stop
        return @{
            ComputerName = $ComputerName
            Reachable    = $true
            Latency      = $Ping.ResponseTime
        }
    }
    catch {
        return @{
            ComputerName = $ComputerName
            Reachable    = $false
            Latency      = $null
            Error        = $_.Exception.Message
        }
    }
}

function Get-RemoteService {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [string]$ServiceName
    )
    
    try {
        $Service = Get-Service -Name $ServiceName -ComputerName $ComputerName -ErrorAction Stop
        return @{
            ComputerName = $ComputerName
            ServiceName  = $Service.Name
            DisplayName  = $Service.DisplayName
            Status       = $Service.Status
            StartType    = $Service.StartType
        }
    }
    catch {
        return @{
            ComputerName = $ComputerName
            ServiceName  = $ServiceName
            Status       = "NotFound"
            Error        = $_.Exception.Message
        }
    }
}

function Invoke-RemoteCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,
        [int]$Timeout = 30
    )
    
    try {
        $Session = New-PSSession -ComputerName $ComputerName -ErrorAction Stop
        $Result = Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ErrorAction Stop
        Remove-PSSession $Session
        return $Result
    }
    catch {
        Write-Error "Failed to execute remote command on $ComputerName`: $($_.Exception.Message)"
        return $null
    }
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string]$Level = "Info",
        [string]$LogPath = "$PSScriptRoot\..\Logs\sysops.log"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    
    $LogDir = Split-Path $LogPath -Parent
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
    
    Add-Content -Path $LogPath -Value $LogEntry
    
    switch ($Level) {
        "Info"    { Write-Host $LogEntry -ForegroundColor Cyan }
        "Warning" { Write-Host $LogEntry -ForegroundColor Yellow }
        "Error"   { Write-Host $LogEntry -ForegroundColor Red }
        "Success" { Write-Host $LogEntry -ForegroundColor Green }
    }
}

function ConvertTo-PrettyJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject,
        [int]$Depth = 10
    )
    
    return $InputObject | ConvertTo-Json -Depth $Depth
}

function Export-ReportData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object]$Data,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        [ValidateSet("Json", "Csv", "Xml")]
        [string]$Format = "Json"
    )
    
    $OutputDir = Split-Path $OutputPath -Parent
    if (-not (Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    }
    
    switch ($Format) {
        "Json" { $Data | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8 }
        "Csv"  { $Data | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8 }
        "Xml"  { $Data | Export-Clixml -Path $OutputPath }
    }
    
    return $OutputPath
}

function Send-EmailReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Subject,
        [Parameter(Mandatory = $true)]
        [string]$Body,
        [string]$SmtpServer,
        [string]$From,
        [string]$To,
        [string[]]$Attachment
    )
    
    $Params = @{
        Subject     = $Subject
        Body        = $Body
        BodyAsHtml  = $true
        From        = $From
        To          = $To
        SmtpServer  = $SmtpServer
    }
    
    if ($Attachment) {
        $Params.Attachments = $Attachment
    }
    
    try {
        Send-MailMessage @Params -ErrorAction Stop
        Write-Log "Email report sent successfully" -Level Success
        return $true
    }
    catch {
        Write-Log "Failed to send email: $($_.Exception.Message)" -Level Error
        return $false
    }
}

function Get-CimSessionSafe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [int]$Timeout = 10
    )
    
    try {
        $Cim = New-CimSession -ComputerName $ComputerName -OperationTimeoutSec $Timeout -ErrorAction Stop
        return $Cim
    }
    catch {
        Write-Warning "Failed to create CIM session to $ComputerName`: $($_.Exception.Message)"
        return $null
    }
}

Export-ModuleMember -Function @(
    'Get-Config',
    'Test-ServerReachability',
    'Get-RemoteService',
    'Invoke-RemoteCommand',
    'Write-Log',
    'ConvertTo-PrettyJson',
    'Export-ReportData',
    'Send-EmailReport',
    'Get-CimSessionSafe'
)

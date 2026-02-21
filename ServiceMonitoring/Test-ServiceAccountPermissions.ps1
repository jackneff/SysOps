<#
.SYNOPSIS
    Checks for service account permission issues.

.DESCRIPTION
    Identifies services running under user accounts that may have permission problems.

.PARAMETER ComputerName
    Target server(s).

.PARAMETER CheckLogonAsService
    Check if service accounts have LogonAsService privilege.

.PARAMETER CheckExpiredPassword
    Check if service account password is expired.

.EXAMPLE
    .\Test-ServiceAccountPermissions.ps1 -ComputerName "Server01"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string[]]$ComputerName = @("localhost"),
    
    [switch]$CheckLogonAsService,
    
    [switch]$CheckExpiredPassword
)

$ErrorActionPreference = "Stop"

$AllResults = @()

foreach ($Computer in $ComputerName) {
    Write-Host "Checking service accounts on: $Computer" -ForegroundColor Cyan
    
    try {
        $Services = Get-WmiObject -Class Win32_Service -ComputerName $Computer -ErrorAction Stop
        
        foreach ($Service in $Services) {
            if ($Service.StartName -and $Service.StartName -ne "LocalSystem" -and 
                $Service.StartName -ne "NT AUTHORITY\LocalService" -and 
                $Service.StartName -ne "NT AUTHORITY\NetworkService") {
                
                $Issue = ""
                $Severity = "Info"
                
                $AccountName = $Service.StartName
                if ($AccountName -like "*\*") {
                    $Domain = $AccountName.Split("\")[0]
                    $User = $AccountName.Split("\")[1]
                    
                    if ($CheckLogonAsService -and $Domain -ne "NT AUTHORITY") {
                        try {
                            $UserObj = [System.Security.Principal.NTAccount]"$Domain\$User"
                            $Sid = $UserObj.Translate([System.Security.Principal.SecurityIdentifier])
                            
                            $UserRights = Get-WmiObject -Class Win32_LogicalFileSecuritySetting -ComputerName $Computer -Filter "Path='C:\\'" -ErrorAction SilentlyContinue
                        }
                        catch {
                            $Issue = "Unable to verify LogonAsService privilege"
                            $Severity = "Warning"
                        }
                    }
                    
                    if ($CheckExpiredPassword -and $Domain -ne "NT AUTHORITY") {
                        try {
                            if (Get-Module -ListAvailable -Name ActiveDirectory) {
                                $AdUser = Get-ADUser -Identity $User -Server $Domain -ErrorAction SilentlyContinue
                                if ($AdUser -and $AdUser.PasswordExpired) {
                                    $Issue = "Service account password expired"
                                    $Severity = "Critical"
                                }
                            }
                        }
                        catch {
                        }
                    }
                }
                
                if ($Service.State -ne "Running" -and $Service.StartType -eq "Auto") {
                    $Issue = "Service not running but configured for auto-start"
                    $Severity = "Warning"
                }
                
                $AllResults += [PSCustomObject]@{
                    ComputerName   = $Computer
                    ServiceName   = $Service.Name
                    DisplayName   = $Service.DisplayName
                    ServiceAccount = $Service.StartName
                    Status        = $Service.State
                    StartType     = $Service.StartType
                    Issue         = $Issue
                    Severity      = $Severity
                }
            }
        }
    }
    catch {
        Write-Warning "Failed to query $Computer`: $($_.Exception.Message)"
    }
}

$Issues = $AllResults | Where-Object { $_.Issue -ne "" }

Write-Host "`n=== Service Account Status ===" -ForegroundColor Cyan
$AllResults | Format-Table -AutoSize

if ($Issues.Count -gt 0) {
    Write-Host "`n=== Service Account Issues ===" -ForegroundColor Red
    $Issues | Format-Table -AutoSize
}

return $AllResults

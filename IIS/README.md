# IIS Examples

This folder contains scripts for managing IIS servers and sites.

## Test-IISService.ps1

Check if IIS service (W3SVC) is running.

```powershell
# Check local server
.\Test-IISService.ps1

# Check remote server
.\Test-IISService.ps1 -ComputerName "WebServer01"
```

**Example Output:**
```
ComputerName ServiceName DisplayName                            Status   IsHealthy
------------ ----------- -----------                            ------   ---------
localhost   W3SVC       World Wide Web Publishing Service      Running  True
```

## Get-IISSiteStatus.ps1

List all IIS sites and their states.

```powershell
# Get sites from local server
.\Get-IISSiteStatus.ps1

# Get sites from remote server
.\Get-IISSiteStatus.ps1 -ComputerName "WebServer01"
```

**Example Output:**
```
IIS Sites on: WebServer01

Name              Id    State PhysicalPath                           Bindings
----              --    ----- -----------                           --------
Default Web Site  1     Started C:\inetpub\wwwroot                  http://*:80:
Intranet          100   Started C:\inetpub\intranet                http://*:8080:
CRM               200   Started C:\inetpub\crm                     https://*:443:
API               300   Stopped C:\inetpub\api                     http://*:5000:
```

## Get-IISAppPoolStatus.ps1

List application pools and their states.

```powershell
# Get app pools from local server
.\Get-IISAppPoolStatus.ps1

# Get app pools from remote server
.\Get-IISAppPoolStatus.ps1 -ComputerName "WebServer01"
```

**Example Output:**
```
IIS Application Pools on: WebServer01

Name               State     ManagedRuntimeVersion ManagedPipelineMode StartMode
----               -----     --------------------- --------------------- ---------
DefaultAppPool     Running   v4.0                  Integrated            OnDemand
ClassicAppPool    Running   v2.0                  Classic              OnDemand
IntranetPool      Running   v4.0                  Integrated            AlwaysRunning
CRMPool           Stopped   v4.0                  Integrated            OnDemand
APIPool           Running   v4.0                  Integrated            OnDemand
```

## Test-IISSite.ps1

Test IIS site availability via HTTP.

```powershell
# Test all sites on server
.\Test-IISSite.ps1 -ComputerName "WebServer01"

# Test specific site
.\Test-IISSite.ps1 -ComputerName "WebServer01" -SiteName "Default Web Site"
```

**Example Output:**
```
IIS Site Tests on: WebServer01

SiteName       Url                  State    StatusCode IsHealthy
--------       ---                  -----    --------- ---------
Default Web Site http://localhost:80  Started  200        True
Intranet       http://localhost:8080 Started  200        True
CRM            https://localhost:443 Started  200        True
API            http://localhost:5000 Stopped  0          False
```

## Get-IISBindings.ps1

List site bindings.

```powershell
# Get bindings from local server
.\Get-IISBindings.ps1

# Get bindings from remote server
.\Get-IISBindings.ps1 -ComputerName "WebServer01"
```

**Example Output:**
```
IIS Bindings on: WebServer01

SiteName       Protocol Port IPAddress HostHeader Certificate
--------       -------- ---- --------- ---------- ----------
Default Web Site HTTP     80   *         *           
Intranet       HTTP     8080 *         *           
CRM            HTTPS    443  *         *           A1B2C3...
API            HTTP     5000 *         api.local  
```

## Get-IISWorkerProcesses.ps1

List running w3wp.exe worker processes.

```powershell
.\Get-IISWorkerProcesses.ps1 -ComputerName "WebServer01"
```

**Example Output:**
```
IIS Worker Processes on: WebServer01

ProcessId AppPoolName    CPU  MemoryMB StartTime
--------- ------------   ---  -------- ---------
4524      DefaultAppPool 125  256      2024-01-15 10:30:00
5623      IntranetPool   45   128      2024-01-15 11:45:00
6789      CRMPool        234  512      2024-01-15 09:15:00
```

## Get-IISErrorLogs.ps1

Parse IIS logs for errors.

```powershell
# Get errors from last 24 hours
.\Get-IISErrorLogs.ps1 -ComputerName "WebServer01"

# Get errors from custom path
.\Get-IISErrorLogs.ps1 -ComputerName "WebServer01" -LogPath "D:\inetpub\logs\LogFiles" -Hours 48
```

**Example Output:**
```
IIS Errors on: WebServer01 (Last 24 hours)

DateTime                   SiteName   StatusCode UriStem
--------                   --------   ---------- --------
2024-01-15 14:30:01       Default Web Site 500 /api/Error
2024-01-15 12:15:22       CRM         404 /images/missing.png
2024-01-15 10:05:15       API         500 /api/users/1
```

## Start-IISSite.ps1 / Stop-IISSite.ps1

Start or stop an IIS site.

```powershell
# Stop a site
.\Stop-IISSite.ps1 -ComputerName "WebServer01" -SiteName "Default Web Site"

# Start a site
.\Start-IISSite.ps1 -ComputerName "WebServer01" -SiteName "Default Web Site"
```

**Example Output (Stop):**
```
Site 'Default Web Site' stopped successfully
```

**Example Output (Start):**
```
Site 'Default Web Site' started successfully
```

## Recycle-IISAppPool.ps1

Recycle an application pool.

```powershell
.\Recycle-IISAppPool.ps1 -ComputerName "WebServer01" -AppPoolName "DefaultAppPool"
```

**Example Output:**
```
Application pool 'DefaultAppPool' recycled. State: Running
```

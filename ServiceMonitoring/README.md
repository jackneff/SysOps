# Service Monitoring Examples

This folder contains scripts for monitoring Windows services.

## Check-ServiceStatus.ps1

Check a specific service on a remote server.

```powershell
# Check a single service on local machine
.\Check-ServiceStatus.ps1 -ServiceName W3SVC

# Check multiple services on remote servers
.\Check-ServiceStatus.ps1 -ComputerName "Server01","Server02" -ServiceName "MSSQLSERVER"

# Use services from config
.\Check-ServiceStatus.ps1 -UseConfig
```

**Example Output:**
```
ComputerName ServiceName DisplayName                  Status   StartType
------------ ----------- -----------                  ------   ---------
localhost   W3SVC       World Wide Web Publishing... Running  Automatic
```

## Check-ServiceHealth.ps1

Monitor service health across multiple servers.

```powershell
# Check health of all services in config
.\Check-ServiceHealth.ps1 -UseConfig

# Check specific servers and services
.\Check-ServiceHealth.ps1 -ComputerName "Server01","Server02" -ServiceNames "W3SVC","MSSQLSERVER" -AlertOnStopped
```

**Example Output:**
```
=== Service Health Check Results ===

ComputerName ServiceName  DisplayName                  Status   IsHealthy
------------ -----------  -----------                  ------   ---------
Server01    W3SVC       World Wide Web Publishing... Running  True
Server01    MSSQLSERVER  SQL Server (MSSQLSERVER)     Running  True
Server02    W3SVC       World Wide Web Publishing... Running  True
Server02    MSSQLSERVER  SQL Server (MSSQLSERVER)     Stopped False

=== Alerts ===

ComputerName AlertType      ServiceName  Message
------------ ---------      -----------  -------
Server02    ServiceStopped MSSQLSERVER  Service 'MSSQLSERVER' is not running

=== Summary ===

TotalChecks     : 4
HealthyServices : 3
Unhealthy       : 1
Alerts          : 1
Timestamp       : 2024-01-15 14:30:00
```

## Monitor-CriticalServices.ps1

Comprehensive monitoring with alerts.

```powershell
# Monitor all critical services with full alerting
.\Monitor-CriticalServices.ps1 -UseConfig -AlertOnStopped -AlertOnDisabled -AlertOnHung

# Monitor specific servers
.\Monitor-CriticalServices.ps1 -ComputerName "WebServer01" -ServiceNames "W3SVC","WAS" -AlertOnStopped -AlertOnHung
```

**Example Output:**
```
Checking services on: Server01
Checking services on: Server02

=== Alerts Found: 2 ===

ComputerName ServiceName  DisplayName     AlertType    Severity Message
------------ -----------  -----------     ---------    -------- -------
Server02    MSSQLSERVER  SQL Server      Stopped     Critical Service is not running (Status: Stopped)
Server01    BITS         Background...   DisabledAuto High    Auto-start service is disabled
```

## Find-DisabledAutoStartServices.ps1

Find services configured to start automatically but are disabled.

```powershell
# Check local server
.\Find-DisabledAutoStartServices.ps1

# Check multiple servers
.\Find-DisabledAutoStartServices.ps1 -ComputerName "Server01","Server02","Server03"
```

**Example Output:**
```
Checking: Server01
Checking: Server02

=== Disabled Auto-Start Services ===

ComputerName ServiceName DisplayName                         Status    StartType
------------ ----------- -----------                         ------    ---------
Server01    BITS        Background Intelligent Transfer...   Stopped  Disabled
Server02    RemoteReg   Remote Registry                    Stopped  Disabled

Found 2 disabled auto-start services
```

## Find-HungServices.ps1

Detect services stuck in Starting or Stopping state.

```powershell
# Find hung services with default 5 minute threshold
.\Find-HungServices.ps1 -ComputerName "Server01"

# Use custom threshold
.\Find-HungServices.ps1 -ComputerName "Server01","Server02" -ThresholdMinutes 10
```

**Example Output:**
```
Checking: Server01

=== Hung Services ===

ComputerName ServiceName  DisplayName         CurrentState StartType WaitTimeMinutes IsHung
------------ -----------  -----------         ------------ ---------- --------------- ------
Server01    MyService    My Custom Service   StopPending   Automatic  8               True

Hung services (>5 min): 1
```

## Test-ServiceAccountPermissions.ps1

Check service account permission issues.

```powershell
# Check service accounts on server
.\Test-ServiceAccountPermissions.ps1 -ComputerName "Server01"

# Also check for expired passwords (requires AD module)
.\Test-ServiceAccountPermissions.ps1 -ComputerName "Server01" -CheckExpiredPassword
```

**Example Output:**
```
Checking service accounts on: Server01

=== Service Account Status ===

ComputerName ServiceName  ServiceAccount             Status   StartType Issue                    Severity
------------ -----------  ---------------             ------   --------- -----                    --------
Server01    W3SVC        NT AUTHORITY\LocalSystem    Running  Auto                                  Info
Server01    MSSQLSERVER  DOMAIN\SqlService           Stopped  Auto      Service not running...   Warning
Server02    MyAppSvc     DOMAIN\AppService          Running  Auto                                  Info
Server02    ExpiredSvc   DOMAIN\ExpiredAccount      Running  Auto      Service account password... Critical

=== Service Account Issues ===

ComputerName ServiceName  ServiceAccount      Issue                           Severity
------------ -----------  ---------------      -----                           --------
Server02    MSSQLSERVER  DOMAIN\SqlService   Service not running but...      Warning
Server02    ExpiredSvc   DOMAIN\ExpiredAccount Password expired               Critical
```

## Watch-ServiceStateChanges.ps1

Track service state changes over time.

```powershell
# Run to capture current state and detect changes
.\Watch-ServiceStateChanges.ps1 -UseConfig

# Run again later to see what changed
.\Watch-ServiceStateChanges.ps1 -UseConfig
```

**Example Output (first run - captures state):**
```
No state changes detected
```

**Example Output (second run - changes detected):**
```
=== Service State Changes Detected ===

ComputerName ServiceName  DisplayName      Property PreviousValue CurrentValue Timestamp
------------ -----------  -----------      -------- -------------- ------------- ---------
Server01    W3SVC       World Wide...    Status   Running        Stopped       2024-01-15 14:30:00
Server01    MSSQLSERVER  SQL Server       Status   Stopped        Running       2024-01-15 14:30:00
```

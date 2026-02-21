# Web Monitoring Examples

This folder contains scripts for monitoring web applications and URLs.

## Test-WebApplication.ps1

Test a single web application's availability.

```powershell
# Test basic URL
.\Test-WebApplication.ps1 -Url "https://www.example.com"

# Test with custom expected status
.\Test-WebApplication.ps1 -Url "https://intranet.company.com" -ExpectedStatusCode 200

# Ignore SSL certificate errors
.\Test-WebApplication.ps1 -Url "https://selfsigned.site.com" -IgnoreSSL

# Custom timeout
.\Test-WebApplication.ps1 -Url "https://slowsite.com" -TimeoutSeconds 60
```

**Example Output (healthy):**
```
OK - https://www.example.com returned 200 in 45ms
```

**Example Output (unhealthy):**
```
FAIL - https://www.example.com returned 500 (Internal Server Error)
```

**Example Output Object:**
```
Url             : https://www.example.com
StatusCode      : 200
StatusDescription : OK
ResponseTimeMs  : 45
IsHealthy       : True
Timestamp       : 2024-01-15 14:30:00
```

## Test-WebApplicationBatch.ps1

Test multiple web applications from config.

```powershell
# Test all websites in config
.\Test-WebApplicationBatch.ps1 -UseConfig

# Test specific URL
.\Test-WebApplicationBatch.ps1 -Url "https://api.example.com/health"
```

**Example Output:**
```
Testing: https://intranet.company.com
OK - https://intranet.company.com returned 200 in 32ms
Testing: https://crm.company.com
OK - https://crm.company.com returned 200 in 150ms
Testing: https://api.company.com
FAIL - https://api.company.com returned 503 (Service Unavailable)

=== Web Application Health Summary ===

Name      Url                           StatusCode ResponseTimeMs IsHealthy
----      ---                           ---------- -------------- ----------
Intranet  https://intranet.company.com 200        32             True
CRM       https://crm.company.com       200        150            True
API       https://api.company.com       503        45             False

=== Unhealthy Sites ===

Name Url                    StatusCode IsHealthy
---- ---                    ---------- ----------
API  https://api.company.com 503        False
```

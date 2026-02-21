# Reports Examples

This folder contains scripts for generating reports.

## Invoke-DailyHealthCheck.ps1

Generate comprehensive daily health check report.

```powershell
# Generate report with config
.\Invoke-DailyHealthCheck.ps1 -UseConfig

# Generate and send email
.\Invoke-DailyHealthCheck.ps1 -UseConfig -SendEmail

# Save to custom location
.\Invoke-DailyHealthCheck.ps1 -UseConfig -OutputPath "C:\Reports\HealthCheck-$(Get-Date -Format 'yyyyMMdd').html"
```

**Example Output:**
```
Generating Daily Health Check Report...
Servers: Server01, Server02, Server03

Report saved to: C:\Reports\DailyHealthCheck-20240115-143000.html
Email report sent successfully
```

**HTML Report Sample:**

The generated HTML report includes:

1. **Service Status Table**
   - Server name
   - Service name
   - Status (color-coded: green=healthy, red=stopped)

2. **Disk Space Table**
   - Server, Drive, Used GB, Free GB, % Used
   - Color-coded (green <80%, yellow 80-90%, red >90%)

3. **System Uptime Table**
   - Server, Last Boot Time, Uptime

4. **Web Application Status** (if configured)
   - Name, URL, Status Code, Response Time

5. **Summary Section**
   - Total Service Checks
   - Healthy/Unhealthy counts
   - Alert count

**Example HTML Preview:**

```html
<h1>Daily Health Check Report</h1>
<p class="timestamp">Generated: 2024-01-15 14:30:00</p>

<h2>Service Status</h2>
<table>
  <tr><th>Server</th><th>Service</th><th>Status</th></tr>
  <tr><td>Server01</td><td>W3SVC</td><td class='healthy'>Running</td></tr>
  <tr><td>Server01</td><td>MSSQLSERVER</td><td class='healthy'>Running</td></tr>
  <tr><td>Server02</td><td>W3SVC</td><td class='unhealthy'>Stopped</td></tr>
</table>

<h2>Disk Space</h2>
<table>
  <tr><th>Server</th><th>Drive</th><th>Used GB</th><th>Free GB</th><th>% Used</th></tr>
  <tr><td>Server01</td><td>C:</td><td>200</td><td>56</td><td class='warning'>78%</td></tr>
</table>

<div class="summary">
  <p>Total Service Checks: 15</p>
  <p class="healthy">Healthy Services: 14</p>
  <p class="unhealthy">Unhealthy Services: 1</p>
  <p>Alerts: 3</p>
</div>
```

## Scheduling Daily Health Check

Create a scheduled task to run the health check daily:

```powershell
# Create daily health check task at 6 AM
.\ScheduledTasks\New-ScheduledTask.ps1 -TaskName "DailyHealthCheck" `
    -Action "powershell.exe -ExecutionPolicy Bypass -File C:\Scripts\Reports\Invoke-DailyHealthCheck.ps1 -UseConfig -SendEmail" `
    -TriggerType Daily -TriggerValue "06:00" `
    -Description "Daily server health check report"
```

## Customizing the Report

Edit `Config/settings.json` to customize what gets checked:

```json
{
  "servers": [
    "Server01",
    "Server02",
    "Server03"
  ],
  "criticalServices": [
    "W3SVC",
    "MSSQLSERVER",
    "DNS"
  ],
  "websites": [
    {
      "name": "Intranet",
      "url": "http://intranet.company.com"
    }
  ],
  "diskSpaceThreshold": 80,
  "smtpServer": "smtp.company.com",
  "fromEmail": "sysops@company.com",
  "toEmail": "admin@company.com"
}
```

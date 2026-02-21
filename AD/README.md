# Active Directory Examples

This folder contains scripts for managing Active Directory.

## Get-ADUser.ps1

Query AD users.

```powershell
# Get all enabled users
.\Get-ADUser.ps1 -Enabled

# Get specific user
.\Get-ADUser.ps1 -Identity "jsmith"

# Get users from specific OU
.\Get-ADUser.ps1 -SearchBase "OU=Finance,DC=domain,DC=com"

# Get users with custom properties
.\Get-ADUser.ps1 -Properties "SamAccountName","DisplayName","EmailAddress","Department","Title"
```

**Example Output:**
```
SamAccountName DisplayName        EmailAddress              Enabled LastLogonDate       PasswordExpired LockedOut
-------------- -----------      ------------              ------- --------------       -------------- ----------
jsmith         John Smith       jsmith@domain.com         True    2024-01-15 10:30:00 False          False
jdoe           Jane Doe         jdoe@domain.com          True    2024-01-14 09:15:00 False          False
```

## Get-ADGroup.ps1

Query AD groups.

```powershell
# Get all groups
.\Get-ADGroup.ps1

# Get specific group with members
.\Get-ADGroup.ps1 -Identity "Domain Admins" -IncludeMembers

# Get groups matching filter
.\Get-ADGroup.ps1 -Filter "Name -like '*Admin*'" -IncludeMembers
```

**Example Output (without members):**
```
Name                GroupCategory GroupScope     DistinguishedName
----                ------------- -----------     -----------------
Domain Admins       Security      DomainLocal   CN=Domain Admins,CN=Users,DC=domain,DC=com
Account Operators   Security      DomainLocal   CN=Account Operators,CN=Users,DC=domain,DC=com
```

**Example Output (with members):**
```
GroupName       MemberName      MemberType MemberDistinguishedName
---------       ----------      ---------- ------------------------
Domain Admins   Administrator   user       CN=Administrator,CN=Users,DC=domain,DC=com
Domain Admins   Domain Admins   group      CN=Domain Admins,CN=Users,DC=domain,DC=com
```

## Get-ADComputer.ps1

Query computer accounts.

```powershell
# Get all computers
.\Get-ADComputer.ps1

# Get only Windows servers
.\Get-ADComputer.ps1 -OperatingSystem "*Server*"

# Find inactive computers (90+ days)
.\Get-ADComputer.ps1 -InactiveDays 90
```

**Example Output:**
```
Name           DNSHostName               OperatingSystem                OperatingSystemVersion LastLogonDate       Enabled
----           ----------               ----------------                --------------------- --------------       -------
SERVER01       SERVER01.domain.com      Windows Server 2022 Datacenter 21H2                   2024-01-15          True
SERVER02       SERVER02.domain.com      Windows Server 2019 Standard   1809                   2024-01-10          True
WORKSTATION01 WORKST01.domain.com     Windows 11 Pro                 23H2                    2023-12-01          True
```

## Get-ADUserGroups.ps1

Get all groups a user belongs to.

```powershell
# Get groups for user
.\Get-ADUserGroups.ps1 -Identity jsmith

# Using distinguished name
.\Get-ADUserGroups.ps1 -Identity "CN=John Smith,OU=Users,DC=domain,DC=com"
```

**Example Output:**
```
Groups for user: jsmith

Name                  GroupCategory GroupScope     DistinguishedName
----                  ------------- -----------     -----------------
Domain Users          Security      DomainLocal   CN=Domain Users,CN=Users,DC=domain,DC=com
Finance Team          Security      Global       CN=Finance Team,OU=Groups,DC=domain,DC=com
VPN Users             Security      Global       CN=VPN Users,OU=Groups,DC=domain,DC=com
Remote Desktop Users  Security      DomainLocal   CN=Remote Desktop Users,CN=Users,DC=domain,DC=com
```

## Get-ADLockedAccounts.ps1

Find locked out user accounts.

```powershell
# Find all locked accounts
.\Get-ADLockedAccounts.ps1
```

**Example Output:**
```
Locked Accounts: 1

Name          SamAccountName DistinguishedName                              LastLogonDate      LockedOut
----          -------------- -----------------                              --------------      ----------
John Smith    jsmith        CN=John Smith,OU=Users,DC=domain,DC=com        2024-01-15        True
```

## Get-ADExpiredAccounts.ps1

Find expired accounts.

```powershell
# Find already expired accounts
.\Get-ADExpiredAccounts.ps1

# Find accounts expiring within 30 days
.\Get-ADExpiredAccounts.ps1 -DaysUntilExpiration 30
```

**Example Output:**
```
Expired Accounts: 2

Name           SamAccountName DistinguishedName                          AccountExpirationDate Enabled
----           -------------- -----------------                          --------------------- -------
Test User     testuser      CN=Test User,OU=Test,DC=domain,DC=com      2024-01-01          False
Temp Employee tempemp      CN=Temp Employee,OU=Temp,DC=domain,DC=com    2024-01-20          True
```

## Get-ADInactiveComputers.ps1

Find stale computer accounts.

```powershell
# Find computers inactive for 90 days
.\Get-ADInactiveComputers.ps1 -InactiveDays 90
```

**Example Output:**
```
Inactive Computers (>90 days): 3

Name            DNSHostName              OperatingSystem     LastLogonDate      DistinguishedName
----            ----------              ----------------     --------------      -----------------
OLD-PC01       OLD-PC01.domain.com     Windows 10 Pro      2023-09-15         CN=OLD-PC01,OU=Computers,DC=domain,DC=com
OLD-PC02       OLD-PC02.domain.com     Windows 10 Pro      2023-08-20         CN=OLD-PC02,OU=Computers,DC=domain,DC=com
```

## Test-ADReplication.ps1

Check AD replication status.

```powershell
# Check replication on all DCs
.\Test-ADReplication.ps1

# Check specific DCs
.\Test-ADReplication.ps1 -ComputerName "DC01","DC02"
```

**Example Output:**
```
Checking replication on: DC01
Checking replication on: DC02

=== AD Replication Status ===

SourceServer PartnerServer      LastReplication   FailureCount LastError IsHealthy
----------- ------------        ---------------   ------------ --------- ---------
DC01        DC02.domain.com     2024-01-15 14:30  0            0         True
DC02        DC01.domain.com     2024-01-15 14:30  0            0         True
```

## Test-ADServices.ps1

Verify critical AD services.

```powershell
# Use config for domain controllers
.\Test-ADServices.ps1 -UseConfig

# Check specific servers
.\Test-ADServices.ps1 -ComputerName "DC01","DC02"
```

**Example Output:**
```
Checking AD services on: DC01
Checking AD services on: DC02

=== AD Service Status ===

ComputerName ServiceName           DisplayName                                  Status    IsHealthy
------------ -----------           -----------                                  ------    ---------
DC01         NTDS                  Active Directory Domain Services            Running   True
DC01         DNS                   DNS Server                                  Running   True
DC01         NetLogon              Netlogon                                    Running   True
DC01         W32Time               Windows Time                                Running   True
DC02         NTDS                  Active Directory Domain Services            Running   True
DC02         DNS                   DNS Server                                  Running   True
DC02         NetLogon              Netlogon                                    Running   True
DC02         W32Time               Windows Time                                Running   True
```

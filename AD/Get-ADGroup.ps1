<#
.SYNOPSIS
    Queries Active Directory for groups.

.DESCRIPTION
    Retrieves AD groups and optionally lists members.

.PARAMETER Identity
    Specific group identity.

.PARAMETER Filter
    LDAP filter string.

.PARAMETER IncludeMembers
    Include group members in output.

.EXAMPLE
    .\Get-ADGroup.ps1 -IncludeMembers

.EXAMPLE
    .\Get-ADGroup.ps1 -Filter "Name -like '*Admin*'"
#>

[CmdletBinding()]
param(
    [string]$Identity = "",
    [string]$Filter = "*",
    [switch]$IncludeMembers
)

$ErrorActionPreference = "Stop"

if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "ActiveDirectory module not available."
    exit 1
}

Import-Module ActiveDirectory -ErrorAction Stop

$Params = @{ Filter = $Filter }

if ($Identity) {
    $Params.Identity = $Identity
}

$Groups = Get-ADGroup @Params -ErrorAction Stop

if ($IncludeMembers) {
    $Results = @()
    foreach ($Group in $Groups) {
        $Members = Get-ADGroupMember -Identity $Group.DistinguishedName -ErrorAction SilentlyContinue
        foreach ($Member in $Members) {
            $Results += [PSCustomObject]@{
                GroupName = $Group.Name
                MemberName = $Member.Name
                MemberType = $Member.objectClass
                MemberDistinguishedName = $Member.DistinguishedName
            }
        }
    }
    $Results | Format-Table -AutoSize
    return $Results
}
else {
    $Groups | Select-Object Name, GroupCategory, GroupScope, DistinguishedName | Format-Table -AutoSize
    return $Groups
}

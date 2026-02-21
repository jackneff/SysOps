# Pester Testing for SysOps

This directory contains Pester tests for validating the SysOps PowerShell scripts.

## Overview

[Pester](https://pester.dev/) is a testing and mocking framework for PowerShell. It provides a domain-specific language (DSL) for writing tests that validate the behavior of your PowerShell scripts and functions.

## Installation

### Prerequisites
- PowerShell 5.1 or later
- Windows Server 2012 R2 or later

### Install Pester

```powershell
# From PowerShell Gallery (recommended)
Install-Module -Name Pester -Force -SkipPublisherCheck

# Or update existing version
Update-Module -Name Pester

# Verify installation
Import-Module Pester -MinimumVersion 5.0
Get-Module Pester
```

### Version Requirements
- **Pester 5.x** - Recommended for modern testing features
- **Pester 4.x** - Legacy support

## Running Tests

### Run All Tests
```powershell
# From the SysOps root directory
Invoke-Pester

# With detailed output
Invoke-Pester -Output Detailed

# Run specific test file
Invoke-Pester -Path ".\Tests\ServiceMonitoring\Tests.Check-ServiceHealth.ps1"
```

### Run Tests by Category
```powershell
# Service Monitoring tests
Invoke-Pester -Path ".\Tests\ServiceMonitoring\"

# Event Logs tests
Invoke-Pester -Path ".\Tests\EventLogs\"

# Network Monitoring tests
Invoke-Pester -Path ".\Tests\NetworkMonitoring\"
```

### Run Tests with Coverage
```powershell
# Run tests and generate code coverage report
Invoke-Pester -CodeCoverage .\ServiceMonitoring\*.ps1 -Output Detailed
```

## Test Structure

### File Naming Convention
- Test files should be named `Tests.<ScriptName>.ps1`
- Example: `Tests.Check-ServiceHealth.ps1` tests `Check-ServiceHealth.ps1`

### Basic Test Example

```powershell
# Tests.ServiceMonitoring.Tests.Check-ServiceHealth.ps1

BeforeAll {
    # Import the script to test
    . "$PSScriptRoot\..\..\ServiceMonitoring\Check-ServiceHealth.ps1"
}

Describe "Check-ServiceHealth" {
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { Check-ServiceHealth -ComputerName "localhost" } | Should -Not -Throw
        }
        
        It "Should accept ServiceNames parameter" {
            { Check-ServiceHealth -ServiceNames @("Spooler") } | Should -Not -Throw
        }
        
        It "Should accept UseConfig switch" {
            { Check-ServiceHealth -UseConfig } | Should -Not -Throw
        }
    }
    
    Context "Output Validation" {
        It "Should return a hashtable with Results key" {
            $result = Check-ServiceHealth -ComputerName "localhost" -ServiceNames "Spooler"
            $result.Results | Should -Not -BeNullOrEmpty
        }
        
        It "Should return results as PSCustomObject" {
            $result = Check-ServiceHealth -ComputerName "localhost" -ServiceNames "Spooler"
            $result.Results[0] | Should -BeOfType [PSCustomObject]
        }
    }
}
```

### Testing Error Handling

```powershell
Describe "Error Handling" {
    It "Should handle unreachable computers gracefully" {
        $result = Check-ServiceHealth -ComputerName "nonexistent.server.com" -ServiceNames "Spooler"
        $result.Alerts | Should -Not -BeNullOrEmpty
    }
}
```

### Testing with Mocking

```powershell
BeforeAll {
    # Mock Test-ServerReachability
    Mock Test-ServerReachability {
        return @{
            ComputerName = "localhost"
            Reachable    = $true
            Latency      = 1
        }
    }
    
    # Mock Get-Service
    Mock Get-Service {
        return [PSCustomObject]@{
            Name        = "Spooler"
            DisplayName = "Print Spooler"
            Status      = "Running"
            StartType   = "Automatic"
        }
    }
}

Describe "Check-ServiceHealth with Mocks" {
    It "Should use mocked service data" {
        $result = Check-ServiceHealth -ComputerName "localhost" -ServiceNames "Spooler"
        $result.Results[0].Status | Should -Be "Running"
    }
}
```

### Testing Configuration Files

```powershell
Describe "Configuration Tests" {
    BeforeAll {
        $ConfigPath = "$PSScriptRoot\..\..\Config\settings.json"
    }
    
    It "Should have a valid settings.json file" {
        Test-Path $ConfigPath | Should -Be $true
    }
    
    It "Should have valid JSON in settings.json" {
        { Get-Content $ConfigPath -Raw | ConvertFrom-Json } | Should -Not -Throw
    }
    
    It "Should have required config properties" {
        $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
        $config.servers | Should -Not -BeNullOrEmpty
        $config.criticalServices | Should -Not -BeNullOrEmpty
    }
}
```

## Test Categories

### Unit Tests
- Test individual functions in isolation
- Use mocking to simulate dependencies
- Fast execution

### Integration Tests
- Test scripts with real system components
- May require specific environment setup
- Slower but more comprehensive

### Parameter Tests
- Validate all parameters accept correct input
- Test boundary conditions
- Test parameter combinations

## Best Practices

### 1. Use Describe and Context Blocks
```powershell
Describe "ScriptName" {
    Context "Specific Feature" {
        It "Should do something specific" {
            # Test code
        }
    }
}
```

### 2. Use BeforeAll for Setup
```powershell
BeforeAll {
    $script:TestVariable = "value"
}
```

### 3. Use It Blocks for Individual Tests
```powershell
It "Should return valid output" {
    $result = Get-Something
    $result | Should -Not -BeNullOrEmpty
}
```

### 4. Clean Up with AfterAll
```powershell
AfterAll {
    # Cleanup code
    Remove-Item $TestPath -ErrorAction SilentlyContinue
}
```

### 5. Use Test Drive for Temporary Files
```powershell
It "Should create output file" {
    $testFile = Join-Path $TestDrive "output.txt"
    # Test code that creates $testFile
    Test-Path $testFile | Should -Be $true
}
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Pester Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Pester
        run: Install-Module -Name Pester -Force -SkipPublisherCheck
      - name: Run Tests
        run: Invoke-Pester -Output Detailed
```

### Azure DevOps Example
```yaml
- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      Install-Module -Name Pester -Force -SkipPublisherCheck
      Invoke-Pester -Output Detailed
```

## Common Issues

### Issue: Tests hang or timeout
**Solution:** Add timeout to Invoke-Pester or individual tests
```powershell
Invoke-Pester -Timeout 300
```

### Issue: Cannot import module
**Solution:** Use dot-sourcing or Import-Module correctly
```powershell
BeforeAll {
    . "$PSScriptRoot\..\..\Modules\AdminTools.psm1"
}
```

### Issue: Mock not working
**Solution:** Ensure mock is in BeforeAll scope
```powershell
BeforeAll {
    Mock Get-Service { ... }
}

It "Test" {
    # Mock is available here
}
```

## Running Specific Test Patterns

```powershell
# Run only tests matching a pattern
Invoke-Pester -Name "Should return*"

# Run tests in parallel (Pester 5.1+)
Invoke-Pester -RunInParallel

# Skip certain tests
Invoke-Pester -ExcludeTag "Slow"
```

## Additional Resources

- [Pester Documentation](https://pester.dev/docs/quick-start)
- [Pester Assertions](https://pester.dev/docs/assertions)
- [Pester Mocking](https://pester.dev/docs/mocking)
- [Pester Configuration](https://pester.dev/docs/configuration)

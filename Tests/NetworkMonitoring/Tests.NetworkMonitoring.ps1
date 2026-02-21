$script:NetworkPath = "C:\jack\dev\SysOps\NetworkMonitoring"

Describe "Get-PortStatus Script Tests" {
    $script:ScriptPath = "$script:NetworkPath\Get-PortStatus.ps1"
    
    Context "Script Existence" {
        It "Should have Get-PortStatus.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept Port parameter" {
            { & $script:ScriptPath -Port 80 } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute and return port status" {
            $result = & $script:ScriptPath -ComputerName "localhost" -Port 135
            $result | Should Not BeNullOrEmpty
            $result.ComputerName | Should Not BeNullOrEmpty
            $result.Port | Should Be 135
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Get-ProcessOnPort.ps1"

Describe "Get-ProcessOnPort Script Tests" {
    Context "Script Existence" {
        It "Should have Get-ProcessOnPort.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Port parameter" {
            { & $script:ScriptPath -Port 80 } | Should Not Throw
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Get-ListeningPorts.ps1"

Describe "Get-ListeningPorts Script Tests" {
    Context "Script Existence" {
        It "Should have Get-ListeningPorts.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            $result = & $script:ScriptPath
            $result | Should Not BeNullOrEmpty
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Test-NetworkConnectivity.ps1"

Describe "Test-NetworkConnectivity Script Tests" {
    Context "Script Existence" {
        It "Should have Test-NetworkConnectivity.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should test localhost connectivity" {
            $result = & $script:ScriptPath -ComputerName "localhost"
            $result | Should Not BeNullOrEmpty
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Test-DNSResolution.ps1"

Describe "Test-DNSResolution Script Tests" {
    Context "Script Existence" {
        It "Should have Test-DNSResolution.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept DomainName parameter" {
            { & $script:ScriptPath -DomainName "google.com" } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should resolve valid domain" {
            $result = & $script:ScriptPath -DomainName "google.com"
            $result | Should Not BeNullOrEmpty
            $result.Resolved | Should Be $true
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Get-NetworkAdapterStatus.ps1"

Describe "Get-NetworkAdapterStatus Script Tests" {
    Context "Script Existence" {
        It "Should have Get-NetworkAdapterStatus.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            $result = & $script:ScriptPath
            $result | Should Not BeNullOrEmpty
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Get-FirewallRules.ps1"

Describe "Get-FirewallRules Script Tests" {
    Context "Script Existence" {
        It "Should have Get-FirewallRules.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Direction parameter" {
            { & $script:ScriptPath -Direction "Inbound" } | Should Not Throw
        }
    }
}

$script:ScriptPath = "$script:NetworkPath\Get-ExpiringCertificates.ps1"

Describe "Get-ExpiringCertificates Script Tests" {
    Context "Script Existence" {
        It "Should have Get-ExpiringCertificates.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept WarningDays parameter" {
            { & $script:ScriptPath -WarningDays 30 } | Should Not Throw
        }
    }
}

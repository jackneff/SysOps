$script:ModulePath = "C:\jack\dev\SysOps\Modules\AdminTools.psm1"
$script:ServiceMonitorPath = "C:\jack\dev\SysOps\ServiceMonitoring"

Describe "ServiceMonitoring Module Tests" {
    Context "AdminTools Module" {
        It "Should import AdminTools module successfully" {
            { Import-Module $script:ModulePath -Force } | Should Not Throw
        }
        
        It "Should have Get-Config function" {
            Import-Module $script:ModulePath -Force
            Get-Command Get-Config | Should Not BeNullOrEmpty
        }
        
        It "Should have Test-ServerReachability function" {
            Import-Module $script:ModulePath -Force
            Get-Command Test-ServerReachability | Should Not BeNullOrEmpty
        }
        
        It "Should have Get-RemoteService function" {
            Import-Module $script:ModulePath -Force
            Get-Command Get-RemoteService | Should Not BeNullOrEmpty
        }
    }
    
    Context "Get-Config Function" {
        Import-Module $script:ModulePath -Force
        
        It "Should return null for non-existent config" {
            $result = Get-Config -ConfigPath "C:\NonExistent\config.json"
            $result | Should BeNullOrEmpty
        }
        
        It "Should load valid config file" {
            $configPath = "C:\jack\dev\SysOps\Config\settings.json"
            if (Test-Path $configPath) {
                $result = Get-Config -ConfigPath $configPath
                $result | Should Not BeNullOrEmpty
                $result.servers | Should Not BeNullOrEmpty
            }
        }
    }
    
    Context "Test-ServerReachability Function" {
        Import-Module $script:ModulePath -Force
        
        It "Should return reachable for localhost" {
            $result = Test-ServerReachability -ComputerName "localhost"
            $result.Reachable | Should Be $true
        }
        
        It "Should return proper hashtable structure" {
            $result = Test-ServerReachability -ComputerName "localhost"
            $result.ComputerName | Should Be "localhost"
            $result.Reachable | Should BeOfType ([System.Boolean])
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Check-ServiceHealth.ps1"

Describe "Check-ServiceHealth Script Tests" {
    Context "Script Existence" {
        It "Should have Check-ServiceHealth.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept ServiceNames parameter" {
            { & $script:ScriptPath -ServiceNames "Spooler" } | Should Not Throw
        }
        
        It "Should accept UseConfig switch" {
            { & $script:ScriptPath -UseConfig } | Should Not Throw
        }
        
        It "Should accept AlertOnStopped switch" {
            { & $script:ScriptPath -AlertOnStopped } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute with local services" {
            $result = & $script:ScriptPath -ComputerName "localhost" -ServiceNames "Spooler" 2>$null
            $result | Should Not BeNullOrEmpty
        }
        
        It "Should return results for valid service" {
            $result = & $script:ScriptPath -ComputerName "localhost" -ServiceNames "Spooler"
            $result.Results | Should Not BeNullOrEmpty
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Check-ServiceStatus.ps1"

Describe "Check-ServiceStatus Script Tests" {
    Context "Script Existence" {
        It "Should have Check-ServiceStatus.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept ServiceName parameter" {
            { & $script:ScriptPath -ServiceName "Spooler" } | Should Not Throw
        }
        
        It "Should accept UseConfig switch" {
            { & $script:ScriptPath -UseConfig } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            $result = & $script:ScriptPath -ComputerName "localhost" -ServiceName "Spooler"
            $result | Should Not BeNullOrEmpty
        }
        
        It "Should return service object with status" {
            $result = & $script:ScriptPath -ComputerName "localhost" -ServiceName "Spooler"
            $result.Count | Should BeGreaterThan 0
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Monitor-CriticalServices.ps1"

Describe "Monitor-CriticalServices Script Tests" {
    Context "Script Existence" {
        It "Should have Monitor-CriticalServices.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Find-HungServices.ps1"

Describe "Find-HungServices Script Tests" {
    Context "Script Existence" {
        It "Should have Find-HungServices.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Find-DisabledAutoStartServices.ps1"

Describe "Find-DisabledAutoStartServices Script Tests" {
    Context "Script Existence" {
        It "Should have Find-DisabledAutoStartServices.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Watch-ServiceStateChanges.ps1"

Describe "Watch-ServiceStateChanges Script Tests" {
    Context "Script Existence" {
        It "Should have Watch-ServiceStateChanges.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ServiceName parameter" {
            { & $script:ScriptPath -ServiceName "Spooler" } | Should Not Throw
        }
    }
}

$script:ScriptPath = "$script:ServiceMonitorPath\Test-ServiceAccountPermissions.ps1"

Describe "Test-ServiceAccountPermissions Script Tests" {
    Context "Script Existence" {
        It "Should have Test-ServiceAccountPermissions.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
}

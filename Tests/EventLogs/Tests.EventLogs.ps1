$script:EventLogsPath = "C:\jack\dev\SysOps\EventLogs"

Describe "Get-EventLogErrors Script Tests" {
    $script:ScriptPath = "$script:EventLogsPath\Get-EventLogErrors.ps1"
    
    Context "Script Existence" {
        It "Should have Get-EventLogErrors.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept LogName parameter" {
            { & $script:ScriptPath -LogName "System" } | Should Not Throw
        }
        
        It "Should accept Hours parameter" {
            { & $script:ScriptPath -Hours 24 } | Should Not Throw
        }
        
        It "Should accept MaxEvents parameter" {
            { & $script:ScriptPath -MaxEvents 50 } | Should Not Throw
        }
        
        It "Should have default ComputerName as localhost" {
            { & $script:ScriptPath } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            { & $script:ScriptPath -LogName "System" -Hours 1 -MaxEvents 10 } | Should Not Throw
        }
        
        It "Should return array of events" {
            $result = & $script:ScriptPath -LogName "System" -Hours 1 -MaxEvents 10
            $result | Should Not BeNullOrEmpty
        }
    }
}

Describe "Get-UserLogonEvents Script Tests" {
    $script:ScriptPath = "$script:EventLogsPath\Get-UserLogonEvents.ps1"
    
    Context "Script Existence" {
        It "Should have Get-UserLogonEvents.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept Days parameter" {
            { & $script:ScriptPath -Days 7 } | Should Not Throw
        }
        
        It "Should accept LogonType parameter" {
            { & $script:ScriptPath -LogonType "Interactive" } | Should Not Throw
        }
        
        It "Should accept IncludeSuccessful switch" {
            { & $script:ScriptPath -IncludeSuccessful } | Should Not Throw
        }
        
        It "Should accept IncludeFailed switch" {
            { & $script:ScriptPath -IncludeFailed } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            { & $script:ScriptPath -Days 1 } | Should Not Throw
        }
    }
}

Describe "Get-SystemRestarts Script Tests" {
    $script:ScriptPath = "$script:EventLogsPath\Get-SystemRestarts.ps1"
    
    Context "Script Existence" {
        It "Should have Get-SystemRestarts.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should Not Throw
        }
        
        It "Should accept Days parameter" {
            { & $script:ScriptPath -Days 7 } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute successfully" {
            { & $script:ScriptPath -Days 1 } | Should Not Throw
        }
    }
}

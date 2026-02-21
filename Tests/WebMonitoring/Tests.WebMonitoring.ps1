$script:WebMonitorPath = "C:\jack\dev\SysOps\WebMonitoring"

Describe "Test-WebApplication Script Tests" {
    $script:ScriptPath = "$script:WebMonitorPath\Test-WebApplication.ps1"
    
    Context "Script Existence" {
        It "Should have Test-WebApplication.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept Url parameter" {
            { & $script:ScriptPath -Url "https://www.google.com" } | Should Not Throw
        }
        
        It "Should accept ExpectedStatusCode parameter" {
            { & $script:ScriptPath -Url "https://www.google.com" -ExpectedStatusCode 200 } | Should Not Throw
        }
        
        It "Should accept TimeoutSeconds parameter" {
            { & $script:ScriptPath -Url "https://www.google.com" -TimeoutSeconds 30 } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should return healthy result for valid URL" {
            $result = & $script:ScriptPath -Url "https://www.google.com"
            $result.IsHealthy | Should Be $true
        }
        
        It "Should return PSCustomObject" {
            $result = & $script:ScriptPath -Url "https://www.google.com"
            $result | Should BeOfType ([PSCustomObject])
        }
        
        It "Should have required properties" {
            $result = & $script:ScriptPath -Url "https://www.google.com"
            $result.Url | Should Not BeNullOrEmpty
            $result.StatusCode | Should Not BeNullOrEmpty
            $result.ResponseTimeMs | Should Not BeNullOrEmpty
        }
    }
}

Describe "Test-WebApplicationBatch Script Tests" {
    $script:ScriptPath = "$script:WebMonitorPath\Test-WebApplicationBatch.ps1"
    
    Context "Script Existence" {
        It "Should have Test-WebApplicationBatch.ps1 script" {
            Test-Path $script:ScriptPath | Should Be $true
        }
    }
    
    Context "Parameter Validation" {
        It "Should accept UseConfig switch" {
            { & $script:ScriptPath -UseConfig } | Should Not Throw
        }
        
        It "Should accept Url parameter" {
            { & $script:ScriptPath -Url "https://www.google.com" } | Should Not Throw
        }
    }
    
    Context "Execution" {
        It "Should execute with single URL" {
            { & $script:ScriptPath -Url "https://www.google.com" } | Should Not Throw
        }
        
        It "Should return results" {
            $result = & $script:ScriptPath -Url "https://www.google.com"
            $result | Should Not BeNullOrEmpty
        }
    }
}

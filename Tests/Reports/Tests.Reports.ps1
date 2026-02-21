BeforeAll {
    $script:ReportsPath = "$PSScriptRoot\..\Reports"
}

Describe "Reports Scripts Tests" {
    Context "Invoke-DailyHealthCheck Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ReportsPath\Invoke-DailyHealthCheck.ps1"
        }
        
        It "Should have Invoke-DailyHealthCheck.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept UseConfig switch" {
            { & $script:ScriptPath -UseConfig } | Should -Not -Throw
        }
        
        It "Should accept SendEmail switch" {
            { & $script:ScriptPath -SendEmail } | Should -Not -Throw
        }
        
        It "Should accept OutputPath parameter" {
            { & $script:ScriptPath -OutputPath "$TestDrive\report.html" } | Should -Not -Throw
        }
    }
}

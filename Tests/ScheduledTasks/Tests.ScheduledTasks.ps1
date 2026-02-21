BeforeAll {
    $script:ScheduledTasksPath = "$PSScriptRoot\..\ScheduledTasks"
}

Describe "Scheduled Tasks Scripts Tests" {
    Context "Get-ScheduledTask Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ScheduledTasksPath\Get-ScheduledTask.ps1"
        }
        
        It "Should have Get-ScheduledTask.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept TaskName parameter" {
            { & $script:ScriptPath -TaskName "*" } | Should -Not -Throw
        }
        
        It "Should accept ComputerName parameter" {
            { & $script:ScriptPath -ComputerName "localhost" } | Should -Not -Throw
        }
    }
    
    Context "New-ScheduledTask Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ScheduledTasksPath\New-ScheduledTask.ps1"
        }
        
        It "Should have New-ScheduledTask.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept TaskName parameter" {
            { & $script:ScriptPath -TaskName "TestTask" } | Should -Not -Throw
        }
        
        It "Should accept Action parameter" {
            { & $script:ScriptPath -TaskName "TestTask" -Action "notepad.exe" } | Should -Not -Throw
        }
        
        It "Should accept Trigger parameter" {
            { & $script:ScriptPath -TaskName "TestTask" -Trigger "Daily" } | Should -Not -Throw
        }
    }
    
    Context "Remove-ScheduledTask Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ScheduledTasksPath\Remove-ScheduledTask.ps1"
        }
        
        It "Should have Remove-ScheduledTask.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept TaskName parameter" {
            { & $script:ScriptPath -TaskName "TestTask" } | Should -Not -Throw
        }
    }
    
    Context "Enable-ScheduledTask Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ScheduledTasksPath\Enable-ScheduledTask.ps1"
        }
        
        It "Should have Enable-ScheduledTask.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept TaskName parameter" {
            { & $script:ScriptPath -TaskName "TestTask" } | Should -Not -Throw
        }
    }
    
    Context "Disable-ScheduledTask Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ScheduledTasksPath\Disable-ScheduledTask.ps1"
        }
        
        It "Should have Disable-ScheduledTask.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept TaskName parameter" {
            { & $script:ScriptPath -TaskName "TestTask" } | Should -Not -Throw
        }
    }
    
    Context "Get-ScheduledTaskHistory Script" {
        BeforeAll {
            $script:ScriptPath = "$script:ScheduledTasksPath\Get-ScheduledTaskHistory.ps1"
        }
        
        It "Should have Get-ScheduledTaskHistory.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept TaskName parameter" {
            { & $script:ScriptPath -TaskName "*" } | Should -Not -Throw
        }
        
        It "Should accept MaxEvents parameter" {
            { & $script:ScriptPath -MaxEvents 50 } | Should -Not -Throw
        }
    }
}

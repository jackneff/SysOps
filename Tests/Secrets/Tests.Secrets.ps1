BeforeAll {
    $script:SecretsPath = "$PSScriptRoot\..\Secrets"
}

Describe "Secrets Scripts Tests" {
    Context "Get-Secret Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\Get-Secret.ps1"
        }
        
        It "Should have Get-Secret.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Name parameter" {
            { & $script:ScriptPath -Name "test" } | Should -Not -Throw
        }
    }
    
    Context "New-StoredCredential Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\New-StoredCredential.ps1"
        }
        
        It "Should have New-StoredCredential.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Target parameter" {
            { & $script:ScriptPath -Target "TestTarget" } | Should -Not -Throw
        }
        
        It "Should accept Username parameter" {
            { & $script:ScriptPath -Target "TestTarget" -Username "testuser" } | Should -Not -Throw
        }
    }
    
    Context "Get-StoredCredential Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\Get-StoredCredential.ps1"
        }
        
        It "Should have Get-StoredCredential.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Target parameter" {
            { & $script:ScriptPath -Target "TestTarget" } | Should -Not -Throw
        }
    }
    
    Context "Get-WindowsCredential Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\Get-WindowsCredential.ps1"
        }
        
        It "Should have Get-WindowsCredential.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Target parameter" {
            { & $script:ScriptPath -Target "TestTarget" } | Should -Not -Throw
        }
    }
    
    Context "New-EncryptedPassword Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\New-EncryptedPassword.ps1"
        }
        
        It "Should have New-EncryptedPassword.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Password parameter" {
            { & $script:ScriptPath -Password "testpassword" } | Should -Not -Throw
        }
    }
    
    Context "Invoke-Vaultwarden Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\Invoke-Vaultwarden.ps1"
        }
        
        It "Should have Invoke-Vaultwarden.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept Command parameter" {
            { & $script:ScriptPath -Command "list" } | Should -Not -Throw
        }
    }
    
    Context "Invoke-AzureKeyVault Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\Invoke-AzureKeyVault.ps1"
        }
        
        It "Should have Invoke-AzureKeyVault.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
        
        It "Should accept VaultName parameter" {
            { & $script:ScriptPath -VaultName "testvault" } | Should -Not -Throw
        }
        
        It "Should accept SecretName parameter" {
            { & $script:ScriptPath -VaultName "testvault" -SecretName "testsecret" } | Should -Not -Throw
        }
    }
    
    Context "Install-SecretModules Script" {
        BeforeAll {
            $script:ScriptPath = "$script:SecretsPath\Install-SecretModules.ps1"
        }
        
        It "Should have Install-SecretModules.ps1 script" {
            Test-Path $script:ScriptPath | Should -Be $true
        }
    }
}

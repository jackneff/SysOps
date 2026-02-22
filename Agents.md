# AGENTS.md - PowerShell Module Development

## Project Overview

- **Project Type**: PowerShell Script Collection
- **Framework**: PowerShell Core 5.1
- **Module Name**: `SysOps`

## Coding Style & Conventions

- **Naming**: Use PascalCase for functions, variables, and parameters (e.g., `Get-Item`).
- **Verbs**: Use approved PowerShell verbs (`Get-`, `Set-`, `New-`, `Remove-`, `Test-`).
- **Documentation**: All public functions MUST include comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`) [6].
- **Formatting**: Use 4 spaces for indentation.
- **Best Practices**:
  - Use `[CmdletBinding()]` for advanced functions.
  - Explicitly define `param()` blocks.
  - Avoid aliases in scripts (e.g., use `Get-ChildItem`, not `dir` or `ls`).
  - Use `Write-Verbose` for debugging instead of `Write-Host`.

## Structure

- `./Functions/`: Individual `.ps1` files for each function.
- `./Public/`: Publicly exported functions.
- `./Private/`: Helper functions not exported in `MyCompany.Automation.psd1`.
- `./Tests/`: Pester tests (Pester 5+).

## Development & Testing

- **Editor**: VS Code with PowerShell Extension.
- **Testing**: Run tests using `Invoke-Pester -Path ./Tests`.
- **Linting**: Run `Invoke-ScriptAnalyzer -Path . -Recurse` before committing [6].

## Security Considerations

- Never hardcode credentials. Use `Get-Secret` from the `Microsoft.PowerShell.SecretManagement` module.
- Validate all input parameters using `[ValidateScript()]` or `[ValidateNotNullOrEmpty()]`.

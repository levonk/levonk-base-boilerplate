# {{package_name | title_case}}

{{package_description}}

## Features

- **Structured Logging**: Comprehensive logging with configurable levels
- **Context Processing**: Process data with context-aware operations
- **Error Handling**: Robust error handling with detailed error messages
- **Module Design**: Clean PowerShell module with exported functions

## Prerequisites

- PowerShell {{powershell_version}} or higher
- Windows PowerShell 5.1+ or PowerShell Core 6.0+

## Installation

### Option 1: Import Module

```powershell
# Import the module
Import-Module .\{{package_name}}.psm1

# Verify installation
Get-Command -Module {{package_name}}
```

### Option 2: Install to System

```powershell
# Copy to PowerShell modules directory
Copy-Item -Path ".\{{package_name}}.psm1" -Destination "$env:ProgramFiles\WindowsPowerShell\Modules\{{package_name}}\" -Recurse

# Import
Import-Module {{package_name}}
```

## Usage

### Basic Operations

```powershell
# Process data with context
$result = Invoke-{{package_name | title_case}}Process -Input "hello" -Context "test-context"
Write-Output $result  # Output: HELLO

# Multiply numbers
$doubled = Invoke-{{package_name | title_case}}Multiply -Value 5
Write-Output $doubled  # Output: 10
```

### Logging Configuration

```powershell
# Configure log level (default: INFO)
$Script:LogLevel = 'DEBUG'

# Configure log format
$Script:LogFormat = '[$timestamp] [$level] $message'
```

## Development

### Project Structure

```text
src/
└── {{package_name}}.psm1
tests/
└── test_{{package_name}}.tests.ps1
README.md
```

### Testing

```powershell
# Run tests
Invoke-Pester -Path .\tests\

# Run with verbose output
Invoke-Pester -Path .\tests\ -Verbose
```

### Module Functions

- `Invoke-{{package_name | title_case}}Process` - Process input data with context
- `Invoke-{{package_name | title_case}}Multiply` - Multiply numbers by two
- `Write-ModuleLog` - Internal logging function

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run all tests with Pester
6. Submit a pull request

## License

{{license}}

## Author

{{author_name}} <{{author_email}}>

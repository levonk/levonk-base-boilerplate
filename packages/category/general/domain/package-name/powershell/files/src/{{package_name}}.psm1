# {{package_description}}
# Author: {{author_name}} <{{author_email}}>
# License: {{license}}

<#
.SYNOPSIS
    Sample PowerShell module demonstrating basic functionality and logging.

.DESCRIPTION
    This module provides example functions for common operations with structured logging.

.EXAMPLE
    PS C:\> Import-Module .\{{package_name}}.psm1
    PS C:\> Invoke-{{package_name | title_case}}Process -Input "hello" -Context "test"
#>

# Module variables
$Script:LogLevel = 'INFO'
$Script:LogFormat = '[$timestamp] [$level] $message'

<#
.SYNOPSIS
    Writes a structured log message.

.DESCRIPTION
    Internal function for consistent logging across the module.

.PARAMETER Message
    The message to log.

.PARAMETER Level
    The log level (DEBUG, INFO, WARN, ERROR).
#>
function Write-ModuleLog {
    param(
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('DEBUG', 'INFO', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = $Script:LogFormat -replace '\$timestamp', $timestamp -replace '\$level', $Level -replace '\$message', $Message
    
    switch ($Level) {
        'DEBUG' { Write-Debug $logEntry }
        'INFO'  { Write-Information $logEntry -InformationAction Continue }
        'WARN'  { Write-Warning $logEntry }
        'ERROR' { Write-Error $logEntry }
    }
}

<#
.SYNOPSIS
    Processes input data with context-aware logging.

.DESCRIPTION
    Demonstrates string processing with comprehensive logging.

.PARAMETER Input
    The input string to process.

.PARAMETER Context
    Processing context information.

.EXAMPLE
    PS C:\> Invoke-{{package_name | title_case}}Process -Input "hello" -Context "test"
    Returns "HELLO"
#>
function Invoke-{{package_name | title_case}}Process {
    param(
        [Parameter(Mandatory)]
        [string]$Input,
        
        [Parameter(Mandatory)]
        [string]$Context
    )
    
    Write-ModuleLog "Starting process with context: $Context" -Level 'INFO'
    Write-ModuleLog "Input received: $Input" -Level 'DEBUG'
    
    try {
        $result = $Input.ToUpper()
        Write-ModuleLog "Processing completed successfully" -Level 'INFO'
        return $result
    }
    catch {
        Write-ModuleLog "Processing failed: $($_.Exception.Message)" -Level 'ERROR'
        throw "Processing failed: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Multiplies a number by two.

.DESCRIPTION
    Simple mathematical operation with logging.

.PARAMETER Value
    The number to multiply.

.EXAMPLE
    PS C:\> Invoke-{{package_name | title_case}}Multiply -Value 5
    Returns 10
#>
function Invoke-{{package_name | title_case}}Multiply {
    param(
        [Parameter(Mandatory)]
        [int]$Value
    )
    
    Write-ModuleLog "Multiplying $Value by 2" -Level 'DEBUG'
    return $Value * 2
}

# Export module functions
Export-ModuleMember -Function @(
    'Invoke-{{package_name | title_case}}Process',
    'Invoke-{{package_name | title_case}}Multiply'
)

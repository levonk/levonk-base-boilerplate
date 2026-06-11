# Structured Error Format Specification

## Overview

This specification defines the structured error format for the Go CLI. Errors are output to stdout in the same format as normal output (TOON or JSON), enabling agents to parse and act on failures programmatically.

## Design Principles

1. **Structured Output**: Errors use the same format as successful output (TOON/JSON)
2. **Stdout for Errors**: Errors go to stdout, diagnostics go to stderr
3. **No Raw Leakage**: Raw dependency output never leaks through
4. **Actionable Suggestions**: Suggestions reference CLI commands, not underlying tools
5. **Programmatically Parseable**: Agents can extract error type, message, and suggestions

## Error Object Structure

### TOON Format

```toon
error[type:config,message:Configuration file not found,suggestion:Run '{{ project_slug }} config init' to create a configuration file,exit_code:3]
```

### JSON Format

```json
{
  "error": {
    "type": "config",
    "message": "Configuration file not found",
    "suggestion": "Run '{{ project_slug }} config init' to create a configuration file",
    "exit_code": 3,
    "context": {
      "file": "/path/to/config.yaml",
      "line": 10,
      "column": 5
    }
  }
}
```

## Error Types

| Type | Exit Code | Description |
|------|-----------|-------------|
| `general` | 1 | General error |
| `config` | 3 | Configuration error |
| `file` | 4 | File operation error |
| `network` | 1 | Network error |
| `permission` | 1 | Permission error |
| `validation` | 2 | Validation error (usage) |
| `execution` | 1 | Execution error |
| `platform` | 1 | Platform error |

## Error Fields

### Required Fields

- `type`: Error type (string, enum from ErrorType)
- `message`: Human-readable error message (string)
- `suggestion`: Actionable suggestion referencing CLI commands (string)
- `exit_code`: Exit code for the error (integer)

### Optional Fields

- `context`: Additional context (object)
  - `file`: File path where error occurred (string)
  - `line`: Line number (integer)
  - `column`: Column number (integer)
  - `function`: Function name (string)
  - `module`: Module name (string)

## Suggestion Guidelines

1. **Reference CLI Commands**: Suggestions should reference the CLI's own commands, not underlying tools
   - ✅ "Run `{{ project_slug }} config init` to create a configuration file"
   - ❌ "Run `touch ~/.config/{{ project_slug }}/config.yaml`"

2. **Be Actionable**: Suggestions should provide concrete next steps
   - ✅ "Run `{{ project_slug }} auth login` to authenticate"
   - ❌ "Authentication is required"

3. **Context-Aware**: Suggestions should be specific to the error context
   - ✅ "Check your configuration file at $HOME/.config/{{ project_slug }}/config.yaml"
   - ❌ "Check your configuration"

## Output Channel Separation

### Stdout (Structured Output)

- Error objects in TOON or JSON format
- Success output in TOON or JSON format
- All programmatic output

### Stderr (Diagnostics)

- Debug logging
- Progress information
- Stack traces (in debug mode)
- Internal diagnostics

## Error Validation

Before calling dependencies, validate:

1. **Input Validation**: Validate all inputs before passing to dependencies
2. **File Existence**: Check file existence before operations
3. **Permissions**: Check permissions before operations
4. **Configuration**: Validate configuration before use
5. **Network**: Validate URLs and network accessibility

## Error Translation

When wrapping dependency errors:

1. **Extract Meaning**: Parse dependency error to extract actionable meaning
2. **Translate**: Translate to CLI-specific error type and message
3. **Suggest**: Provide CLI-specific suggestion
4. **Sanitize**: Remove internal implementation details

Example:
```go
// Raw dependency error: "ENOENT: no such file or directory, open '/tmp/config.yaml'"
// Translated structured error:
{
  "error": {
    "type": "file",
    "message": "Configuration file not found",
    "suggestion": "Run '{{ project_slug }} config init' to create a configuration file",
    "exit_code": 4
  }
}
```

## Integration with Output Formats

### TOON Integration

Errors are encoded as TOON objects with the `error` key:

```go
errorValue := toon.Object{
    Fields: map[string]toon.Value{
        "type":       toon.StringValue("config"),
        "message":    toon.StringValue("Configuration file not found"),
        "suggestion": toon.StringValue("Run '{{ project_slug }} config init'"),
        "exit_code":  toon.NumberValue(3),
    },
}
```

### JSON Integration

Errors are encoded as JSON objects with the `error` key:

```go
errorMap := map[string]interface{}{
    "error": map[string]interface{}{
        "type":       "config",
        "message":    "Configuration file not found",
        "suggestion": "Run '{{ project_slug }} config init'",
        "exit_code":  3,
    },
}
```

## Implementation Requirements

1. **New Package**: `internal/errors` package for error formatting
2. **Formatter Integration**: Integrate with existing `formatting.Formatter`
3. **Channel Separation**: Separate stdout (errors) from stderr (diagnostics)
4. **Validation Layer**: Add validation before dependency calls
5. **Translation Layer**: Add error translation for dependency errors
6. **Test Coverage**: Unit tests for all error formatting scenarios

## Migration Path

1. Create new `internal/errors` package with structured error formatting
2. Update `ExitWithError` to use structured format to stdout
3. Update all error paths to use structured format
4. Add validation layer before dependency calls
5. Add error translation for dependency errors
6. Update tests to verify structured error output
7. Update help text to document error format

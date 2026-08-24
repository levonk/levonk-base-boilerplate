# Structured Error Format Specification

## Overview

This specification defines the structured error format for Rust CLI tools following AXI (Agent eXperience Interface) standards. Errors are formatted consistently with normal output to enable agents to parse and act on failures programmatically.

## Design Principles

1. **Structured on stdout**: Errors go to stdout in the same format as normal output (TOON/JSON)
2. **Actionable suggestions**: Every error includes at least one actionable next step
3. **No raw dependency output**: Never leak API errors, stack traces, or tool-specific messages
4. **CLI command references**: Suggestions reference CLI commands, not underlying tools
5. **Exit code semantics**: 0 = success (including no-ops), 1 = error, 2 = usage error

## Error Format Structure

### TOON Format

```
error[1]{code,message}: "MISSING_REQUIRED_FLAG","--title is required"
help[1]: "mytool create --title \"...\" [--body \"...\"]"
```

### JSON Format

```json
{
  "error": {
    "code": "MISSING_REQUIRED_FLAG",
    "message": "--title is required"
  },
  "help": [
    "mytool create --title \"...\" [--body \"...\"]"
  ]
}
```

### Human Format

```
Error: --title is required

Suggestion: Run mytool create --title "..." [--body "..."]
```

## Error Codes

### Validation Errors (Exit Code 2)

| Code | Description | Common Causes |
|------|-------------|---------------|
| `MISSING_REQUIRED_FLAG` | Required flag not provided | User omitted required argument |
| `INVALID_FLAG_VALUE` | Flag value is invalid | Value doesn't match expected format |
| `CONFLICTING_FLAGS` | Mutually exclusive flags provided | User provided incompatible options |
| `UNKNOWN_FLAG` | Unknown flag provided | Typo or unsupported option |

### Operational Errors (Exit Code 1)

| Code | Description | Common Causes |
|------|-------------|---------------|
| `NOT_FOUND` | Resource not found | ID or name doesn't exist |
| `ALREADY_EXISTS` | Resource already exists | Attempt to create duplicate |
| `PERMISSION_DENIED` | Insufficient permissions | Auth or authorization failure |
| `NETWORK_ERROR` | Network operation failed | Connection or timeout issues |
| `INTERNAL_ERROR` | Unexpected internal error | Bug or unexpected state |

### Idempotent Success (Exit Code 0)

| Code | Description | Example |
|------|-------------|---------|
| `NO_OP` | Desired state already exists | Task already closed, file already exists |

## Suggestion Format

Solutions must be:
- **Complete**: Include all necessary flags and arguments
- **Actionable**: Can be copy-pasted and executed
- **Context-aware**: Based on current state and error context
- **CLI-focused**: Reference CLI commands, not underlying tools

### Suggestion Patterns

| Error Type | Suggestion Pattern |
|------------|-------------------|
| Missing required flag | `<command> --<flag> "..." [--optional-flag "..."]` |
| Invalid value | `<command> --<flag> <valid-value>` |
| Not found | `<command> list` to find valid IDs |
| Already exists | `<command> view <id>` to check existing |
| Permission denied | `<command> --auth` or check credentials |

## Error Channel Separation

### stdout (Structured Output)
- Error messages in structured format (TOON/JSON)
- Actionable suggestions
- Exit codes

### stderr (Diagnostics)
- Debug logging (when `--debug` is set)
- Progress indicators
- Stack traces (only in debug mode)
- Tool-specific diagnostics

## Error Translation Rules

1. **Validate before dependencies**: Check all flags and arguments before calling external tools
2. **Extract actionable meaning**: Parse raw errors to identify the core issue
3. **Discard noise**: Remove stack traces, tool-specific jargon, and irrelevant details
4. **Map to error codes**: Translate raw errors to standard error codes
5. **Generate suggestions**: Create CLI-specific suggestions based on error context

## Examples

### Missing Required Flag

**Input**: `mytool create --body "Fix the bug"`

**Output (TOON)**:
```
error[1]{code,message}: "MISSING_REQUIRED_FLAG","--title is required"
help[1]: "mytool create --title \"...\" --body \"Fix the bug\""
```

**Output (JSON)**:
```json
{
  "error": {
    "code": "MISSING_REQUIRED_FLAG",
    "message": "--title is required"
  },
  "help": [
    "mytool create --title \"...\" --body \"Fix the bug\""
  ]
}
```

### Resource Not Found

**Input**: `mytool view 999`

**Output (TOON)**:
```
error[1]{code,message}: "NOT_FOUND","Task #999 not found"
help[1]: "mytool list"
help[2]: "mytool view <id>"
```

**Output (JSON)**:
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Task #999 not found"
  },
  "help": [
    "mytool list",
    "mytool view <id>"
  ]
}
```

### Idempotent No-Op

**Input**: `mytool close 42` (task 42 already closed)

**Output (TOON)**:
```
task[1]{id,status}: "42","closed"
note[1]: "Task #42 already closed (no-op)"
```

**Exit code**: 0

## Implementation Requirements

1. **Error formatter**: Centralized function to format errors in all output formats
2. **Suggestion generator**: Context-aware suggestion engine based on error type
3. **Validator**: Pre-dependency validation for all flags and arguments
4. **Translator**: Error translation layer for external tool errors
5. **Channel separation**: Separate stdout (structured) from stderr (diagnostics)
6. **Integration**: Integrate with TOON and JSON output formatters

## Testing Requirements

- Unit tests for error formatting in all formats (TOON, JSON, human)
- Unit tests for suggestion generation for each error type
- Integration tests for error channel separation
- Integration tests for error translation from external tools
- Property tests for error format consistency

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- TOON Format: https://toonformat.dev/reference/spec.html
- ADR-20260607001: CLI Tool Standards v4.0.0

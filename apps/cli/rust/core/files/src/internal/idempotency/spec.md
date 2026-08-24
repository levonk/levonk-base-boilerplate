# Idempotency Specification

## Overview

This specification defines idempotency strategies for CLI operations to ensure that repeating commands doesn't cause errors when the desired state already exists.

## State-Changing Operations

### Common Operation Types

| Operation Type | Description | Idempotency Strategy |
|----------------|-------------|---------------------|
| **Create** | Create a new resource | Skip if resource already exists with same identifier/attributes |
| **Update** | Modify an existing resource | Skip if resource already has desired state |
| **Delete** | Remove a resource | Skip if resource doesn't exist |
| **Close** | Change status to closed | Skip if already closed |
| **Open** | Change status to open | Skip if already open |
| **Move** | Move/rename resource | Skip if already at destination |
| **Enable** | Enable a feature | Skip if already enabled |
| **Disable** | Disable a feature | Skip if already disabled |

## Idempotency Strategies

### Create Operations

**Strategy**: Check existence before creation

**Behavior**:
- If resource exists with same identifier:
  - Compare attributes with requested state
  - If attributes match: Return success with no-op acknowledgment (exit code 0)
  - If attributes differ: Return error (conflict) or update based on policy
- If resource doesn't exist: Create normally

**Example**:
```bash
# First call: creates resource
mytool create --id 42 --title "Fix bug"

# Second call (same attributes): no-op
mytool create --id 42 --title "Fix bug"
# Output: task[1]{id,status}: "42","open"
#         note[1]: "Task #42 already exists with desired state (no-op)"
# Exit code: 0

# Third call (different attributes): error or update
mytool create --id 42 --title "Different title"
# Output: error[1]{code,message}: "ALREADY_EXISTS","Task #42 exists with different title"
#         help[1]: "mytool update 42 --title \"Different title\""
# Exit code: 1
```

### Update Operations

**Strategy**: Check current state before update

**Behavior**:
- If resource doesn't exist: Return error (not found)
- If resource exists:
  - Compare current state with desired state
  - If states match: Return success with no-op acknowledgment (exit code 0)
  - If states differ: Update normally

**Example**:
```bash
# First call: updates resource
mytool update 42 --title "New title"

# Second call (same state): no-op
mytool update 42 --title "New title"
# Output: task[1]{id,title}: "42","New title"
#         note[1]: "Task #42 already has desired state (no-op)"
# Exit code: 0
```

### Delete Operations

**Strategy**: Check existence before deletion

**Behavior**:
- If resource doesn't exist: Return success with no-op acknowledgment (exit code 0)
- If resource exists: Delete normally

**Example**:
```bash
# First call: deletes resource
mytool delete 42

# Second call: no-op
mytool delete 42
# Output: note[1]: "Task #42 already deleted (no-op)"
# Exit code: 0
```

### Close Operations

**Strategy**: Check status before closing

**Behavior**:
- If resource doesn't exist: Return error (not found)
- If resource already closed: Return success with no-op acknowledgment (exit code 0)
- If resource open: Close normally

**Example**:
```bash
# First call: closes task
mytool close 42

# Second call: no-op
mytool close 42
# Output: task[1]{id,status}: "42","closed"
#         note[1]: "Task #42 already closed (no-op)"
# Exit code: 0
```

## No-Op Acknowledgment Format

### TOON Format
```
resource[1]{id,status}: "42","closed"
note[1]: "Task #42 already closed (no-op)"
```

### JSON Format
```json
{
  "resource": {
    "id": "42",
    "status": "closed"
  },
  "note": "Task #42 already closed (no-op)"
}
```

### Human Format
```
Task #42 already closed (no-op)
```

## Exit Code Semantics

| Scenario | Exit Code | Error Code |
|----------|-----------|------------|
| Successful operation | 0 | - |
| No-op (desired state exists) | 0 | NO_OP |
| Resource not found (for update/delete) | 1 | NOT_FOUND |
| Conflict (create with different attributes) | 1 | ALREADY_EXISTS |
| Permission denied | 1 | PERMISSION_DENIED |
| Invalid input | 2 | INVALID_FLAG_VALUE |
| Missing required flag | 2 | MISSING_REQUIRED_FLAG |

## Implementation Requirements

1. **State Checking**: Always check current state before applying changes
2. **Comparison Logic**: Implement proper comparison for each resource type
3. **No-Op Messages**: Provide clear, descriptive no-op acknowledgments
4. **Exit Code 0**: Always use exit code 0 for successful no-ops
5. **Error Translation**: Use structured error system for actual errors
6. **Logging**: Add debug logging for idempotency decisions

## Performance Considerations

- **Optimize State Queries**: Use efficient queries to check state
- **Caching**: Consider caching state checks for frequently accessed resources
- **Batch Operations**: For batch operations, check all states before applying changes
- **Early Exit**: Return early when no-op is detected

## Security Considerations

- **No Bypass**: Idempotency must not bypass security controls
- **Audit Trail**: Log all operations including no-ops for audit purposes
- **Sensitive Data**: No-op messages must not leak sensitive information
- **Authorization**: State checking must respect authorization rules

## Testing Requirements

- Unit tests for state comparison logic
- Integration tests for idempotent command behavior
- Exit code verification tests
- No-op message format tests
- Performance tests for state checking

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- Structured Error Format: `src/internal/errors/format-spec.md`

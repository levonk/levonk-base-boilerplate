# Prompt Suppression Specification

## Overview

This specification defines prompt suppression behavior for CLI operations to ensure agent mode is non-interactive while human mode retains prompts (unless overridden).

## Common Interactive Prompts

### CLI-Level Prompts

| Prompt Type | Description | Flag Alternative | Agent Mode | Human Mode |
|-------------|-------------|-----------------|------------|------------|
| **Confirmation** | Confirm destructive operations | `--force` / `--yes` | Skip (auto-confirm) | Prompt (unless `--force`) |
| **Input** | Request missing required value | `--value` flag | Fail with error | Prompt |
| **Selection** | Choose from options | `--option` flag | Fail with error | Prompt |
| **Password** | Request credentials | `--password` / `--token` | Fail with error | Prompt |
| **Multi-select** | Select multiple items | `--items` flag | Fail with error | Prompt |

### Wrapped Tool Prompts

| Tool Type | Prompt Scenario | Suppression Method |
|-----------|----------------|-------------------|
| **Package managers** | Confirmation for install | `--yes` / `-y` flag |
| **Version control** | Commit message | `--message` / `-m` flag |
| **Build tools** | Configuration selection | `--config` flag |
| **Deployment tools** | Environment selection | `--env` flag |

## Prompt Suppression Strategy

### Mode-Based Behavior

**Agent Mode (mode = "agent")**
- All interactive prompts are suppressed
- Missing required values fail immediately with structured error
- Destructive operations auto-confirm (no confirmation prompt)
- Wrapped tools invoked with non-interactive flags

**Human Mode (mode = "human")**
- Interactive prompts work normally
- `--force` flag bypasses confirmation prompts
- Missing required values prompt for input
- Wrapped tools invoked normally (unless `--force`)

### Implementation Requirements

1. **Mode Detection**: Use mode detection from story 01-001
2. **Prompt Suppressor**: Centralized module to control prompt behavior
3. **Flag-Based Alternatives**: Every prompted operation must have a flag alternative
4. **Immediate Failure**: Missing required values fail with clear error in agent mode
5. **Force Flag**: `--force` flag bypasses prompts in human mode
6. **Tool Wrapper**: Wrapped tools invoked with non-interactive flags in agent mode

## Error Messages for Missing Values

### Missing Required Flag

**Agent Mode (fail immediately)**
```
error[2]{code,message}: "MISSING_REQUIRED_FLAG","--title is required"
help[1]: "{{ project_slug }} create --title \"...\""
```

**Human Mode (prompt)**
```
Enter title: [prompt for input]
```

### Missing Selection

**Agent Mode (fail immediately)**
```
error[2]{code,message}: "MISSING_REQUIRED_FLAG","--environment is required"
help[1]: "{{ project_slug }} deploy --environment <production|staging|dev>"
```

**Human Mode (prompt)**
```
Select environment:
1) production
2) staging
3) dev
Enter choice [1-3]:
```

## --force Flag Behavior

### Human Mode

**Without --force**
```
⚠️  This will delete file: important.txt [y/N]:
```

**With --force**
```
Deleting file: important.txt
```

### Agent Mode

**Always behaves as if --force is set**
```
Deleting file: important.txt
```

## Wrapped Tool Suppression

### Package Managers

**npm**
```bash
# Human mode
npm install package

# Agent mode
npm install package --yes --silent
```

**pip**
```bash
# Human mode
pip install package

# Agent mode
pip install package --quiet --no-input
```

### Version Control

**git**
```bash
# Human mode
git commit

# Agent mode
git commit --message "Automated commit"
```

## Implementation Examples

### Confirmation Prompt

```rust
use crate::internal::prompts::PromptSuppressor;
use crate::internal::mode::Mode;

let suppressor = PromptSuppressor::new(mode);

if suppressor.should_prompt_confirmation() {
    // Show confirmation prompt
    let confirmed = confirm("Delete this file?");
    if !confirmed {
        return Ok(());
    }
}
// Proceed with operation
```

### Input Prompt

```rust
let suppressor = PromptSuppressor::new(mode);

if let Some(value) = args.title {
    // Use provided value
} else if suppressor.is_agent_mode() {
    // Fail with error
    let error = StructuredError::new(
        ErrorCode::MissingRequiredFlag,
        "--title is required"
    );
    return Err(error.into());
} else {
    // Prompt for input
    let title = prompt("Enter title:");
}
```

### Wrapped Tool Invocation

```rust
let suppressor = PromptSuppressor::new(mode);

let mut cmd = Command::new("npm");
cmd.arg("install");
cmd.arg("package");

if suppressor.is_agent_mode() {
    cmd.arg("--yes");
    cmd.arg("--silent");
}

cmd.spawn()?;
```

## Testing Requirements

- Unit tests for prompt suppression logic
- Integration tests for agent mode behavior
- Integration tests for human mode behavior
- Tests for --force flag behavior
- Tests for wrapped tool suppression

## Security Considerations

- Prompt suppression must not bypass security controls
- Error messages must not leak sensitive information
- --force flag should be documented as potentially dangerous
- Auto-confirmation in agent mode should be logged

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- Mode Selection (01-001): `src/internal/mode/detection.rs`
- Structured Errors (03-001): `src/internal/errors/format-spec.md`

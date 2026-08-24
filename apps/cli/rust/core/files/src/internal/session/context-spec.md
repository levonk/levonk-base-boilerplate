# Session Context Specification

## Overview

This specification defines the session context output format for ambient context injection in AI agents. Session context provides compact, token-efficient state information about the current working directory and CLI session.

## Session Context Format

### TOON Format (Compact)

```
cwd: "/path/to/project"
repo_root: "/path/to/project"
repo_type: "git"
branch: "main"
recent_operations: 5
session_id: "abc123"
```

### JSON Format

```json
{
  "cwd": "/path/to/project",
  "repo_root": "/path/to/project",
  "repo_type": "git",
  "branch": "main",
  "recent_operations": 5,
  "session_id": "abc123"
}
```

## Context Fields

| Field | Description | Token Budget |
|-------|-------------|--------------|
| `cwd` | Current working directory | Required |
| `repo_root` | Repository root (if in repo) | Required if in repo |
| `repo_type` | Repository type (git, hg, svn, jj) | Required if in repo |
| `branch` | Current branch name | Required if in repo |
| `recent_operations` | Count of recent operations in this directory | Optional |
| `session_id` | Unique session identifier | Optional |

## Token Budget Awareness

Session context must be token-efficient:
- Use relative paths where possible
- Truncate long paths with `...` notation
- Limit recent operations count to single digit
- Omit optional fields if not needed
- Total target: < 100 tokens

## Directory Scoping

Session context is directory-scoped to the current working directory:
- Context reflects state of `cwd` at time of command
- Changes when directory changes
- No cross-directory state mixing
- Each directory has independent context

## Implementation Requirements

1. **Compact TOON Output**: Use minimal TOON syntax for efficiency
2. **Repository Detection**: Auto-detect VCS type and root
3. **Path Resolution**: Resolve and format paths appropriately
4. **Token Budgeting**: Apply truncation for long values
5. **Directory Scoping**: Always use current working directory
6. **Session Tracking**: Generate unique session ID per CLI invocation

## Hook Registration

### Hook Types

| Hook Type | Purpose | Platform |
|-----------|---------|----------|
| Session Start | Inject context at session start | Claude Code, Codex |
| Session End | Capture session metadata at end | Claude Code, Codex |

### Hook Installation

**Claude Code** (`.claude/settings.json`)
```json
{
  "shellCommand": "{{ project_slug }} --session-context",
  "description": "Inject session context"
}
```

**Codex** (`.codex/hooks.json`)
```json
{
  "sessionStart": "{{ project_slug }} --session-context",
  "sessionEnd": "{{ project_slug }} --session-end"
}
```

### Portable Command Resolution

Hooks must use portable command resolution:
1. Check if command is in PATH
2. If in PATH: Use command name only
3. If not in PATH: Use absolute path
4. Verify command is executable

### Idempotent Installation

Hook installation must be idempotent:
- Check if hook already exists
- If exists with same path: Silent no-op
- If exists with different path: Update path
- If doesn't exist: Create new hook

## Session Metadata

Session metadata captured at session end:
- Session ID
- Start time
- End time
- Operations performed
- Directory worked in
- Exit code

## Security Considerations

- Session context must not leak sensitive information
- Paths should be sanitized if they contain secrets
- Hook files must have secure permissions (0600 for files, 0700 for directories)
- Portable command resolution must not execute arbitrary commands

## Testing Requirements

- Unit tests for context generation
- Unit tests for hook registration
- Integration tests for hook installation
- Tests for idempotent hook installation
- Tests for portable command resolution

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- TOON Format: https://toonformat.dev/reference/spec.html

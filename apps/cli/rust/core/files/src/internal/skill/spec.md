# Agent Skill Specification

## Overview

This specification defines the SKILL.md format for agent discoverability via agentskills.io. The skill is generated from the same content as the no-args home view, with live state stripped and command examples rewritten to non-interactive form.

## SKILL.md Template

```markdown
---
name: "{{ project_name }}"
description: "{{ description }}"
---

# {{ project_name }}

{{ description }}

## Usage

### Basic Commands

{{ project_slug }} <command> [options]

### Output Formats

The CLI supports multiple output formats:
- **TOON**: Compact, token-efficient format for agents
- **JSON**: Structured JSON output
- **Human**: Human-readable text output

Use `--toon`, `--json`, or `--human` flags to select format.

### Agent Mode

The CLI automatically detects agent mode and optimizes output for AI consumption:
- Uses TOON format by default
- Provides minimal default schemas to reduce token consumption
- Suppresses interactive prompts
- Outputs structured errors with actionable suggestions

### Examples

```bash
# List items in TOON format
{{ project_slug }} --toon list-items

# Create a new item
{{ project_slug }} create --title "My Item" --body "Description"

# Update an item
{{ project_slug }} update 42 --title "Updated Title"

# Delete an item
{{ project_slug }} delete 42
```

## Output Formats

### TOON Format

Compact, token-efficient format optimized for AI agents:

```
items[3]{id,title,status}: "1","Task 1","open","2","Task 2","in-progress","3","Task 3","closed"
count: 3 of 10 total
```

### JSON Format

Structured JSON output:

```json
{
  "items": [
    {"id": "1", "title": "Task 1", "status": "open"},
    {"id": "2", "title": "Task 2", "status": "in-progress"},
    {"id": "3", "title": "Task 3", "status": "closed"}
  ],
  "count": 3,
  "total": 10
}
```

## Error Handling

The CLI uses structured error formatting with actionable suggestions:

```
error[2]{code,message}: "MISSING_REQUIRED_FLAG","--title is required"
help[1]: "{{ project_slug }} create --title \"...\""
```

## Idempotent Operations

All state-changing operations are idempotent. Repeating commands when the desired state already exists returns success with exit code 0.

## Configuration

The CLI supports multiple configuration sources with precedence:
1. Command-line arguments
2. Environment variables ({{ PROJECT_SLUG }}_*)
3. Local config (.config/{{ project_slug }}/config.toml)
4. User config (~/.config/myorg/{{ project_slug }}/config.toml)
5. System config (/etc/{{ project_slug }}/config.toml)
6. Default values
```

## Live State Stripping

The skill generation process strips live state from the generated SKILL.md:

### Stripped Content

- Repository-specific paths
- Environment-specific values
- User-specific configuration
- Live operation counts
- Session-specific metadata
- File system state

### Preserved Content

- Command syntax and flags
- Output format examples
- Error format examples
- Configuration precedence
- General usage patterns

## Non-Interactive Command Examples

Command examples in SKILL.md are rewritten to non-interactive form:

### Interactive Form (Stripped)

```bash
# This form is stripped from SKILL.md
{{ project_slug }} create
# Prompts: Enter title: [input]
```

### Non-Interactive Form (Preserved)

```bash
# This form is preserved in SKILL.md
{{ project_slug }} create --title "My Item"
```

## CI Validation

The `--check-skill` command validates that the committed SKILL.md is not stale:

```bash
{{ project_slug }} --check-skill
```

This command:
- Generates current skill content
- Compares with committed SKILL.md
- Fails if content differs
- Provides diff for manual review

## Integration Methods

Users can integrate the CLI with agents via two methods:

### 1. Session Hooks (Recommended for Local Development)

Install session hooks for automatic context injection:

```bash
{{ project_slug }} --install-agent-hooks
```

**Pros**: Automatic context injection, no manual configuration
**Cons**: Requires hook installation, agent-specific configuration

### 2. Agent Skill (Recommended for Cloud/Remote)

Generate and publish SKILL.md for agent discoverability:

```bash
{{ project_slug }} --generate-skill > SKILL.md
```

**Pros**: No installation required, works with agentskills.io
**Cons**: Manual regeneration when CLI changes

**Note**: Users only need one integration method - choose based on use case.

## Implementation Requirements

1. **Skill Generation**: Generate SKILL.md from CLI help and examples
2. **Live State Stripping**: Remove repository-specific and environment-specific content
3. **Non-Interactive Examples**: Rewrite all examples to use flags instead of prompts
4. **Trigger Frontmatter**: Include name and description in YAML frontmatter
5. **CI Validation**: Check skill freshness in CI pipeline
6. **Documentation**: Document both integration methods in README

## Security Considerations

- Generated SKILL.md must not leak sensitive information
- Live state stripping must be comprehensive
- Non-interactive examples must work without user input
- CI validation must prevent stale skills from being committed

## Testing Requirements

- Unit tests for skill generation logic
- Unit tests for live state stripping
- Integration tests for skill validation
- Manual verification of generated SKILL.md format

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- agentskills.io: https://agentskills.io

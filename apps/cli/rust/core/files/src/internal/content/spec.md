# Content-First No-Args Behavior Specification

## Overview

This specification defines content-first no-args behavior where running the CLI with no arguments shows the most relevant live content, not a usage manual. This enables agents to see actual state immediately and act without a second call.

## No-Args Behavior

### Traditional Behavior (Avoided)

```
$ {{ project_slug }}
Usage: {{ project_slug }} [OPTIONS] <COMMAND>

Commands:
  list     List items
  create   Create a new item
  update   Update an existing item
  delete   Delete an item

Options:
  -h, --help     Print help
  -V, --version  Print version
```

### Content-First Behavior (Required)

**Agent Mode (TOON format)**
```
items[5]{id,title,status}: "1","Task 1","open","2","Task 2","in-progress","3","Task 3","closed","4","Task 4","open","5","Task 5","open"
count: 5 of 10 total
recent_operations: 3
```

**Human Mode (Human-readable format)**
```
Current State:
- 5 items total (3 open, 1 in-progress, 1 closed)
- Recent operations: 3
- Repository: main branch

Suggestions:
- {{ project_slug }} list --toon
- {{ project_slug }} create --title "..."
```

## Content Selection Strategy

### Context-Aware Selection

Content selection is based on the current working directory context:

| Context | Content Shown |
|---------|----------------|
| **Project root** | Project summary, recent items, status |
| **Subdirectory** | Directory-specific items, parent context |
| **Empty directory** | Empty state message, creation suggestions |
| **No repository** | File system state, recent operations |

### Most Relevant Live Content

**Priority Order:**
1. Primary entity state (e.g., items, tasks, resources)
2. Pre-computed aggregates (counts, status distribution)
3. Recent operations
4. Repository context (branch, type)
5. Contextual help suggestions

## State Summary Generation

### Components

1. **Primary Entity**: Main data type for the CLI context
2. **Aggregates**: Pre-computed counts and summaries
3. **Recent Activity**: Recent operations in this directory
4. **Repository Context**: VCS information if applicable
5. **Suggestions**: Context-aware next steps

### TOON Format

```
<entity>[N]{<fields>}: <values>
count: <N> of <total> total
recent_operations: <N>
repo: <branch>
help[1]: "<suggestion>"
```

### Human Format

```
Current State:
- <entity summary>
- <aggregates>
- <recent activity>
- <repository context>

Suggestions:
- <suggestion 1>
- <suggestion 2>
```

## Implementation Requirements

1. **Context Detection**: Detect directory context (project root, subdirectory, empty)
2. **Content Selection**: Select most relevant content based on context
3. **State Summary**: Generate summary with aggregates and recent activity
4. **Mode-Aware Output**: Use TOON in agent mode, human-readable in human mode
5. **Help Preservation**: Keep `--help` flag unchanged for detailed usage
6. **Integration**: Integrate pre-computed aggregates and contextual help

## --help Flag Behavior

The `--help` flag must remain unchanged and show detailed usage:

```
$ {{ project_slug }} --help
Usage: {{ project_slug }} [OPTIONS] <COMMAND>

Commands:
  list     List items
  create   Create a new item
  update   Update an existing item
  delete   Delete an item

Options:
  -h, --help     Print help
  -V, --version  Print version
```

## Security Considerations

- No-args output must not leak sensitive information
- File paths should be sanitized if they contain secrets
- Repository context should not expose private data
- Recent operations should not include sensitive content

## Testing Requirements

- Unit tests for content selection logic
- Unit tests for state summary generation
- Integration tests for no-args behavior in different contexts
- Tests for mode-aware output formatting
- Tests for `--help` flag preservation

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- Pre-computed Aggregates (02-003): `src/internal/aggregates/`

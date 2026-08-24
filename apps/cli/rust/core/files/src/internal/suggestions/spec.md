# Contextual Disclosure Specification

## Overview

This specification defines the suggestion engine for contextual disclosure. The engine generates 2-4 relevant, actionable suggestions per output that follow logically from current state. Suggestions are formatted as structured `help[]` array in TOON output.

## Suggestion Engine Architecture

### Components

1. **Suggestion Engine**: Core logic for generating suggestions
2. **Suggestion Rules**: Context-aware rules per command
3. **Suggestion Ranking**: Relevance scoring and sorting
4. **Suggestion Formatter**: TOON `help[]` array formatting

### Flow

```
Command Output → State Analysis → Rule Matching → Ranking → Formatting → Output
```

## Suggestion Rules

### Context-Based Rules

| Context | Suggestion | Example |
|---------|------------|---------|
| **Empty list** | Create first item | `{{ project_slug }} create --title "..."` |
| **Open items** | Close item | `{{ project_slug }} close 42` |
| **List view** | View details | `{{ project_slug }} view 42` |
| **Update success** | View updated item | `{{ project_slug }} view 42` |
| **Delete success** | List remaining | `{{ project_slug }} list` |
| **Error** | Retry with flags | `{{ project_slug }} create --title "..." --force` |

### Command-Specific Rules

**list command**
- If empty: suggest create
- If has items: suggest view first, create new

**create command**
- On success: suggest view created item
- On error: suggest retry with flags

**update command**
- On success: suggest view updated item
- On error: suggest view current state

**delete command**
- On success: suggest list remaining
- On error: suggest view item first

**view command**
- If item exists: suggest update, delete
- If item not found: suggest list all

## Suggestion Ranking

### Relevance Factors

1. **Context match**: How well suggestion matches current state
2. **Actionability**: How complete and executable the suggestion is
3. **Logical flow**: How naturally it follows from current action
4. **Flag carry-forward**: Whether it preserves context flags

### Ranking Algorithm

```
score = (context_match * 0.4) + (actionability * 0.3) + (logical_flow * 0.2) + (flag_carry * 0.1)
```

## Suggestion Format

### TOON Format

```
items[3]{id,title}: "1","Task 1","2","Task 2","3","Task 3"
count: 3 of 10 total
help[2]: "{{ project_slug }} view 1","{{ project_slug }} create --title \"...\""
```

### JSON Format

```json
{
  "items": [
    {"id": "1", "title": "Task 1"},
    {"id": "2", "title": "Task 2"},
    {"id": "3", "title": "Task 3"}
  ],
  "count": 3,
  "total": 10,
  "help": [
    "{{ project_slug }} view 1",
    "{{ project_slug }} create --title \"...\""
  ]
}
```

### Human Format

```
Items: 3 of 10 total

Suggestions:
- {{ project_slug }} view 1
- {{ project_slug }} create --title "..."
```

## Implementation Requirements

1. **Suggestion Engine**: Generate suggestions based on context
2. **Command Rules**: Define rules for each command type
3. **Context Awareness**: Use current state for relevant suggestions
4. **Actionability**: Ensure suggestions are complete commands
5. **Flag Carry-Forward**: Preserve disambiguating flags
6. **Limit**: Maximum 2-4 suggestions per output
7. **Ranking**: Sort by relevance
8. **Integration**: Add to all command outputs

## Security Considerations

- Suggestions must not leak sensitive information
- Suggestions must not bypass security controls
- Flag carry-forward must not expose credentials
- Error suggestions must not reveal internal details

## Testing Requirements

- Unit tests for suggestion generation logic
- Unit tests for suggestion ranking
- Integration tests for suggestion output
- Tests for context awareness
- Tests for flag carry-forward

## References

- AXI Specification: https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md
- Pre-computed Aggregates (02-003): `src/internal/aggregates/`

# Handoff Document Template

## Storage Lifecycle & Commit Conventions

Handoff documents use a two-stage lifecycle:

| Stage | Path | When |
|-------|------|------|
| **Pending** | `.agents/handoffs/todo/YYYYMMDDHHmm-handoffslug.md` | Created — awaiting work |
| **Archived** | `.agents/handoffs/archive/YYYY/MM/YYYYMMDDHHmm-handoffslug.md` | All DoD tasks `[x]` — moved via `git mv` |

The filename never changes between stages. The archive `YYYY/MM/` is derived
from the filename's embedded timestamp (creation date, not completion date).

**Commit messages** (both include a mandatory `#tag` array as the last body
line):

- **Capture** (new handoff):
  ```
  docs(handoff): capture context for {slug}

  Handoff document for session continuation. Records repo state at commit {sha}.

  #project-{project} #module-handoff #type-docs #skill-handoff-capture #skill-grm-created
  ```
- **Archive** (completed handoff, `git mv` todo/ → archive/):
  ```
  docs(handoff): archive completed handoff {slug}

  All Definition of Done tasks verified [x]. Moved from todo/ to archive/{YYYY}/{MM}/.

  #project-{project} #module-handoff #type-docs #skill-handoff-archived #skill-grm-created
  ```

## Document Template

Use this template for consistency when creating handoff documents:

```markdown
# [Descriptive Handoff Title]

**Date**: YYYY-MM-DD
**Session**: [Brief session description]
**Status**: [Current status - e.g., "In progress", "Blocked", "Completed"]

## Current State

### ✅ Completed
- [Completed item 1]
- [Completed item 2]

### ❌ Blocking Issues
1. [Blocking issue 1]
2. [Blocking issue 2]

## Git State

**Commit at handoff**: `<full 40-char SHA>` (captured via `git rev-parse HEAD`
after the pre-handoff commit checkpoint)

This is the exact repo state at handoff time. The receiving session can
reconstruct what was done by inspecting this commit and its history:
- `git show <SHA>` — what the handoff commit changed
- `git log <SHA>..HEAD` — work done since the handoff (during restoration)
- `git diff <SHA>~1 <SHA>` — the last change before handoff

If the target project is not a git repository, replace this section with:
"Not a git repository — no commit hash available."

## Required Reading

Before any other action, read `{REPO_ROOT}/<agent-file>` — it is the root of
this project's progressively-disclosed informational files (JIT index, binding
contracts, conventions). Follow its Usage Protocol and re-read the chain for
any path you touch.

> **Detection**: The capturing session checks in priority order: `AGENTS.md`,
> `AGENT.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `GEMINI.md`,
> `.windsurf/rules/*.md`, `.cursor/rules/*.mdc`, `CONVENTIONS.md`. If multiple
> exist, the largest by byte size wins (pointer/symlink stubs are small).
> Replace `<agent-file>` with the detected path. If none exist, replace this
> section with: "No agent-instructions file found at the project root. No
> progressive-disclosure root to read — proceed without project-level agent
> conventions."

## Project Overview

### Objective
[What we're trying to achieve]

### Current Status
[Where we are in the process]

## Key Decisions Made
- [Decision 1] - [Reason/Brief context]
- [Decision 2] - [Reason/Brief context]

## Technical Context

### Stack/Tools
[List of technologies, frameworks, tools]

### Important Files
- `path/to/file1` - [purpose]
- `path/to/file2` - [purpose]

### Environment Notes
[Any special setup or configuration]

## Next Steps (Priority Order)
1. [Immediate next action]
2. [Following action]
3. [Future action]

## Task List

A checkbox-tracked task list. The receiving session maintains these marks as it
works. Each line is one task; do not collapse multiple tasks into one line.

**Mark legend:**
- `[ ]` — task pending (not yet started)
- `[~]` — task in progress (actively being worked)
- `[x]` — task done (verified complete)
- `[!]` — task blocked (cannot proceed; note the blocker inline)

```markdown
- [ ] {task pending}
- [ ] {task pending}
- [ ] {task pending}
```

**Maintenance protocol (receiving session):**
1. **Verify in-progress marks.** Before doing anything else, re-check every
   task marked `[~]`. If the work is not actually underway (no evidence in the
   working tree, no running process, no recent edit), demote it back to `[ ]`.
   A stale `[~]` is worse than an unstarted `[ ]` because it hides available
   work from the next agent.
2. **Start the next available task.** Pick the first `[ ]` task in priority
   order. Mark it `[~]` immediately before starting work on it.
3. **Prefer subagents for parallel work.** When two or more `[ ]` tasks are
   independent (no shared file writes, no ordering dependency), launch them as
   parallel `run_subagent` calls rather than working them sequentially — this
   is the expected mode of operation, not an optional optimization. Mark each
   `[~]` before launching so concurrent agents see them as claimed. Do not
   parallelize tasks that touch the same files or depend on each other's
   output — run those sequentially.
4. **Mark done only when verified.** Flip `[~]` → `[x]` only after the task's
   Definition of Done checks pass (see below). Never mark `[x]` on intent
   alone.
5. **Record blockers inline.** When a task cannot proceed, mark it `[!]` and
   append the blocker in parentheses on the same line, e.g.
   `- [!] {task blocked (waiting on upstream API access)}`. Move on to the
   next `[ ]` task — do not stall the whole list on one blocker.
6. **Update the list as work reveals new tasks.** Append newly discovered
   tasks as `[ ]` lines in priority order. Do not silently delete tasks; if a
   task is no longer relevant, mark it `[x]` with a note
   (`- [x] {task} (obsolete: reason)`).

## Definition of Done

Before declaring the handoff's work complete, verify every item below.
Items marked **[script]** are deterministically verified by a script — if
the script exits non-zero, the item is NOT done. Items marked **[manual]**
require the agent to check something the scripts cannot verify. Each item
is a checkbox — do not skip any.

- [ ] **[manual]** Every Task List item is `[x]` or marked `[x]` with an
  obsolete note — no `[ ]` or `[~]` items remain
- [ ] **[script]** `git status --porcelain` shows no uncommitted changes
  (all work is committed)
- [ ] **[manual]** The handoff document's Git State commit SHA matches
  `git rev-parse HEAD` (the document is up to date)
- [ ] **[manual]** Each completed task's deliverable matches what was
  described in the handoff (not just marked done — the actual output is
  correct)
- [ ] **[script]** Project-specific validation passes (e.g. `just test`,
  `npm test`, `cargo test` — whichever applies)

### Not Done (common false-completion signals)

If any of these are true, the work is NOT complete:

- All Task List items marked `[x]` but `git status` shows uncommitted
  changes → work was done but not committed
- All items `[x]` but the handoff's Git State SHA doesn't match `HEAD` →
  the handoff document is stale (was not updated after the last commit)
- Items marked `[x]` without verification → the agent marked done on
  intent, not on evidence (re-verify each `[x]` item)
- `just test` passes but the deliverable doesn't match the handoff's
  described outcome → the wrong thing was built

## Open Questions/Blockers
- [Question 1] - [Impact if unresolved]
- [Question 2] - [Impact if unresolved]

## Do Not
- [Things to avoid or approaches rejected]

## Suggested Skills
- [skill-name] - [why this skill should be invoked]
- [skill-name] - [why this skill should be invoked]

## Additional Context
[Any other information crucial for continuation]
```

## Extended Example: Complex Project Handoff

Based on the infrahub example, a more detailed handoff for complex projects:

```markdown
# [Descriptive Title]

**Date**: YYYY-MM-DD
**Session**: [Brief description]
**Status**: [Current status]

## Current State

### ✅ Completed
- **[Completed item]**:
  - [Detail 1]
  - [Detail 2]

### ❌ Blocking Issues
1. **[Issue 1]**: [Description]
2. **[Issue 2]**: [Description]

## Git State

**Commit at handoff**: `<full 40-char SHA>` (captured via `git rev-parse HEAD`
after the pre-handoff commit checkpoint)

This is the exact repo state at handoff time. The receiving session can
reconstruct what was done by inspecting this commit and its history:
- `git show <SHA>` — what the handoff commit changed
- `git log <SHA>..HEAD` — work done since the handoff (during restoration)
- `git diff <SHA>~1 <SHA>` — the last change before handoff

If the target project is not a git repository, replace this section with:
"Not a git repository — no commit hash available."

## Required Reading

Before any other action, read `{REPO_ROOT}/<agent-file>` — it is the root of
this project's progressively-disclosed informational files (JIT index, binding
contracts, conventions). Follow its Usage Protocol and re-read the chain for
any path you touch.

> **Detection**: The capturing session checks in priority order: `AGENTS.md`,
> `AGENT.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, `GEMINI.md`,
> `.windsurf/rules/*.md`, `.cursor/rules/*.mdc`, `CONVENTIONS.md`. If multiple
> exist, the largest by byte size wins (pointer/symlink stubs are small).
> Replace `<agent-file>` with the detected path. If none exist, replace this
> section with: "No agent-instructions file found at the project root. No
> progressive-disclosure root to read — proceed without project-level agent
> conventions."

## Target Architecture

[Architecture diagram or description]

## Required Tasks

### 1. [Task Name]
**Problem**: [Description]
**Investigation Needed**:
- [Investigation item 1]
- [Investigation item 2]
**Files to Check**:
- [File path 1]
- [File path 2]

### 2. [Task Name]
**Problem**: [Description]
**Solutions to Try**:
- [Solution 1]
- [Solution 2]

## Task List

A checkbox-tracked task list. The receiving session maintains these marks as it
works. Each line is one task; do not collapse multiple tasks into one line.

**Mark legend:**
- `[ ]` — task pending (not yet started)
- `[~]` — task in progress (actively being worked)
- `[x]` — task done (verified complete)
- `[!]` — task blocked (cannot proceed; note the blocker inline)

```markdown
- [ ] {task pending}
- [ ] {task pending}
- [ ] {task pending}
```

**Maintenance protocol (receiving session):**
1. **Verify in-progress marks.** Re-check every `[~]` task. If work is not
   actually underway, demote it back to `[ ]`. A stale `[~]` hides available
   work from the next agent.
2. **Start the next available task.** Pick the first `[ ]` task in priority
   order. Mark it `[~]` before starting.
3. **Prefer subagents for parallel work.** Launch independent `[ ]` tasks as
   parallel `run_subagent` calls rather than working them sequentially — this
   is the expected mode of operation, not an optional optimization. Mark each
   `[~]` before launching. Do not parallelize tasks that share files or
   depend on each other's output.
4. **Mark done only when verified.** Flip `[~]` → `[x]` only after the
   Definition of Done checks pass (see below).
5. **Record blockers inline.** Mark blocked tasks `[!]` with the blocker in
   parentheses. Move on to the next `[ ]` task.
6. **Update the list as work reveals new tasks.** Append new tasks as `[ ]` in
   priority order. Mark obsolete tasks `[x]` with a note rather than deleting.

## Definition of Done

Before declaring the handoff's work complete, verify every item below.
Items marked **[script]** are deterministically verified by a script — if
the script exits non-zero, the item is NOT done. Items marked **[manual]**
require the agent to check something the scripts cannot verify. Each item
is a checkbox — do not skip any.

- [ ] **[manual]** Every Task List item is `[x]` or marked `[x]` with an
  obsolete note — no `[ ]` or `[~]` items remain
- [ ] **[script]** `git status --porcelain` shows no uncommitted changes
- [ ] **[manual]** The handoff document's Git State commit SHA matches
  `git rev-parse HEAD`
- [ ] **[manual]** Each completed task's deliverable matches what was
  described in the handoff
- [ ] **[script]** Project-specific validation passes (e.g. `just test`,
  `npm test`, `cargo test` — whichever applies)

### Not Done (common false-completion signals)

If any of these are true, the work is NOT complete:

- All Task List items marked `[x]` but `git status` shows uncommitted
  changes → work was done but not committed
- All items `[x]` but the handoff's Git State SHA doesn't match `HEAD` →
  the handoff document is stale
- Items marked `[x]` without verification → re-verify each `[x]` item
- `just test` passes but the deliverable doesn't match the handoff's
  described outcome → the wrong thing was built

## Files Modified This Session

1. [File path 1]
2. [File path 2]

## Additional Context

- **Project**: [Project name]
- **ADR Compliance**: [Reference to relevant ADRs]
- **Git Workflow**: [Commit strategy]
```

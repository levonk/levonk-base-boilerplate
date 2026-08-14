# Report Templates

Subagents must report back using one of two structured templates, depending
on the outcome. Both templates are mandatory — a vague "done" or "it didn't
work" is not acceptable.

## Block Report (task could not be completed)

Use when, after trying alternatives, the subagent cannot complete the
objective. The orchestrator uses this to decide the next action (re-dispatch,
fix environment, escalate, mark blocked).

```markdown
## Block Report

**Objective**: <the specific step or acceptance criterion being attempted>

**What I tried**:
1. <command or approach #1> → <result>
2. <command or approach #2> → <result>
3. <command or approach #3> → <result>

**Root cause (hypothesis)**: <best diagnosis, labeled as a hypothesis>

**Recommended next step**: <concrete action for the orchestrator or user>
  - Option A: <e.g., "install ripgrep via `devbox global add ripgrep`">
  - Option B: <e.g., "user needs to provide the vault password">
  - Option C: <e.g., "re-dispatch with story-3 marked as a dependency">
```

## Workaround Report (task succeeded after working around an obstacle)

Use when the task completed successfully BUT the subagent hit an obstacle
and worked around it. This is not optional — even on success, the
orchestrator cannot capture learnings it doesn't know about. The next
subagent (working on the next story) benefits from the updated project
memory; silent workarounds force it to re-iterate.

```markdown
## Workaround Report

**Obstacle**: <what command failed or what was missing>

**Actual error**: <the exact error message or observed behavior, quoted>

**Workaround that worked**: <the exact command or approach that succeeded>

**Why the workaround was needed**: <the subagent's diagnosis>
  - e.g., "tool not on PATH but available at ~/.local/bin/"
  - e.g., "project requires pnpm dlx not npx per AGENTS.md universal contract"
  - e.g., "test runner needs --frozen-lockfile in CI"
```

The orchestrator reviews workaround reports and decides whether to spawn a
memory-capture subagent (see [capturing-learnings.md](capturing-learnings.md)).
Not every workaround warrants a doc update — the orchestrator applies the
trigger criteria to keep the developer docs lean.

Both reports must be specific enough that the orchestrator can act on them
without re-investigating. "It didn't work" is not a block report; "I worked
around it" is not a workaround report.

## See Also

- [principle.md](principle.md) — the persist-before-reporting discipline
  that governs when to use these templates
- [capturing-learnings.md](capturing-learnings.md) — what the orchestrator
  does with workaround reports
- [worked-examples.md](worked-examples.md) — concrete examples of both
  report types

# Capturing Learnings to Project Memory

When the orchestrator decides a workaround is worth persisting (per the
trigger criteria in SKILL.md Phase 4 step 4.5), it spawns a memory-capture
subagent. This document covers the contract for that subagent.

## What the Memory Subagent Updates

The memory subagent updates the project's **developer docs** — the
progressively-disclosed documentation referenced from `AGENTS.md`. This is
NOT `AGENTS.md` itself (which is always-loaded context and must stay lean).
Typical locations:

- `.agents/knowledge/developer.md` (skills-src convention)
- `docs/developer-guide.md` (alternative location)
- Whatever path `AGENTS.md`'s "Developer Guide" or "JIT Index" section
  references

The subagent must read `AGENTS.md` first to find the developer-doc
reference. If no developer doc exists, the subagent creates one following
the progressive-disclosure pattern (JIT Index → sections → Known Gotchas)
and adds a reference to it from `AGENTS.md`.

## Where in the Developer Doc

Add the learning to the "Known Gotchas" section (or equivalent — "Troubleshooting", "Common Issues", etc.). If the section doesn't exist, create it.

Each entry should be concise — one paragraph per gotcha:

```markdown
### <gotcha-name>

**Symptom**: <what the agent observes — the error message or behavior>

**Cause**: <why it happens — the underlying reason>

**Fix**: <the sanctioned command or approach>

**Learned from**: <story-name or commit ref where this was encountered>
```

Do not duplicate existing entries. Search the developer doc for similar
gotchas first; if one exists, extend it with the new detail instead of
adding a new entry.

## What the Memory Subagent Returns

- The path to the updated developer doc.
- A one-line summary of the addition (e.g., "Added 'ripgrep not on PATH in
  devbox shell' to Known Gotchas").

The orchestrator then commits the doc update as its own commit (separate
from the story's code commit) so the learning is traceable in git history.

## See Also

- [report-templates.md](report-templates.md) — the workaround report that
  triggers this flow
- [worked-examples.md](worked-examples.md) — Example 4 shows a full
  workaround-to-memory-capture flow

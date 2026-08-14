

# Anti-Patterns Templates

Anti-patterns are things explicitly NOT to do — practices that were tried and
found harmful, inferior, or counterproductive. These are **negative findings**:
the agent must avoid these approaches. Each anti-pattern is date-stamped and
individually citable.

## Directory Structure

```
internal-docs/anti-patterns/
├── INDEX.md                          # Progressive disclosure entry point
├── YYYY/MM/                           # Date-stamped detailed files
│   └── anti-patterns-YYYYMMDDHHmm-{slug}.md
└── {package}/                         # Package-specific (monorepo)
    ├── INDEX.md                       # Package-specific index
    └── YYYY/MM/
        └── anti-patterns-YYYYMMDDHHmm-{slug}.md
```

## INDEX.md Template

The index is the progressive disclosure layer. **Every entry is marked with
🛑** to make it visually unmistakable that these are things NOT to do. Agents
read this first to scan known anti-patterns without reading all detailed
files. Each entry has a one-line summary; the agent drills into the detailed
file only if the current task touches that area.

```markdown
# Anti-Patterns Index

> 🛑 These are things explicitly NOT to do. Every entry below is a practice
> that was found to be harmful or inferior. Read the summary; drill into the
> full file only if your current task touches that area. Do NOT implement
> any of these approaches.

| Anti-Pattern | Area | Added | Details |
|---|---|---|---|
| 🛑 {one-line summary of what NOT to do} | {root or package} | {date} | [details](YYYY/MM/anti-patterns-YYYYMMDDHHmm-{slug}.md) |
| 🛑 {one-line summary of what NOT to do} | {package} | {date} | [details](YYYY/MM/anti-patterns-YYYYMMDDHHmm-{slug}.md) |

## Package-Specific Anti-Patterns
- [{package}/]({package}/INDEX.md) — {one-line description of package anti-patterns}
```

**The 🛑 emoji prefixes every entry summary.** It is the visual marker that
distinguishes anti-patterns from improvements or recommendations — a stop
sign means "do not proceed," which is exactly what an anti-pattern is. The
preamble explicitly says "Do NOT implement any of these approaches."

## Detailed File Template

Each anti-pattern gets its own date-stamped file with full rationale. The
title and preamble make it unmistakable that this is a negative finding.

```markdown
# 🛑 Anti-Pattern: {title}

> 🛑 DO NOT DO THIS. This is an anti-pattern — a practice that was found to
> be harmful or inferior. This file documents what NOT to do and why. Do not
> implement the approach described below.

**Area:** {root or package path}
**Discovered:** {date}
**Status:** {active/superseded/resolved}
**Source:** {git history / incident / research / code review / user report}

## What Not To Do
{clear description of the anti-pattern — what the harmful practice is. Frame
it as "Do not do X" not "Consider doing X."}

## Why It's Wrong
{explanation of why this practice is harmful or inferior. Include concrete
evidence: incidents, performance data, maintenance burden, bug count, etc.}

## What To Do Instead
{the correct approach — what the agent should do instead of the anti-pattern.
Be specific with examples.}

## Origin
{how this anti-pattern was discovered — git history (revert commits, "switch
from X to Y" commits), incident reports, code review findings, external
research, etc. Include specific commits, issues, or sources.}

## Related
- {links to related anti-patterns, improvements, ADRs, or OOS files}
```

**Status values:** `active` (still relevant — do not do this),
`superseded` (replaced by a newer finding — link to replacement),
`resolved` (the underlying issue was fixed — kept for historical context).

## Naming Convention

- Files: `anti-patterns-YYYYMMDDHHmm-{slug}.md` (date-embedded, chronologically
  sortable, same convention as OOS and improvements files)
- Directory: `internal-docs/anti-patterns/YYYY/MM/` structure
- Slug: lowercase, hyphenated, describes the anti-pattern (e.g.,
  `using-npm-not-pnpm`, `direct-nx-commands`, `skipping-tests`)

## Maintenance

When adding a new anti-pattern:
1. Create the detailed file in `YYYY/MM/`
2. Add an entry to `INDEX.md` (or the relevant package `INDEX.md`) with 🛑 prefixing the summary
3. Verify the preamble in INDEX.md still says "Do NOT implement any of these"

When an anti-pattern is resolved (the underlying issue was fixed):
1. Update status to `resolved` in the detailed file
2. Keep the file for historical context — do not delete
3. Update the INDEX.md entry if needed

## Integration with AGENTS.md

The root AGENTS.md references the anti-patterns index with **explicit negative
framing** so no reader can mistake these for positive recommendations:

```markdown
## Anti-Patterns
For things explicitly NOT to do (practices found harmful or inferior), see
[`internal-docs/anti-patterns/INDEX.md`](internal-docs/anti-patterns/INDEX.md).
These are negative findings — do NOT implement any approach listed there.
```

The developer guide includes a JIT Index entry pointing to the anti-patterns
directory with a note to check before implementing changes (to avoid
re-introducing known-bad approaches).

## Critical: Negative Marking

Anti-patterns must be clearly marked as negative in **three places**:

1. **In the AGENTS.md reference**: The link text and surrounding sentence must
   say "things NOT to do" and "do NOT implement." Never link with neutral
   language like "see anti-patterns" — always frame it as negative.
2. **In the INDEX.md preamble**: The header must say "Do NOT implement any of
   these approaches" and every entry summary must be prefixed with 🛑.
3. **In the detailed file**: The title must start with `🛑 Anti-Pattern:` and
   the preamble must say `DO NOT DO THIS`.

This triple marking prevents any reader (human or AI) from mistaking an
anti-pattern for a recommendation.

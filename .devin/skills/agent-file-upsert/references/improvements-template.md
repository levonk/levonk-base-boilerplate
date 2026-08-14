

# Improvements Templates

Potential improvements discovered during research and delta analysis. These
are **suggestions to consider**, not decisions yet. Each improvement is
date-stamped and individually citable.

## Directory Structure

```
internal-docs/improvements/
├── INDEX.md                          # Progressive disclosure entry point
├── YYYY/MM/                           # Date-stamped detailed files
│   └── improvements-YYYYMMDDHHmm-{slug}.md
└── {package}/                         # Package-specific (monorepo)
    ├── INDEX.md                       # Package-specific index
    └── YYYY/MM/
        └── improvements-YYYYMMDDHHmm-{slug}.md
```

## INDEX.md Template

The index is the progressive disclosure layer. Agents read this first to see
what improvements have already been proposed without scanning all detailed
files. Each entry has a one-line summary; the agent drills into the detailed
file only if the current task touches that area.

```markdown
# Improvements Index

> Potential improvements to architecture, standards, and processes. Each
> entry is a suggestion to consider — not a decision yet. Read the summary;
> drill into the full file only if your current task touches that area.

| # | Improvement | Area | Added | Status | Details |
|---|-------------|------|-------|--------|---------|
| 1 | {one-line summary} | {root or package} | {date} | proposed | [details](YYYY/MM/improvements-YYYYMMDDHHmm-{slug}.md) |
| 2 | {one-line summary} | {package} | {date} | proposed | [details](YYYY/MM/improvements-YYYYMMDDHHmm-{slug}.md) |

## Package-Specific Improvements
- [{package}/]({package}/INDEX.md) — {one-line description of package improvements}
```

**Status values:** `proposed` (not yet evaluated), `under review` (being
considered), `accepted` (will be implemented), `rejected` (evaluated and
declined — see file for rationale), `implemented` (done — see file for what
changed), `superseded` (replaced by a newer improvement — link to replacement).

## Detailed File Template

Each improvement gets its own date-stamped file with full rationale:

```markdown
# Improvement: {title}

> 💡 Potential improvement — a suggestion to consider, not a decision yet.

**Area:** {root or package path}
**Discovered:** {date}
**Status:** proposed
**Source:** {research phase / delta analysis / user request / external research}

## Summary
{one-paragraph summary of the proposed improvement}

## Current State
{how things work now, with specific file references}

## Proposed Change
{what the improvement would look like, with enough detail to evaluate}

## Rationale
{why this improvement is worth considering — benefits, trade-offs, risks}

## Origin
{how this was discovered — git delta analysis, research phase, user request,
external research, etc. Include specific commits, issues, or research sources
that led to this finding.}

## Related
- {links to related improvements, anti-patterns, ADRs, or OOS files}
```

## Naming Convention

- Files: `improvements-YYYYMMDDHHmm-{slug}.md` (date-embedded, chronologically
  sortable, same convention as OOS files)
- Directory: `internal-docs/improvements/YYYY/MM/` structure
- Slug: lowercase, hyphenated, descriptive (e.g., `migrate-to-turso`,
  `add-websocket-support`)

## Maintenance

When adding a new improvement:
1. Create the detailed file in `YYYY/MM/`
2. Add an entry to `INDEX.md` (or the relevant package `INDEX.md`)
3. Update the `date.knowledge-basis` in INDEX.md frontmatter if present

When an improvement status changes (proposed → accepted/rejected/implemented):
1. Update the status field in the detailed file
2. Update the status column in `INDEX.md`
3. If rejected, add rationale to the detailed file (so the same improvement
   isn't proposed again without new context)
4. If implemented, link to the commits/PRs that implemented it

## Integration with AGENTS.md

The root AGENTS.md references the improvements index in its JIT Index or a
dedicated section:

```markdown
## Improvements
For potential improvements to architecture, standards, and processes, see
[`internal-docs/improvements/INDEX.md`](internal-docs/improvements/INDEX.md).
```

The developer guide includes a JIT Index entry pointing to the improvements
directory with a note to check before proposing changes (to avoid
re-proposing already-evaluated improvements).

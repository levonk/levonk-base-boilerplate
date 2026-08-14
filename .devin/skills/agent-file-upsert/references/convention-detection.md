

# Convention Detection

Before generating or updating agent documentation, detect the project's
existing convention. This determines which files to create, update, and how
they relate to each other.

## Detection Steps

### Step 1: Check for existing agent files

Look for these files at the repository root and in major subdirectories:

```bash
# Find all agent-file variants at root
ls -la AGENTS.md CLAUDE.md AGENT.md 2>/dev/null

# Find all agent files recursively (for sub-folder detection)
find . -name "AGENTS.md" -o -name "CLAUDE.md" -o -name "AGENT.md" | sort
```

### Step 2: Classify the relationship

For each pair of files that exist at the same level, determine how they relate:

| Test | Command | Relationship |
|------|---------|-------------|
| Symlink | `ls -la CLAUDE.md` shows `-> AGENTS.md` | **symlink** |
| Referral | `cat CLAUDE.md` contains `@AGENTS.md` or `Refer to AGENTS.md` | **referral** |
| Independent | Both files have distinct content, no link | **independent** |
| One only | Only AGENTS.md or only CLAUDE.md exists | **single** |

### Step 3: Determine the convention

Based on what exists and how they relate:

| State | Convention | Action |
|-------|-----------|--------|
| Only `AGENTS.md` | AGENTS.md primary | Create/update AGENTS.md as primary |
| Only `CLAUDE.md` | CLAUDE.md only | Create AGENTS.md as primary, convert CLAUDE.md to referral |
| Only `AGENT.md` | AGENT.md (singular) | Create AGENTS.md as primary, convert AGENT.md to referral |
| Both, CLAUDE.md is symlink to AGENTS.md | symlinked | Update AGENTS.md; symlink is automatic |
| Both, CLAUDE.md is referral to AGENTS.md | referral | Update AGENTS.md; verify referral still valid |
| Both, independent content | independent | **Ask user**: consolidate to AGENTS.md primary + CLAUDE.md referral, or keep both independent? |
| Neither exists | greenfield | Create AGENTS.md as primary (default) |

## Primary File Policy

**AGENTS.md is always the primary file.** The skill creates and maintains
`AGENTS.md` as the canonical source of agent documentation. Other agent-file
variants (`CLAUDE.md`, `AGENT.md`) are maintained as:

1. **Symlinks** (preferred on Unix): `ln -s AGENTS.md CLAUDE.md`
   - Zero maintenance — changes to AGENTS.md automatically reflected
   - Works on macOS/Linux; on Windows, use a referral instead
2. **Referrals**: CLAUDE.md contains a single line pointing to AGENTS.md
   - `@AGENTS.md` (Claude Code native import syntax)
   - `Refer to [AGENTS.md](AGENTS.md) for agent documentation.`
   - Portable across platforms; requires no symlink support

### When the project has independent CLAUDE.md and AGENTS.md

If both files exist with independent content, **ask the user** before
consolidating. They may have a reason for keeping them separate (e.g.,
CLAUDE.md has Claude-specific instructions that don't belong in AGENTS.md).

Options to present:
1. **Consolidate**: Merge unique CLAUDE.md content into AGENTS.md, replace
   CLAUDE.md with a referral. Single source of truth.
2. **Keep both**: Maintain both independently. The skill updates both, but
   this risks divergence. Only recommended if CLAUDE.md has genuinely
   Claude-specific content.

### Sub-folder conventions

Sub-folder agent files follow the same convention as the root. If the root
uses `AGENTS.md` primary with `CLAUDE.md` as symlink, sub-folders do the same.
Detect the root convention first, then apply it consistently throughout the
hierarchy.

### CLAUDE.md referral template

When creating or converting CLAUDE.md to a referral:

```markdown
@AGENTS.md
```

Or for a more explicit referral:

```markdown
Refer to [AGENTS.md](AGENTS.md) for agent documentation.
```

### AGENT.md (singular) handling

Some projects use `AGENT.md` (singular) instead of `AGENTS.md` (plural). When
detected, create `AGENTS.md` as the primary file and convert `AGENT.md` to a
referral. The plural form is the standard; the singular form is maintained
for backward compatibility only.

## Consistency Rules

- Never create independent CLAUDE.md content when AGENTS.md exists — always
  use referral or symlink
- When updating AGENTS.md, verify that CLAUDE.md and AGENT.md referrals still
  point to it (the consistency checker handles this)
- When moving AGENTS.md (rare), update all symlinks and referrals
- On Windows, prefer referrals over symlinks (symlink support is unreliable)

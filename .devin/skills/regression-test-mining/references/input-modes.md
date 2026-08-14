# Input Modes

The skill accepts three input modes for the source of bug-fix commits.

## Mode 1: Full History (default)

```bash
bash scripts/mine-bug-fixes.sh [--since <date>] [--max-count <N>]
```

Mines `git log` for all bug-fix commits in range. This is the default and the
most common mode.

**When to use:** the user wants a comprehensive audit of untested fixes.

**Bounding the scan:**
- `--since="90 days ago"` — focus on recent fixes (recommended for large repos)
- `--max-count=1000` — cap the scan (default; prevents unbounded runs)
- `--max-count=0` — unbounded (use only on small repos or with `--since`)

**Output:** all commits matching conventional `fix:`, `Fixes #N`, `Closes #N`,
`Resolves #N`, or `Revert "..."` patterns, deduped by SHA, sorted by date
descending.

## Mode 2: Single Commit (--bisect)

```bash
bash scripts/mine-bug-fixes.sh --bisect <sha>
```

Skip mining; process a single known bug-introducing commit. Use this when
the user has already run `git bisect` and identified the commit that
introduced the bug.

**When to use:** the user says "I ran git bisect and found that commit
`abc1234` introduced the bug" or provides a single SHA.

**Workflow:**
1. The script emits the single commit
2. Classify it (it is always a `GAP` — the user is asking for a test for it)
3. Determine the *fix* commit (the commit that touched the same lines after
   the bug-introducing commit — use `git log <bisect-sha>..HEAD -- <file>`)
4. Dispatch `unit-test-writing` with the fix commit SHA for the SHA reference

**Note:** the SHA reference in the generated test points to the *fix* commit
(the one that corrected the bug), not the *bug-introducing* commit (the one
from `git bisect`). The fix commit is the permanent record of the correction.

## Mode 3: Commit List (--from-file)

```bash
bash scripts/mine-bug-fixes.sh --from-file <path>
```

Skip mining; read commit SHAs from a file (one per line, `#` comments
allowed). Use this when the user has a pre-filtered list from another source.

**When to use:**
- A CI failure log listing the commits in a failing pipeline
- A security audit identifying commits that introduced vulnerabilities
- A `git log --author=<user>` query for a specific contributor's fixes
- A code review checklist with specific commits to verify

**File format:**
```
# Comments allowed
abc1234def567890123456789012345678901234
def5678901234567890123456789012345678abc
# Another comment
7890123456789012345678901234567890abcdef
```

**Workflow:**
1. The script resolves each SHA to its subject, date, and body
2. Classify each (apply the normal
   [Commit Classification](commit-classification.md) decision tree)
3. Dispatch `unit-test-writing` for each `GAP`

## Choosing a Mode

| Situation | Mode |
|-----------|------|
| "Audit all untested fixes" | Full history |
| "I ran git bisect, here's the SHA" | Single commit |
| "Here's a list of SHAs from CI" | Commit list |
| "Find fixes from the last quarter" | Full history with `--since` |
| "This one bug keeps recurring" | Single commit (the reintroduction) |
| "Security audit found these SHAs" | Commit list |

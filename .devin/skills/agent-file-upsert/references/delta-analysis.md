

# Delta Analysis

When updating an existing AGENTS.md (not creating from scratch), analyze what
changed in the repository since the AGENTS.md was last updated. This surfaces
new patterns, removed patterns, and practices that were reverted or abandoned
— raw material for improvements and anti-patterns.

## Two-Stage Process

### Stage 1: Script — Generate Structured Report

Run the delta analysis script to produce a deterministic, structured report
of repository changes since the AGENTS.md was last updated:

```bash
uv run --script scripts/analyze_git_delta.py {REPO_ROOT} --agents-file AGENTS.md --verbose
```

The script determines the "last updated" date from:
1. The `date.knowledge-basis` field in the AGENTS.md frontmatter (if present)
2. The last git commit that modified the AGENTS.md file (fallback)

It then produces a structured report with:

- **Commit summary**: count, date range, top contributors
- **New files**: files added since the cutoff, grouped by directory
- **Deleted files**: files removed since the cutoff
- **New directories**: directories that appeared since the cutoff
- **Changed patterns**: new test files, new config files, new scripts
- **Revert/removal commits**: commits with "revert", "remove", "delete",
  "switch from", "replace", "deprecate" in their messages — these are
  anti-pattern candidates
- **New dependencies**: packages added to package.json, Cargo.toml, etc.
- **Removed dependencies**: packages removed — may indicate anti-patterns

The script output is JSON (machine-readable) with a `--verbose` human-readable
summary. See `scripts/analyze_git_delta.py` for the full output schema.

### Stage 2: Subagent — Interpret the Report

Spawn a subagent to interpret the structured report and extract:

1. **Positive things to add to AGENTS.md**: new patterns, new conventions,
   new directories that should be documented, new dependencies that change
   the tech stack, new test patterns worth noting.

2. **Negative things (anti-pattern candidates)**: practices that were
   reverted, removed, or replaced. The subagent examines the revert/removal
   commits and their context to determine:
   - What was the harmful practice?
   - Why was it removed/reverted? (commit message, surrounding discussion)
   - What replaced it? (if anything)
   - Is this worth recording as an anti-pattern?

3. **Improvement candidates**: new patterns or tools that suggest the
   AGENTS.md should be updated to recommend them, or gaps in the current
   documentation that the changes reveal.

#### Subagent Prompt Template

```
You are analyzing repository changes to extract documentation updates.

Repository: {REPO_ROOT}
Delta report (JSON): {script output}

Your task:
1. Read the delta report carefully.
2. For each category of change, determine whether it represents:
   a. A POSITIVE change that should be documented in AGENTS.md (new pattern,
      new convention, new directory, new dependency, new test approach)
   b. A NEGATIVE finding — a practice that was reverted, removed, or replaced
      (anti-pattern candidate)
   c. An IMPROVEMENT candidate — something that could be improved in the
      architecture, standards, or processes based on what changed
3. For anti-pattern candidates, examine the revert/removal commits to
   understand WHY the practice was abandoned. Use git show <commit> to read
   the full commit message and diff context.
4. Output three lists:
   - POSITIVE: things to add to AGENTS.md (with specific file references)
   - NEGATIVE: anti-pattern candidates (with origin: which commits, why)
   - IMPROVEMENTS: improvement candidates (with rationale from the changes)

Be specific. Reference actual file paths, commit hashes, and patterns. Do not
speculate — if you can't determine why something was removed, say so and flag
it for human review.
```

#### Subagent Delegation

Use the `run_subagent` tool with the `subagent_explore` profile (read-only —
the subagent only reads git history and files, it does not modify anything).
Pass the full delta report JSON and the prompt template above. The subagent
returns three categorized lists that the main agent uses to:

1. Update AGENTS.md with positive findings
2. Create anti-pattern files in `internal-docs/anti-patterns/` for negative
   findings (using the anti-patterns template)
3. Create improvement files in `internal-docs/improvements/` for improvement
   candidates (using the improvements template)

See `{{ include "includes/subagent-delegation.md" . }}` for general
subagent patterns and when to use them.

## When to Run Delta Analysis

- **Always when updating an existing AGENTS.md** (not creating from scratch)
- **Skip if the user explicitly says "skip delta analysis"** or
  "just update the docs I pointed you at"
- **Skip if the AGENTS.md was created today** (no meaningful delta to analyze)
- **Skip if the repository has no git history** (not a git repo, or empty
  history)

## Scope Control

The user may specify the scope of delta analysis:

- **Whole repo** (default): analyze all changes since the cutoff date
- **Specific path**: `--path src/auth/` — only analyze changes under that path
- **Tree up and down**: `--path src/auth/ --include-parents` — analyze the
  specified path plus parent and child AGENTS.md scopes

When the user asks to update AGENTS.md for a specific subtree, scope the
delta analysis to that subtree. The improvements and anti-patterns files go
in the relevant package's `internal-docs/anti-patterns/{package}/` directory.

## Output Integration

The delta analysis output feeds directly into:

1. **AGENTS.md updates** (Phase 2-3): positive findings become new content in
   the root or sub-folder AGENTS.md files
2. **Anti-patterns files** (Phase 4b): negative findings become new files in
   `internal-docs/anti-patterns/`
3. **Improvements files** (Phase 4c): improvement candidates become new files
   in `internal-docs/improvements/`

All three outputs use the templates referenced in their respective reference
files. The main agent is responsible for writing the files — the subagent
only produces the categorized lists.

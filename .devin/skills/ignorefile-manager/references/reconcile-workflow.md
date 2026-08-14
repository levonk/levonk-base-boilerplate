# Reconcile Workflow

The reconcile step scans deployed ignore files for patterns that aren't
in any concern file yet. This catches manual additions that would
otherwise be silently overwritten on the next generation.

## When to Reconcile

- **Before first generation** in a project that already has ignore files
- **After manual edits** to any deployed ignore file
- **After pulling changes** that modified ignore files
- **Periodically** to catch drift (e.g. monthly)

## How It Works

1. **Load all concern patterns** — collect every pattern from all
   `assets/concerns/*.ignorefile` files into a set
2. **Scan deployed output files** — read `.gitignore`, `.codeiumignore`,
   `.cursorignore`, `.dockerignore`, `.npmignore`, `.chezmoiignore`,
   `.code-workspace`, `.vscode/settings.json` from the target directory
3. **Extract patterns** from each deployed file (handling both gitignore
   and JSON glob syntax)
4. **Compare** — any pattern in a deployed file that's not in the concern
   set is an "orphan"
5. **Suggest a concern** for each orphan using heuristic matching
6. **Prompt or auto-assign** — the user confirms or reassigns each orphan
7. **Append to concern files** — orphans are added under a
   `## Reconciled from deployed files` section

## Heuristic Matching

The script uses substring matching to suggest concerns:

| Pattern contains | Suggested concern |
|---|---|
| `.env`, `.aws`, `.ssh`, `*.key`, `*.pem` | secrets |
| `target/`, `dist/`, `build/`, `__pycache__`, `result` | build-artifacts |
| `.DS_Store`, `Thumbs.db`, `._*` | os-files |
| `.idea/`, `*.swp`, `.vscode` | editor-files |
| `node_modules/`, `.venv`, `venv/` | dependencies |
| `.claude`, `.cursor`, `.codegraph`, `.archon` | ai-generated |
| `*.local.`, `.devbox`, `.direnv` | dev-local |
| `.git/`, `.svn`, `.hg/` | vcs-meta |
| `*.log`, `logs/` | logs |
| `*.exe`, `*.dll`, `*.zip`, `*.png` | binaries |

Patterns that don't match any heuristic default to `dev-local`.

## Running Reconcile

```bash
# Scan and report only (no changes)
uv run --script scripts/generate_ignores.py reconcile --target /path/to/project

# Scan and auto-assign all orphans to suggested concerns
uv run --script scripts/generate_ignores.py reconcile --target /path/to/project --auto-assign

# Scan with interactive prompts (accept, reassign, or skip each orphan)
uv run --script scripts/generate_ignores.py reconcile --target /path/to/project
```

## Interactive Mode

Without `--auto-assign`, the script prompts for each orphan:

```
  result -> build-artifacts? [Enter=accept / concern-name / skip]
```

- **Enter** — accept the suggestion
- **Type a concern name** — reassign (e.g. `dev-local`)
- **Type `skip`** — don't add this pattern to any concern

## After Reconcile

Once orphans are added to concern files, run `generate` to update all
outputs with the new patterns:

```bash
uv run --script scripts/generate_ignores.py generate --target /path/to/project
```

The previously-orphan patterns now appear in the generated block of all
relevant outputs, not just the one file they were found in.

## Edge Cases

### Negation patterns

Negation patterns (`!Cargo.lock`, `!.env.example`) found in deployed files
are treated as patterns. They're added to concerns and preserved in
gitignore-syntax outputs. For `.dockerignore` (no-negation mode), they're
stripped with a warning.

### JSON glob patterns

Patterns extracted from VS Code `files.exclude` / `search.exclude` are
reverse-transformed: `**/node_modules` → `node_modules/`. This ensures
they round-trip correctly through the generator.

### Duplicate patterns across files

If the same orphan pattern is found in multiple deployed files (e.g. in
both `.gitignore` and `.codeiumignore`), it's reported once with a list of
files it was found in, and added to one concern.

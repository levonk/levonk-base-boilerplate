# Ignorefile Manager

Generate, reconcile, and audit ignore files from a single set of modular
concern sources. Instead of editing `.gitignore`, `.codeiumignore`,
`.dockerignore`, VS Code settings, and ripgrep config independently (and
watching them diverge), you edit small concern files and generate all
outputs from them.

## Quick Start

```bash
# Generate all ignore files to the current directory
uv run --script scripts/generate_ignores.py generate

# Dry-run first
uv run --script scripts/generate_ignores.py generate --dry-run

# Audit: check which outputs are missing or stale
uv run --script scripts/generate_ignores.py audit

# Reconcile: find patterns in deployed files not in any concern
uv run --script scripts/generate_ignores.py reconcile

# Update all *.code-workspace files under a directory tree
uv run --script scripts/generate_ignores.py workspace --target ~/p/gh

# Update ripgrep config (~/.config/ripgrep/)
uv run --script scripts/generate_ignores.py ripgrep
```

## How It Works

1. **Concern files** (`assets/concerns/*.ignorefile`) — small, single-purpose
   files, each covering one category (secrets, build-artifacts, lockfiles, etc.)
2. **outputs.yaml** (`assets/outputs.yaml`) — composition config mapping each
   output file to which concerns it includes
3. **generate_ignores.py** (`scripts/generate_ignores.py`) — composes, dedupes,
   sorts, and transforms patterns for each output format

## Five Modes

| Mode | What it does |
|------|-------------|
| `generate` | Compose outputs from concerns and write to target directory |
| `reconcile` | Scan deployed files for patterns missing from concerns |
| `audit` | Check which outputs are missing or stale |
| `workspace` | Find and update all `*.code-workspace` files with exclude settings |
| `ripgrep` | Update ripgrep `config` and `ripgrepignore` deterministically |

## Concerns

| Concern | Covers | In .gitignore? |
|---------|--------|----------------|
| `secrets` | Credentials, API keys, certificates | Yes |
| `build-artifacts` | Compiler output, build dirs, ctags | Yes |
| `os-files` | .DS_Store, Thumbs.db, etc. | Yes |
| `editor-files` | .idea/, *.swp, *.code-workspace | Yes |
| `dependencies` | node_modules/, .venv/, etc. | Yes |
| `ai-generated` | .claude, .cursor, .codegraph/ | No (committed by default) |
| `dev-local` | *.local.*, .devbox/, .cflare/, .obsidian/ | Yes |
| `binaries` | *.exe, *.png, *.pdf, etc. | Yes |
| `vcs-meta` | .git/, .hg/, .svn/ | Yes |
| `logs` | *.log, logs/ | Yes |
| `lockfiles` | *.lock, package-lock.json, Cargo.lock | **No** (must be committed) |

The `lockfiles` concern is special: lockfiles must be committed for
reproducible builds, so they are NOT in `.gitignore`. They are only in
VS Code `search.exclude`, `files.watcherExclude`, and ripgrep
`ripgrepignore` to keep search results and watchers clean.

## Outputs

| Output | Syntax | Concerns |
|--------|--------|----------|
| `.gitignore` | gitignore | All except ai-generated |
| `.chezmoiignore` | gitignore | All except ai-generated |
| `.codeiumignore` | gitignore | All except os-files, editor-files |
| `.cursorignore` | gitignore | All except os-files, editor-files |
| `.aiexclude` | gitignore | All except os-files, editor-files |
| `.npmignore` | gitignore | All + packaging extras |
| `.dockerignore` | gitignore-no-neg | All + Docker extras |
| `vscode-files-exclude` | json-glob | Build, deps, vcs, dev-local, logs, ai |
| `vscode-search-exclude` | json-glob | Build, deps, vcs, logs, lockfiles |
| `vscode-watcher-exclude` | json-glob | Build, deps, vcs, dev-local, logs, ai, lockfiles |
| `ripgrep-ignore` | gitignore | Secrets, build, deps, vcs, dev-local, logs, binaries, lockfiles |

## Adding a New Pattern

1. Identify which concern the pattern belongs to (see
   `references/concern-catalog.md`)
2. Add it to the appropriate `assets/concerns/<name>.ignorefile`
3. Re-run `generate_ignores.py generate --target <project>`
4. Review and commit

## Per-Project Patterns

Each generated output file has a marker-based structure:

```
# Project-specific patterns (preserved across regenerations)
<user's manual additions>

# ===== BEGIN GENERATED CONTENT =====
<generated patterns from concerns>
# ===== END GENERATED CONTENT =====
```

Add project-specific patterns above the marker — they survive re-generation.

## References

- `references/concern-catalog.md` — full catalog of concerns
- `references/output-formats.md` — how each output format is generated
- `references/per-project-patterns.md` — marker system details
- `references/reconcile-workflow.md` — reconcile process
- `references/workspace-mode.md` — workspace auto-merge mode
- `references/ripgrep-mode.md` — ripgrep config update mode

## Development

This skill is authored in the `skills-src` monorepo using Go `text/template`
files (`.tmpl`). The templater renders `.tmpl` files into final output.

```bash
# Build the current profile
just build current

# Validate
just validate
```

See the repository's `AGENTS.md` for authoring conventions, the
`src/current/skills/AGENTS.md` for skill-specific patterns, and
`.agents/knowledge/developer.md` for the developer guide.

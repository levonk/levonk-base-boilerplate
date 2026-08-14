# Ripgrep Mode

The `ripgrep` mode deterministically checks and updates the ripgrep
configuration at `$XDG_CONFIG_HOME/ripgrep/` (or `~/.config/ripgrep/`).

## Why This Mode Exists

Ripgrep (`rg`) is used by many tools (VS Code search, fzf, grep wrappers,
AI agents). Its config lives in a plain-text file with one CLI argument
per line, plus a separate ignore file. Without management, the ignore
file drifts from the project's other ignore files — lockfiles show up in
search, binary files get matched, etc.

## Usage

```bash
# Dry-run: show what would change
uv run --script scripts/generate_ignores.py ripgrep --dry-run

# Update config and ripgrepignore
uv run --script scripts/generate_ignores.py ripgrep

# Custom config directory
uv run --script scripts/generate_ignores.py ripgrep --config-dir /custom/ripgrep/dir
```

## What It Ensures

### config file (`~/.config/ripgrep/config`)

A plain-text file with one ripgrep CLI argument per line. The mode ensures
these flags are present:

- `--hidden` — search hidden files (but respect ignore patterns)
- `--smart-case` — case-insensitive when pattern is lowercase, sensitive when mixed
- `--sort=path` — deterministic output ordering
- `--ignore-file=<path>/ripgrepignore` — points to the ignore file

Missing flags are appended. Existing flags are preserved. Duplicate
`--ignore-file=` lines are deduplicated.

### ripgrepignore file (`~/.config/ripgrep/ripgrepignore`)

Generated from the `ripgrep-ignore` output in `outputs.yaml`, which
includes these concerns:

- **secrets** — `.env`, `.aws/`, `.ssh/*`, `*.pem`, etc.
- **build-artifacts** — `target/`, `dist/`, `__pycache__/`, `tags`, etc.
- **dependencies** — `node_modules/`, `.venv/`, etc.
- **vcs-meta** — `.git/`, `.hg/`, `.svn/`, `.jj/`
- **dev-local** — `.devbox/`, `.direnv/`, `.cflare/`, `.obsidian/`, etc.
- **logs** — `*.log`, `logs/`, etc.
- **binaries** — `*.exe`, `*.png`, `*.pdf`, `*.ttf`, etc.
- **lockfiles** — `*.lock`, `package-lock.json`, `Cargo.lock`, etc.

Excludes:
- **os-files** — low impact on search
- **editor-files** — low impact on search
- **ai-generated** — AI tool dirs may contain searchable content

## Marker-Based Preservation

The `ripgrepignore` file uses the same marker system as other gitignore
outputs:

```
# Project-specific patterns (preserved across regenerations)
<user's manual additions>

# ===== BEGIN GENERATED CONTENT =====
<generated patterns from concerns>
# ===== END GENERATED CONTENT =====
```

Add project-specific ignore patterns above the marker — they survive
re-generation.

## Ripgrep Config Format Note

Ripgrep config files are **plain text** with one CLI argument per line —
not TOML, despite sometimes being called `config.toml`. The actual file
is `config` (no extension) in the `$XDG_CONFIG_HOME/ripgrep/` directory.
This mode handles the correct format.

## Idempotency

Re-running `ripgrep` on an up-to-date configuration produces no changes.
The script compares existing generated content with new generated content
and only writes if they differ.

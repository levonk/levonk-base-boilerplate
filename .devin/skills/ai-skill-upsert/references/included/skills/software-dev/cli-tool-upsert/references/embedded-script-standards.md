# Embedded Script Standards

> This file is shared with `ai-upsert` via a relative include
> (`../../software-dev/cli-tool-upsert/references/embedded-script-standards.md`).
> It is the single source of truth for CLI scripts bundled inside skills and
> projects. Changes here propagate to both skills at build time.

## What Is an Embedded Script?

An embedded script is a CLI script bundled inside a skill's `scripts/`
directory or a project's `scripts/` directory. It is:

- **Single-file** — no project structure, no `Cargo.toml`, no `package.json`
- **Invoked by name** — `uv run --script scripts/foo.py` or `./scripts/foo.sh`
- **Agent-facing** — called by AI agents during skill workflows or project
  automation
- **Short-lived** — runs to completion and exits, no daemon, no server

Contrast with **full CLI tools** (scaffolded from boilerplate, multi-file,
distributed as packages). See `references/cli-best-practices.md` — Full CLI
Tool Scaffolding for that path.

## Table of Contents

1. [Language Selection](#language-selection)
2. [PEP 723 and uv (Python)](#pep-723-and-uv-python)
3. [Bash Standards](#bash-standards)
4. [AXI Output Contract](#axi-output-contract)
5. [XDG Paths for Embedded Scripts](#xdg-paths-for-embedded-scripts)
6. [Error Handling](#error-handling)
7. [Exit Codes](#exit-codes)
8. [Script Output Contract](#script-output-contract)

## Language Selection

| Scenario | Language | Rationale |
|----------|----------|-----------|
| <50 lines, no external deps, glue code | Bash | Fastest, no runtime dep, universal |
| Substantive logic, needs a library, >50 lines | Python (uv/PEP 723) | Self-contained via uv, rich stdlib |
| Performance-critical, called frequently | Python (uv/PEP 723) | Good enough for most; Rust if truly CPU-bound |
| Caller specifies another language | Caller's choice | The skill adapts — see `references/language-templates.md` |

**Default**: Python (uv/PEP 723) for substantive scripts, bash for tiny glue.
Bash is not dogma — if in doubt, use Python. Python's stdlib (argparse, json,
pathlib, subprocess) covers most CLI needs without third-party deps.

## PEP 723 and uv (Python)

Every Python embedded script MUST include a [PEP 723](https://peps.python.org/pep-0723/)
inline script metadata header. This lets `uv run --script <file>.py` provision
an ephemeral environment with declared dependencies automatically — no
virtualenv, no `pip install`, no build step.

**Minimal header (stdlib-only):**
```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
```

**Header with dependencies:**
```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests>=2.31.0",
# ]
# ///
```

**Rules:**
- Pin `requires-python` to `>=3.11` unless newer syntax is needed
- Declare all third-party deps in the `dependencies` array — never `pip install`
  at runtime
- Prefer stdlib; omit `dependencies` when no third-party packages are needed
- When `uv` is unavailable, `python script.py` works for stdlib-only scripts
  (PEP 723 block is a comment Python ignores)
- Do NOT inline `pip install` or mutate the environment — `uv run` handles it

See `references/script-execution-standards.md` in `ai-upsert` for the
full devbox/rtk detection patterns that accompany the PEP 723 header.

## Bash Standards

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- **`set -e`** — exit on error
- **`set -u`** — error on undefined variables
- **`set -o pipefail`** — pipe failures propagate
- Use `[[ ]]` for tests (not `[ ]` — safer with empty strings)
- Quote all variable expansions: `"${var}"`
- Use `local` in functions
- No `eval` — ever
- Check dependencies: `command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required" >&2; exit 1; }`

## AXI Output Contract

Embedded scripts follow a subset of AXI principles. See
`references/axi-principles.md` for the full list with tier markings.

### Required for all embedded scripts:

1. **Output discipline** — results to stdout, logs/progress/diagnostics to
   stderr. Agents read stdout; stderr is for humans and debug.
2. **Structured errors** — errors go to stdout in a parseable format with an
   actionable suggestion. Never leak stack traces or raw dependency errors.
   ```
   error: --title is required
   help: Run with --title "..." to specify the title
   ```
3. **Definitive empty states** — when there are no results, say so explicitly.
   ```
   items: 0 items found matching filter "closed"
   ```
4. **No interactive prompts** — every operation completable with flags alone.
   Missing required values fail immediately with a clear error.
5. **Idempotent mutations** — don't error when the desired state already exists.
   Exit 0 for no-ops.
6. **Exit codes** — 0 success (including no-ops), 1 error, 2 usage error.

### Required when output is a list:

7. **Pre-computed aggregates** — include total count, not just the page size.
   ```
   count: 30 of 847 total
   ```
8. **Minimal schemas** — 3-4 fields per item by default, not 10. Offer
   `--fields` to request more.
   ```
   $ fetch-transcripts list --fields id,title,duration,segments
   ```

### Required when output is data-heavy (>500 tokens of structured data):

9. **TOON output format** — use [TOON](https://toonformat.dev/) for
   token-efficient structured output. ~40% savings over JSON. Convert at
   the output boundary, keep internal logic in JSON.
   ```
   transcripts[2]{id,title,duration}:
     "abc123",Intro to Rust,12:30
     "def456",Advanced Clap,45:00
   ```
10. **`--fields` flag** — let agents request additional fields explicitly.
    Validate field names against available fields. Default schema is 3-4
    fields; `--fields` expands it.

### Required when output has large text fields:

11. **Content truncation** — truncate by default (500-1500 chars), show total
    size, suggest `--full` escape hatch. Never omit entirely.

## XDG Paths for Embedded Scripts

Embedded scripts that need to cache or persist data use XDG paths:

| Data type | Path | Env var fallback |
|-----------|------|------------------|
| Transient cache | `${XDG_CACHE_HOME:-$HOME/.cache}/<tool>/` | `~/.cache/<tool>/` |
| Persistent state | `${XDG_DATA_HOME:-$HOME/.local/share}/<tool>/` | `~/.local/share/<tool>/` |
| Config | `${XDG_CONFIG_HOME:-$HOME/.config}/<tool>/` | `~/.config/<tool>/` |

**Python resolution:**
```python
import os
from pathlib import Path

def cache_dir(tool: str) -> Path:
    return Path(os.environ.get("XDG_CACHE_HOME", "~/.cache")).expanduser() / tool

def data_dir(tool: str) -> Path:
    return Path(os.environ.get("XDG_DATA_HOME", "~/.local/share")).expanduser() / tool

def config_dir(tool: str) -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME", "~/.config")).expanduser() / tool
```

**Bash resolution:**
```bash
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/<tool>"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/<tool>"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/<tool>"
mkdir -p "$CACHE_DIR" "$DATA_DIR"
```

**Rules:**
- Cache = can be deleted without data loss (API response caches, temp downloads)
- Data = persistent state the user would not want to lose (history, databases)
- Config = user-edited settings
- Always `mkdir -p` before writing — the dir may not exist on first run
- Never write outside XDG paths — no `/tmp`, no `~/.<tool>rc`, no `/var`

## Error Handling

### Structured error format

```
error: <description>
help: <actionable suggestion>
```

- One-line description of what went wrong
- One-line suggestion of how to fix it
- Reference the script's own flags/commands, not underlying tools
- Never leak dependency names, stack traces, or raw API errors

### Python pattern

```python
import sys

def fail(msg: str, suggestion: str = "", exit_code: int = 1) -> None:
    """Print structured error to stdout and exit."""
    print(f"error: {msg}")
    if suggestion:
        print(f"help: {suggestion}")
    sys.exit(exit_code)

# Usage:
if not args.title:
    fail("--title is required", 'Run with --title "..." to specify the title', exit_code=2)
```

### Bash pattern

```bash
fail() {
    echo "error: $1"
    if [[ -n "${2:-}" ]]; then
        echo "help: $2"
    fi
    exit "${3:-1}"
}

# Usage:
[[ -n "$TITLE" ]] || fail "--title is required" 'Run with --title "..." to specify the title' 2
```

## Exit Codes

| Code | Meaning | When to use |
|------|---------|-------------|
| 0 | Success | Operation completed, including no-ops |
| 1 | Generic error | Runtime failure, unexpected state |
| 2 | Usage error | Missing required args, invalid flags, unknown subcommand |

For scripts that need more granularity:
- 3 = network error
- 4 = validation error
- 5 = file not found
- 6 = permission denied
- 130 = SIGINT (Ctrl-C)

**Always use exit code 2 for usage errors** — this lets agents distinguish "I
ran it wrong" from "it ran but failed".

## Script Output Contract

All embedded scripts must follow this output contract so the calling AI can
function efficiently without reading the script source:

- **Quiet by default**: emit only the minimum output the calling AI needs to
  make its next decision (exit code, a single status line, or compact JSON).
  Suppress intermediate command output, progress indicators, and verbose
  diagnostics unless `--verbose` is passed.
- **`--verbose` mode**: when passed, emit full detail — every command run,
  intermediate results, diagnostic messages. Use for debugging.
- **`--dry-run` mode**: when passed, print what would happen without making
  changes. Output should be human-readable and show specific operations.

```bash
# Quiet (default) — AI gets just what it needs
scripts/check-status.sh
# Output: "ok" or "failed"

# Verbose — user wants to understand what happened
scripts/check-status.sh --verbose
# Output: full curl command, API response, parsed result

# Dry-run — user wants to preview before committing
scripts/deploy.sh --dry-run
# Output: "Would deploy to production"
#         "Would run health check on https://..."
```

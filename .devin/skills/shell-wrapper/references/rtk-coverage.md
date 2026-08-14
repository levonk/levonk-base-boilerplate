# RTK Coverage

RTK (Rust Token Killer) supports 100+ commands across multiple ecosystems.
This is a **reference summary** — the authoritative source is `rtk rewrite`
(or `rtk --help`), which the wrapper script calls to determine coverage. This
file does NOT need to be kept in sync with rtk; it exists for human reference
only.

## Supported Commands

The wrapper script's `RTK_SUPPORTED` list must stay in sync with this table.
When rtk adds new filters, update both this file and the script.

### Files

| Command | What rtk does |
|---------|---------------|
| `ls` | Token-optimized directory tree |
| `read` | Smart file reading (strips noise) |
| `smart` | 2-line heuristic code summary |
| `find` | Compact find results |
| `grep` | Grouped search results |
| `diff` | Condensed diff |

### Git / GitHub CLI

| Command | What rtk does |
|---------|---------------|
| `git` | Compact status, one-line log, condensed diff, `-> "ok"` for mutations |
| `gh` | Compact PR/issue listing, PR details + checks, workflow run status |
| `gt` | Graphite CLI (git stacking) — compact output |

### Test Runners

| Command | What rtk does |
|---------|---------------|
| `jest` | Failures only |
| `vitest` | Failures only |
| `playwright` | E2E results, failures only |
| `pytest` | Python tests (-90%) |
| `rake` | Ruby minitest (-90%) |
| `rspec` | RSpec (JSON, -60%+) |
| `go` | `go test` — NDJSON, -90% (note: rtk handles `go test`, not all `go` subcommands) |
| `cargo` | `cargo test` — -90% |
| `err` | Filter errors only from any command |
| `test` | Generic test wrapper — failures only (-90%) |

### Build & Lint

| Command | What rtk does |
|---------|---------------|
| `lint` | ESLint grouped by rule/file (supports `lint biome`) |
| `tsc` | TypeScript errors grouped by file |
| `next` | `next build` compact |
| `prettier` | Files needing formatting |
| `cargo` | `cargo build` (-80%), `cargo clippy` (-80%) |
| `ruff` | Python linting (JSON, -80%) |
| `golangci-lint` | Go linting (JSON, -85%) |
| `rubocop` | Ruby linting (JSON, -60%+) |

### Package Managers

| Command | What rtk does |
|---------|---------------|
| `pnpm` | Compact dependency tree |
| `pip` | Python packages (auto-detect uv), outdated packages |
| `bundle` | Ruby gems (strip "Using" lines) |
| `prisma` | Schema generation (no ASCII art) |

### AWS

| Command | What rtk does |
|---------|---------------|
| `aws` | Compact output for sts, ec2, lambda, logs, cloudformation, dynamodb, iam, s3 |

### Containers

| Command | What rtk does |
|---------|---------------|
| `docker` | Compact ps/images, deduplicated logs, compose ps |
| `kubectl` | Compact pods/services, deduplicated logs |

### Data & Analytics

| Command | What rtk does |
|---------|---------------|
| `json` | Structure without values |
| `deps` | Dependencies summary |
| `env` | Filtered env vars |
| `log` | Deduplicated logs |
| `curl` | Truncate + save full output |
| `wget` | Download, strip progress bars |
| `summary` | Heuristic summary of any long command |
| `proxy` | Raw passthrough + tracking |

### Token Savings Analytics

| Command | What rtk does |
|---------|---------------|
| `gain` | Summary stats, `--graph`, `--history`, `--daily`, `--all --format json` |
| `discover` | Find missed savings opportunities |
| `session` | Show RTK adoption across recent sessions |

## Passthrough Behavior

For commands NOT supported by rtk, `rtk rewrite` exits 1 (no output) and the
wrapper script passes the command through unchanged. This avoids ~10ms
overhead with no benefit.

To check whether a command is supported:

```bash
rtk rewrite -- <cmd> [subcmd]
# Exit 0 or 3 with rewritten output → supported
# Exit 1 with no output → not supported (passthrough)
```

## Exclusion List

These commands are excluded by `rtk rewrite` itself (exit 1, no rewrite).
The wrapper script does not maintain its own exclusion list — it relies
entirely on `rtk rewrite`.

| Category | Commands | Why |
|----------|----------|-----|
| Interactive editors | `vim`, `vi`, `nvim`, `emacs`, `nano` | rtk filters stdout, which breaks the TUI |
| Process monitors | `top`, `htop`, `btop` | Same — TUI breaks under filtering |
| Terminal multiplexers | `tmux`, `screen` | Same |
| Pagers | `less`, `more` | Same |
| Manual viewer | `man` | Same |
| Fuzzy finders | `fzf` | Same |
| Watchers | `watch` | Same |
| Remote shells | `ssh`, `scp` | rtk would filter the remote session's output |
| Environment wrappers | `devbox` | Recursive wrapping: `devbox run -- rtk devbox ...` |

> **Note**: `make` and `just` are NOT excluded by `rtk rewrite` — rtk
> supports them. An earlier version of this skill wrongly excluded them.

## Adding New Commands

When rtk adds support for a new command, **no change is needed in the wrapper
script** — `rtk rewrite` automatically picks it up. To update this reference
for human readers:

1. Add a row to the appropriate table above
2. Rebuild: `just build current`

## Source

- RTK repo: https://github.com/rtk-ai/rtk
- RTK guide: https://www.rtk-ai.app/guide
- Full command list: `rtk --help` (after installation)
- Authoritative coverage check: `rtk rewrite -- <cmd>` (exit 0/3 = supported)

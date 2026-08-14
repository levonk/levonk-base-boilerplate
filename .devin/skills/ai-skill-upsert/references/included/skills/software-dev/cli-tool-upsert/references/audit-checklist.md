# CLI Audit Checklist

For Mode B (Update an Existing CLI). Audit the existing CLI against this
checklist, classify each gap as Critical / Important / Nice to have, and
propose fixes.

## Table of Contents

1. [Output Discipline](#output-discipline)
2. [Structured Errors](#structured-errors)
3. [Exit Codes](#exit-codes)
4. [Idempotent Mutations](#idempotent-mutations)
5. [No Interactive Prompts](#no-interactive-prompts)
6. [Definitive Empty States](#definitive-empty-states)
7. [Content Truncation](#content-truncation)
8. [Pre-computed Aggregates](#pre-computed-aggregates)
9. [Minimal Default Schemas](#minimal-default-schemas)
10. [Content-First No-Args](#content-first-no-args)
11. [Contextual Disclosure](#contextual-disclosure)
12. [Fail Loud on Unrecognized Input](#fail-loud-on-unrecognized-input)
13. [XDG Paths](#xdg-paths)
14. [Security](#security)
15. [Full CLI Tool Extras](#full-cli-tool-extras)
16. [Agent Simulation Test](#agent-simulation-test)

## Output Discipline

- [ ] Results go to stdout, logs/progress/diagnostics to stderr
- [ ] No progress messages mixed into stdout
- [ ] `--verbose` sends debug info to stderr, not stdout
- [ ] `--quiet` suppresses all non-essential output including progress
- [ ] (Full) `--json` flag produces pure JSON on stdout
- [ ] (Full) `--color=auto|always|never` flag works
- [ ] (Full) `NO_COLOR` env var honored (takes precedence over all)

## Structured Errors

- [ ] Errors go to stdout in parseable format (not stderr)
- [ ] Error format: `error: <description>` + `help: <suggestion>`
- [ ] No raw stack traces or dependency errors leaked
- [ ] No dependency names in error messages
- [ ] Required flags validated before any dependency call
- [ ] Errors are actionable — agent knows what to do next

## Exit Codes

- [ ] 0 = success (including no-ops)
- [ ] 1 = generic error
- [ ] 2 = usage error (missing/invalid args, unknown flags)
- [ ] 130 = SIGINT
- [ ] (Optional) 3 = network, 4 = validation, 5 = file not found, 6 = permission

## Idempotent Mutations

- [ ] Repeating a mutation that's already done returns exit 0
- [ ] No-op acknowledged in output: `item: #42 already closed (no-op)`
- [ ] Non-zero exit reserved for genuine failures

## No Interactive Prompts

- [ ] Every operation completable with flags alone
- [ ] Missing required values fail with clear error, not a prompt
- [ ] No `read` from stdin in default mode (bash)
- [ ] No `input()` in default mode (Python)
- [ ] (Full) `--force` bypasses any confirmation logic
- [ ] Prompts from wrapped tools are suppressed

## Definitive Empty States

- [ ] Empty result sets produce explicit "0 results" output
- [ ] Empty state includes context (filter criteria, scope)
- [ ] Exit code 0 for successful empty queries
- [ ] No ambiguous empty output (agent can tell command succeeded)

## Content Truncation

- [ ] Large text fields truncated by default (500-1500 chars)
- [ ] Truncation metadata included: `... (truncated, N chars total)`
- [ ] `--full` flag disables truncation
- [ ] Escape hatch suggested only when content is actually truncated
- [ ] Large fields never omitted entirely — always a preview

## Pre-computed Aggregates

- [ ] List output includes total count, not just page size
- [ ] Format: `count: 30 of 847 total`
- [ ] Derived status fields included when cheap to compute
- [ ] Follow-up call data pre-computed where possible

## Minimal Default Schemas

- [ ] Default list schema: 3-4 fields, not 10
- [ ] Default limit high enough for common cases
- [ ] Long-form content in detail views, not lists
- [ ] (Full) `--fields` flag for explicit field selection

## Content-First No-Args

- [ ] No-args shows live state, not usage manual (if live state exists)
- [ ] Help moved to `--help` flag
- [ ] No-args output includes `help[]` suggestions
- [ ] Different content based on current directory/context

## Contextual Disclosure

- [ ] 2-4 next-step suggestions after output
- [ ] Suggestions are relevant to current output
- [ ] Suggestions are complete commands (with disambiguating flags)
- [ ] Structured as `help[]` array for machine parsing

## Fail Loud on Unrecognized Input

- [ ] Unknown flags rejected with exit code 2
- [ ] Error lists valid flags for the command
- [ ] `--help` always passes
- [ ] Renamed flags get targeted hint (`--status was renamed; use --state`)
- [ ] Unknown subcommands rejected (not silently ignored)

## XDG Paths

- [ ] Cache in `${XDG_CACHE_HOME:-$HOME/.cache}/<tool>/`
- [ ] Data in `${XDG_DATA_HOME:-$HOME/.local/share}/<tool>/`
- [ ] Config in `${XDG_CONFIG_HOME:-$HOME/.config}/<tool>/`
- [ ] No files in `~/.<tool>rc`, `~/.<tool>/`, or `/tmp` (except truly ephemeral)
- [ ] `mkdir -p` before writing (dir may not exist on first run)
- [ ] (Full) Runtime files in `${XDG_RUNTIME_DIR:-/run/user/$UID}/<tool>/`

## Security

- [ ] No secrets in output, logs, or error messages
- [ ] Secrets masked in `--verbose` mode
- [ ] Secrets read from env vars or keyring, not plaintext config
- [ ] Input validated at trust boundaries
- [ ] No `shell=True` with user input (Python)
- [ ] No `eval` with user input (bash)
- [ ] File permissions correct (0600 for secrets, 0644 for data)

## Full CLI Tool Extras

Only for full CLI tools scaffolded from boilerplate:

- [ ] `--help`/`-h` works at root and major subcommands
- [ ] `--version`/`-v` works
- [ ] `--usage` shows brief usage summary
- [ ] Config file initialization on first run
- [ ] Config precedence: args > env > project > user > system > defaults
- [ ] `--install` generates shell completion + config files
- [ ] `--uninstall` cleans up
- [ ] Shell completion for bash, zsh, fish
- [ ] (Optional) Man page
- [ ] (Optional) Pager integration (`--no-pager` to bypass)
- [ ] (Optional) `--dry-run` flag
- [ ] (Optional) `--daemon`/`--no-daemon` for long-running tasks
- [ ] TOON output mode (`--toon` or default in agent mode)
- [ ] Session hook infrastructure (`--install-agent-hooks`)
- [ ] Mode auto-detection (TTY → human, no-TTY → agent)
- [ ] `--human`/`--interactive` flags for explicit human mode
- [ ] `--fields` flag for schema selection
- [ ] `--full` flag for truncation escape hatch

## Agent Simulation Test

After applying fixes, test the CLI the way an agent would use it:

1. **No TTY**: `tool <command> | cat` — verify no prompts, no color codes
2. **Flags only**: `tool <command> --flag value` — verify no interactive prompts
3. **Parse stdout**: `tool <command> | jq .` (if JSON) or parse text — verify
   output is structured and parseable
4. **Error path**: `tool <command> --bad-flag` — verify structured error on
   stdout, exit code 2
5. **Empty state**: `tool list --nonexistent-filter` — verify "0 results"
   message, exit code 0
6. **No-args**: `tool` — verify content-first (not just help) if live state
   exists
7. **Idempotent**: `tool <mutation> <id>` twice — verify second is a no-op
   with exit 0
8. **Help**: `tool --help` — verify concise, lists all commands and flags

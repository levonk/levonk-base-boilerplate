---
modeline: "vim: set ft=markdown:"
title: "ADR: CLI Tool Standards"
adr-id: "20260607001"
slug: "20260607001-cli-tool-standards"
url: "/internal-docs/adr/adr-20260607001-cli-tool-standards.md"
synopsis: "Defines comprehensive cross-language standards for CLI programs: standard arguments, configuration management with auto-initialization and auto-migration, install/uninstall functionality, input/output discipline with color control (--color=auto|always|never, config setting, NO_COLOR support), logging modes with structured logging and format auto-detection, signal handling including config reload, TUI mode, dry-run, progress indicators, daemon processes (--daemon/--no-daemon flags with auto-spawning and explicit control) with platform fallback, error formatting, shell completion, man pages, pager integration, cross-platform compatibility, security, resource management, collection vs processing separation, health checks for containers, privacy mode with anonymous lists, audit logging with retention, legacy deprecation policy, and agent mode standards (AXI: token-efficient TOON output, minimal schemas, content truncation, pre-computed aggregates, definitive empty states, structured errors, session integrations, content-first no-args, contextual disclosure)."
author: "https://github.com/levonk"
date-created: "2026-06-07"
date-updated: "2026-06-07"
version: "4.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "cli", "boilerplate", "tooling", "standard"]
supersedes: []
superseded-by: []
related-to: ["adr-20250131001-universal-shared-partials-system"]
scope:
  impact-scope: ["all CLI programs in this repo", "boilerplate/apps/cli/*", "all CLI projects generated from these templates"]
  excluded-scope: []
---

# Decision Record: CLI Tool Standards

- belongs in `internal-docs/adr/adr-20260607001-cli-tool-standards.md`

---

## Context

CLI tools are part of the repo's public interface and automation surface. Without codified standards, CLI programs drift across projects and languages, causing inconsistent UX, configuration handling, and operational posture.

The monorepo also maintains multiple production-grade CLI boilerplates (Python, Rust, Go, TypeScript, Bash, PowerShell, C#, Java, Ruby). The existing [ADR 20250131001: Universal Shared Partials System](./adr-20250131001-universal-shared-partials-system.md) provides a template infrastructure but does not define what CLI programs must do.

Additionally, the rise of autonomous AI agents (Claude Code, Codex, OpenCode, etc.) that interact with CLIs via shell execution creates new requirements. Traditional human-centric CLI design (verbose help, interactive prompts, rich formatting) is suboptimal for agent consumption. The [Agent eXperience Interface (AXI)](https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md) specification defines ergonomic standards for agent-facing CLIs, emphasizing token efficiency, structured output, and session integrations.

## Decision

Adopt a unified cross-language standard for CLI program behavior with **agent mode as the default**. CLIs must be optimized for autonomous agent consumption while preserving human-friendly features via explicit mode selection.

All CLI programs **must** provide:

0. Conform to Developer UX standard (direnv, devbox, justfile, nix, nx, containers, unified logging standards)
1. **Standard Arguments**: All CLIs must support `--help`/`-h` (display help), `--version`/`-v` (display version), and `--usage` (display brief usage summary). These should be available at the root command and major subcommands.
2. **Configuration Precedence**: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults. Prefer TOML for human-edited config; YAML acceptable for complex structures; JSON reserved for machine-to-machine.
3. **Config File Initialization**: On first run, if no config file exists in the expected location, create a default config file with all settings commented out, including default values and explanations for each option.
4. **Install Flag**: Provide an `--install` flag that performs all installation tasks: generates shell completion scripts for bash/zsh/fish, initializes default config files, and sets up any required environment. Should include `--uninstall` counterpart for cleanup.
5. **Input & Globbing**: Support recursive `**/*` globbing plus stdin via `-` or piped input; process files or stdin interchangeably.
6. **Output Discipline**: Results to stdout; logs/progress/errors to stderr. Provide `--json` output mode. Color control must support `--color=auto|always|never` flag (default: auto) with smart TTY detection in auto mode. Config file must include `color` setting with same modes. Honor `NO_COLOR` environment variable (takes precedence over all other color settings).
7. **Logging Modes**: Support `--verbose`/`-v`, `--quiet`/`-q`, and `--debug` flags for different logging levels. `--quiet` should suppress all non-essential output including progress indicators.
8. **Signals & Exit Codes**: Graceful SIGINT handling with exit code `130`; standard exit codes `0` success, `1` generic error, `2` usage error, and additional specific codes for different error types (network errors, validation errors, file not found, permission denied, etc.).
9. **TUI Mode Preference**: For complex CLIs with multiple configurable options, provide a TUI (Terminal User Interface) mode that allows interactive configuration and execution. Trigger via `--interactive` or `--tui` flag. The TUI should allow users to view and modify all arguments before execution.
10. **Dry-Run Mode**: Support `--dry-run` flag to preview changes without executing them. Should show exactly what would be done without making any changes.
11. **Confirmation Prompts**: Require confirmation for destructive operations (delete, overwrite, etc.) with a `--force` flag to bypass prompts.
12. **Progress Indicators**: Show progress bars or spinners for long-running operations. Must respect `--quiet` flag (no progress indicators in quiet mode).
13. **Daemon Process Support**: For long-running tasks (>30 seconds), provide daemon mode with job management. The implementation must support ALL of the following behaviors simultaneously:
   - Provide `--daemon` and `--no-daemon` flags as opposites
   - Auto-spawn daemon on first async operation (no flag required)
   - `--daemon` flag pre-launches daemon in background and waits for jobs
   - `--no-daemon` flag forces synchronous in-process operation (disables auto-spawning)
   - Include `--list-jobs` command to show background job status, with an optional job id list to filter results
   - Return the output from `--list-jobs` with job ID immediately when daemon performs the background operation
   - Include `--cancel-job <id>` command to cancel specific background jobs
   - Provide instructions for monitoring job progress
   - If daemon mode is not supported on the current platform, fall back to synchronous processing with a clear error message explaining the limitation if `--no-daemon` is not used. Suggest alternatives if `--daemon` is used. Allow a config variable to override this noisy behavior for non supported platforms.
14. **Error Message Formatting**: Consistent, actionable error messages with suggestions for resolution. Format: `ERROR: <description> - <suggestion>`.
15. **File Reference Formatting**: All file references with line numbers must use VSCode-compatible format: `file:///absolute/path/to/file:line:column` or standard `file:line:column` format that modern terminals auto-linkify.
16. **URL Formatting**: All URLs must be in a format that supports copying to browser or smart terminal linking. Use standard HTTP/HTTPS URLs with proper encoding.
17. **Shell Completion**: Provide shell completion scripts for bash, zsh, and fish. Auto-generated preferred, but must be maintained to match current command structure.
18. **Man Pages**: Provide traditional Unix man pages for documentation, accessible via `man <command>` or `--man` flag.
19. **Pager Integration**: Auto-pager for long output (respect `PAGER` env var, default to `less`). Provide `--no-pager` to bypass.
20. **Subcommand Organization**: Hierarchical command structure with consistent patterns. Group related commands under logical subcommands.
21. **Configuration Validation**: Validate config files on load and report clear, specific error messages with line numbers and suggestions.
22. **Terminal Size Awareness**: Responsive output formatting based on terminal width. Detect terminal size on startup and handle resize events where possible.
23. **Environment Variable Naming**: Consistent `UPPER_CASE` prefix for all environment variables (e.g., `MYTOOL_DEBUG`, `MYTOOL_CONFIG`).
24. **Cross-Platform Path Handling**: Consistent path handling across Windows/Linux/macOS. Use platform-appropriate separators and handle both forward and backward slashes.
25. **Credential/Secret Handling**: Secure handling of sensitive data with no logging of secrets, secure storage options, and clear warnings about insecure config methods.
26. **Resource Limits**: Memory/CPU usage guidelines for long-running operations. Provide `--max-memory` and `--max-cpu` flags where applicable.
27. **Testing**: Language-appropriate tests covering help output, globbing, stdin, config precedence, json vs human output, exit-code behavior, standard arguments, config file initialization, shell completion, error handling, daemon mode, and agent mode (TOON output, minimal schemas, content truncation, pre-computed aggregates, empty states, structured errors, content-first no-args, contextual disclosure) where feasible.
28. **Collection vs Processing Separation**: For CLIs that collect data and perform analysis, separate collection (daemon/background) from processing (offline analysis). Allow data collection in one environment and processing in another. Provide export commands for collected data and analysis commands that operate on exported data without requiring the collection daemon.
29. **Config File Auto-Migration**: When config schema evolves, auto-migrate legacy configs to new format on first run. Create backup of old config (`.bak` suffix), log migration actions, and validate migrated config before use. Support both legacy and new formats for at least one release cycle with deprecation warnings.
30. **Structured Logging with Format Auto-Detection**: Use structured logging (JSON or structured text) with format auto-detection based on TTY. Support language-native env filters (e.g., `RUST_LOG`, `NODE_ENV`, `LOG_LEVEL`). Log level resolution: env vars > CLI flags > config file > defaults.
31. **Signal-Based Config Reload**: Support `SIGHUP` to reload config files without restart. Validate new config before applying, log reload events, and handle validation errors gracefully (keep old config active).
32. **Health Check for Containers**: Provide health check mechanism (signal or HTTP endpoint) for container orchestration (Docker `HEALTHCHECK`, Kubernetes probes). Health check must validate operational state without side effects.
33. **Privacy Mode with Anonymous Lists**: For CLIs that collect sensitive data, support privacy mode with explicit ignore lists (identifiers to never log or process). Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely). Configurable privacy toggles to disable specific data collection.
34. **Audit Logging with Retention**: For CLIs that process significant data, provide optional append-only audit log (SQLite or similar) with configurable retention period. Auto-prune old data on startup. Support export commands for external analysis.
35. **Legacy Deprecation Policy**: When introducing breaking changes or legacy format deprecation, specify a clear end-of-support date (minimum 6 months from announcement). Log deprecation warnings to stderr during the deprecation period. Remove legacy support only after the specified date.

## Agent Mode Standards (AXI)

All CLI programs **must** support agent mode as the default behavior, following the [Agent eXperience Interface (AXI)](https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md) specification. Agent mode optimizes for autonomous agent consumption via shell execution, while human mode preserves user-friendly features.

### Mode Selection

- **Default**: Agent mode (no flags required)
- **Human mode**: Triggered via `--human` flag, `--interactive` flag, TUI mode, or auto-detection when TTY is present and no agent session is detected
- **Config setting**: `mode = "agent" | "human"` in config file
- **Environment variable**: `MYTOOL_MODE=agent|human` (highest precedence after CLI args)

### Agent Mode Requirements

36. **Token-Efficient Output (TOON Format)**: Use [TOON (Token-Oriented Object Notation)](https://toonformat.dev/) as the output format on stdout in agent mode. TOON provides ~40% token savings over equivalent JSON while remaining readable by agents. Convert to TOON at the output boundary — keep internal logic on JSON. Human mode continues using JSON or human-readable formats.

   ```
   tasks[2]{id,title,status,assignee}:
     "1",Fix auth bug,open,alice
     "2",Add pagination,closed,bob
   ```

37. **Minimal Default Schemas**: Every field in stdout costs tokens — multiplied by row count in collections. Default to the smallest schema that lets the agent decide what to do next: typically an identifier, a title, and a status.
   - Default list schemas: 3-4 fields, not 10
   - Default limits: high enough to cover common cases in one call (if most repos have <100 labels, default to 100, not 30)
   - Long-form content (bodies, descriptions) belongs in detail views, not lists
   - Offer a `--fields` flag to let agents request additional fields explicitly

38. **Content Truncation**: Detail views often contain large text fields. Omitting them forces agents to hunt; including them wastes tokens. Truncate by default and tell the agent how to get the full version.
   - Never omit large fields entirely — include a truncated preview
   - Show the total size so the agent knows how much it's missing
   - Suggest the escape hatch (`--full`) only when content is actually truncated
   - Choose a truncation limit that covers most use cases (500-1500 chars)

   ```
   task:
     number: 42
     title: Fix auth bug
     state: open
     body: First 500 chars of the issue body...
       ... (truncated, 8432 chars total)
   help[1]: Run `tasks view 42 --full` to see complete body
   ```

39. **Pre-computed Aggregates**: The most expensive token cost is often not a longer response — it's a follow-up call. If your backend has data that agents commonly need as a next step, compute it and include it.
   - **Aggregate counts**: include the **total count** in list output, not just the page size. Agents need "how many are there?" and will paginate if the answer isn't definitive.
   - **Derived status fields**: when the next step almost always involves checking related state, include a lightweight summary inline. Only include derived fields your backend can provide cheaply — a summary ("3/3 passed"), not the full data.

   ```
   count: 30 of 847 total
   tasks[30]{number,title,state}:
     1,Fix auth bug,open
     ...
   ```

40. **Definitive Empty States**: When the answer is "nothing", say so explicitly. Ambiguous empty output causes agents to re-run with different flags to verify. State the zero with context. Make it clear the command succeeded — the absence of results is the answer.

   ```
   $ tasks list --state closed
   tasks: 0 closed tasks found in this repository
   ```

41. **Structured Errors & Exit Codes**:
   - **Idempotent mutations**: Don't error when the desired state already exists. If the agent closes something already closed, acknowledge and move on with exit code 0. Reserve non-zero exit codes for situations where the agent's intent genuinely cannot be satisfied.
   - **Structured errors on stdout**: Errors go to **stdout** in the same structured format as normal output, so the agent can read and act on them. Include what went wrong and an actionable suggestion. Never let raw dependency output (API errors, stack traces) leak through.
   - **No interactive prompts**: Every operation must be completable with flags alone. If a required value is missing, fail immediately with a clear error — don't prompt for it. Suppress prompts from wrapped tools.
   - **Output channels**: stdout = structured output (data, errors, suggestions); stderr = debug logging, progress indicators, diagnostics (agents don't read this). Exit codes: 0 = success (including no-ops), 1 = error, 2 = usage error.

   ```
   $ tasks close 42
   task: #42 already closed (no-op)    # exit 0

   error: --title is required
   help: tasks create --title "..." [--body "..."]
   ```

42. **Ambient Context via Session Integrations**: Register your tool into the agent's session lifecycle so every conversation starts with relevant state already visible — before the agent takes any action.
   - **Default app targets**: by default, support Claude Code, Codex, and OpenCode. Do not hard-code a single agent integration when the tool can reasonably support multiple agents.
   - **Explicit opt-in**: register hooks or plugins only from a user-invoked setup command, not from ordinary CLI commands.
   - **Portable commands**: hook commands should use a PATH-verified binary name when it resolves to the current executable, and fall back to the full absolute path otherwise.
   - **Path repair**: setup commands should check existing hooks and update the executable path if it has changed (e.g., after reinstall or relocation).
   - **Idempotent**: repeated installs with the same path are silent no-ops.
   - **Directory-scoped**: show only state relevant to the current working directory.
   - **Token-budget-aware**: this context loads on _every_ session — ruthlessly minimize it. Include just enough for the agent to orient and act; deep data belongs in explicit invocations.
   - **Lifecycle capture**: use session-end hooks to capture what happened (transcripts, files touched, specs referenced) so future session-start context gets richer over time.

   **Integration specifics**:
   - **Claude Code**: use native hooks in `~/.claude/settings.json` or project `.claude/settings.json`. Prefer `SessionStart` to inject compact context via stdout.
   - **Codex**: use native hooks in `~/.codex/hooks.json` or `<repo>/.codex/hooks.json`, and ensure `[features].hooks = true` in `config.toml`. Prefer `SessionStart` for ambient context via stdout.
   - **OpenCode**: use a managed plugin in `~/.config/opencode/plugins/`. Prefer ambient system-context injection for the home view rather than adding a custom tool.

43. **Installable Agent Skill (Secondary)**: The session hook is the primary integration, but offer an installable [Agent Skill](https://agentskills.io) as a secondary discovery path. It loads on demand when the agent recognizes a matching task, carries no per-session token cost, and works in any agent that supports the skill format.
   - **Single source of truth**: generate `SKILL.md` from the same content your no-args home view prints, so the skill never drifts from the CLI's own guidance. Add a `--check` build step to CI that fails if the committed skill is stale.
   - **Strip live state**: a skill is static, so omit dynamic data (open sessions, current items) that only the hook can show.
   - **Non-interactive commands**: rewrite command examples to a form the agent can run without a global install (e.g. `npx -y mytool ...`), since a skill may be installed without the binary on PATH.
   - **Trigger-shaped frontmatter**: include `name` and a `description` written as a trigger — terse and outcome-focused so the agent loads it on the right intent.
   - **Document both paths**: in your README, present the hook and the skill as two ways to achieve the same thing, and make clear the user only needs one.

44. **Content First**: Running your CLI with no arguments should show the most relevant live content — not a usage manual. When an agent sees actual state it can act immediately. When it sees help text, it has to make a second call.

   ```
   $ tasks
   tasks[3]{id,title,status}:
     1,Fix auth bug,open
     2,Add pagination,open
     3,Update docs,closed
   help[2]:
     Run `tasks view <id>` to see full details
     Run `tasks create --title "..."` to add a task
   ```

45. **Contextual Disclosure**: Include **a few next steps** that follow logically from the current output. The agent discovers your CLI's surface area organically by using it, not by reading a manual upfront.
   - **Relevant**: after an open item → suggest closing; after an empty list → suggest creating; after a list → suggest viewing
   - **Actionable**: every suggestion is a complete command (or template) carrying forward any disambiguating flags from the current invocation (e.g., `--repo`, `--source`)
   - **Concise**: 2-4 suggestions maximum, ranked by relevance
   - **Structured**: use a `help[]` array in TOON output for machine parsing

### Human Mode Preservation

Human mode retains all existing user-friendly features:
- TUI mode via `--interactive` or `--tui`
- Rich colors and formatting (respecting `--color` settings)
- Pager integration for long output
- Interactive confirmation prompts (unless `--force` is used)
- Progress bars and spinners
- Detailed help text and usage manuals
- Man pages and shell completion
- All existing human-centric behaviors

CLI boilerplates **must** implement these standards and additionally provide:

1. **Developer Experience**: Makefile targets `clean`, `build`, `install`, `lint`, `test`, `run`, `docker-build`, `docker-run`. Include `run.sh` wrapper for Docker usage and a hardened `docker-compose.yml`.
   - Add setup targets: `doctor`, `bootstrap`, `profile`.
   - `doctor` must validate `flake.nix` exists.
2. **Project-Scoped Toolchain**: Include a pinned `flake.nix` devShell and use `nix develop -c` in Makefile targets.
3. **Direnv**: Include a `.envrc` file with `use flake` to auto-load the Nix devShell via `direnv`.
4. **Container Hardening**: Multi-stage Dockerfile, non-root user, drop caps, `no-new-privileges`, read-only root filesystem with tmpfs for writable paths.
5. **Copier Hygiene**: Templates live under `boilerplate/apps/cli/*`, include `.copier-answers.yml` in generated projects, and stay minimal in Jinja logic.

## Rationale

Codified CLI standards prevent drift across languages, give users predictable UX/IO semantics, and simplify security reviews.

Boilerplates are the enforcement mechanism and reference implementation. Requiring Makefile, Docker, and test parity ensures each template is production-ready and updateable via `copier`.

## Technical Approach

- Keep standards language-agnostic; use idiomatic libraries (e.g., Typer, Clap, Cobra, Commander, Spectre.Console, Picocli, Dir.glob).
- Standard arguments (`--help`, `--version`, `--usage`) should be built into the CLI framework's argument parser.
- Config file initialization should check for existing config before creating defaults; use template-based generation with comments explaining each setting.
- **Install Flag**: Use `--install` to orchestrate shell completion generation, config initialization, and environment setup. Store completion scripts in standard locations (`~/.local/share/bash-completion/completions/`, `~/.zfunc/`, `~/.config/fish/completions/`).
- For TUI mode, use language-appropriate libraries with consideration for use case:
  - **Go**: Bubble Tea for both dashboard and interactive CLIs
  - **Python**: Textual for both dashboard and interactive CLIs
  - **Rust**: ratatui for dashboard-style tools, cursive for interactive CLI programs
  - **Node.js**: blessed for interactive CLIs
  - **Other languages**: Use idiomatic TUI libraries for the ecosystem
- **Progress Indicators**: Use libraries like `progress`, `tqdm`, `indicatif`, `cli-progress`. Always check for `--quiet` flag before showing progress.
- **Color Control**: Implement color mode resolution with precedence: NO_COLOR env var > --color flag > config file setting > auto-detection. Use language-appropriate color libraries (colored/termcolor for Python, console/fmt for Rust, chalk/ansi-colors for Node.js, fatih/color or aurora for Go). Smart TTY detection should check if stdout is a terminal using `isatty` or equivalent (mattn/go-isatty for Go). Config file should include `color = "auto|always|never"` setting with "auto" as default.
- **Configuration Management**: Use language-appropriate config libraries (pydantic/pydantic-settings for Python, config/config for Rust, cosmiconfig for Node.js, viper or koanf for Go). Support TOML, YAML, and JSON formats with proper precedence handling.
- **Shell Completion**: Auto-generate from command structure where possible (Clap derive for Rust, Cobra completion for Go, Typer completion for Python, commander/oclif for Node.js, yargs for Node.js). Manual completion for complex dynamic commands.
- **Progress Indicators**: Use libraries like `progress`/`tqdm` (Python), `indicatif` (Rust), `cli-progress` (Node.js), schollz/progressbar or charmbracelet/bubbletea for Go. Always check for `--quiet` flag before showing progress.
- **Credential/Secret Handling**: Use language-appropriate secret storage (keyring for Python, keyring-rs for Rust, keytar for Node.js, zalando/go-keyring or 99designs/keyring for Go). Never log secrets, implement redaction in logging.
- **Daemon Process Management**: Use language-appropriate process management (daemonize for Python, daemonize for Rust, daemonize for Node.js, github.com/kardianos/service or fvbock/endless for Go). Store job state in XDG data directory using SQLite or JSON files.
- **Globbing/Input Handling**: Use language-appropriate globbing (glob for Python, globwalk for Rust, glob for Node.js, doublestar or glob for Go). Support stdin via `-` or piped input with proper detection.
- **Daemon Processes**: Implement background job management with PID files or process managers. Store job state in XDG data directory. Provide job listing and cancellation commands. For platform-specific daemon modes, use conditional compilation (e.g., `#[cfg(target_os = "linux")]` in Rust) and provide clear error messages with fallback to synchronous processing on unsupported platforms.
- **Collection vs Processing Separation**: Design data collection and analysis as separate concerns. Collection runs as daemon/background process writing to persistent storage. Analysis commands read from storage and can run independently. Use portable data formats (JSONL, SQLite) for export/import.
- **Config Auto-Migration**: On startup, detect legacy config formats and auto-migrate to current schema. Create `.bak` backup of original file. Log migration actions at info level. Validate migrated config before use. Support both formats for one release cycle with deprecation warnings.
- **Structured Logging**: Use language-appropriate structured logging libraries (tracing/subscriber for Rust, pino for Node.js, structlog for Python). Auto-detect TTY for format selection (JSON for non-TTY, pretty for TTY). Support language-native env filters alongside custom env vars.
- **Config Reload**: Install signal handler for `SIGHUP`. On receipt, reload config files from disk, validate, and apply if valid. If validation fails, log error and keep previous config active. Log all reload attempts and results.
- **Health Checks**: For containerized CLIs, provide health check via signal (e.g., `SIGUSR1` writes health status to file) or HTTP endpoint (`/health`). Health check must be fast (<100ms) and have no side effects. Validate core functionality without altering state.
- **Privacy Mode**: Implement ignore lists for sensitive identifiers. Use config array for explicit anonymous entries. Distinguish between "unknown" (logged, not assigned) and "anonymous" (never logged). Provide privacy toggle to disable specific data collection types.
- **Audit Logging**: Use append-only storage (SQLite recommended) for audit trails. Schema must include timestamp, event type, source, and metadata. Implement configurable retention with auto-prune on startup. Provide export command for external analysis.
- **Legacy Deprecation**: Document deprecation date in release notes and CLI help. Log deprecation warnings to stderr on every run during deprecation period. Minimum 6 months from announcement to removal.
- **Error Formatting**: Use consistent error format with file references in VSCode-compatible format: `file:///path/to/file:line:col` or `path/to/file:line:col`.
- **URL Formatting**: Ensure all URLs are properly encoded HTTP/HTTPS URLs. Use URL libraries for encoding validation.
- **Shell Completion**: Auto-generate from command structure where possible (Clap derive, Cobra completion, Typer completion). Manual completion for complex dynamic commands.
- **Man Pages**: Generate from help text or maintain separate man page source in roff format. Use tools like `pandoc`, `ronn`, or framework-specific generators.
- **Pager Integration**: Detect terminal capabilities, respect `PAGER` env var, auto-pager output exceeding terminal height. Use libraries like `pager`, `lesspipe`, or manual pipe detection.
- **Exit Codes**: Define enum/constants for exit codes. Use specific codes: 0=success, 1=generic error, 2=usage error, 3=network error, 4=validation error, 5=file not found, 6=permission denied, 7=timeout, 130=SIGINT.
- **Cross-Platform Paths**: Use `path/filepath` (Go), `pathlib` (Python), `std::path` (Rust), `path` module (Node.js). Handle both `/` and `\` separators.
- **Credential Handling**: Use secret scanning, environment variable injection, keyring integration where available. Never log secrets, mask in error messages.
- **Resource Limits**: Implement memory/CPU monitoring, provide configuration options. Use platform-specific resource limiting APIs.
- Enforce stdout/stderr separation and JSON toggle at the command layer.
- Provide container artifacts (Dockerfile, docker-compose.yml, run.sh) with the hardened defaults above.
- Tests must be part of each template (pytest, assert_cmd, Vitest, bats, Pester, xUnit, JUnit, RSpec, etc.) and must cover color mode behavior (auto/always/never), NO_COLOR env var handling, and TTY detection.
- Document standards in the CLI README and cross-link this ADR from architecture docs.

## Affected Components

- All CLI boilerplate templates under `boilerplate/apps/cli/*`
- Makefile targets and development workflows
- Docker containerization standards
- Testing frameworks and coverage requirements
- Configuration management libraries and patterns

## Consequences

### Positive

- Consistent UX, diagnostics, and configuration across all CLIs.
- Faster onboarding and safer updates via copier re-application.
- Reduced security and compliance review overhead due to hardened defaults.
- Predictable behavior for automation and scripting.
- Enhanced developer experience with shell completion, TUI mode, and progress indicators.
- Better long-running operation management with daemon processes and job tracking.
- Improved error messages with actionable suggestions and file references.
- Cross-platform compatibility reduces platform-specific maintenance burden.

### Negative

- Existing generated projects may need updates to conform; copier updates could surface merge conflicts.
- Additional upfront work to keep tests and containers current per language ecosystem.
- Learning curve for developers unfamiliar with XDG config or Nix/direnv workflows.
- Increased implementation complexity due to comprehensive standards may slow initial development.
- More extensive testing required to validate all standards across platforms.
- Boilerplate templates become larger and more complex to maintain.

### Neutral

- Standardization may limit some language-specific optimizations in favor of consistency.
- Initial boilerplate complexity increases but long-term maintenance decreases.

## Alternatives Considered

- **Per-language guidelines only**: Rejected; too much variance and drift.
- **Minimal templates without containers/tests**: Rejected; not production-ready and increases toil later.
- **Ad-hoc per-project customization**: Rejected; undermines consistency and copier-based updates.
- **External CLI framework standardization**: Rejected; would lock ecosystem into specific frameworks rather than behavioral standards.

## Rollout / Migration

1. Update all existing CLI boilerplates to conform to these standards
2. Add validation scripts to check compliance in CI/CD
3. Document migration path for existing projects generated from old templates
4. Provide copier update instructions for project maintainers

## To Investigate

- Language-specific library recommendations for each standard (config parsing, globbing, signal handling, TUI frameworks, progress bars, pagers)
- CI/CD integration for validating CLI standard compliance
- Automated testing strategies for cross-platform CLI behavior
- Config file template generation strategies for complex nested configurations
- TUI library compatibility across different terminal emulators and platforms
- Distinction between dashboard-style vs interactive CLI TUI patterns per language
- Daemon process management strategies and cross-platform compatibility
- Shell completion auto-generation for complex dynamic commands
- Man page generation from help text vs manual maintenance
- Smart terminal URL linking and VSCode file reference format compatibility
- Cross-platform credential storage and keyring integration
- Resource limiting APIs and implementation patterns per platform

## Validation

- Audit existing CLI templates against these standards
- Test generated projects for compliance with all standards: configuration precedence, I/O behavior, signal handling, standard arguments, config initialization, install/uninstall, logging modes, dry-run, confirmation prompts, progress indicators, daemon processes, error formatting, shell completion, man pages, pager integration, subcommand organization, config validation, terminal awareness, cross-platform paths, credential handling, and resource limits
- Survey developers on UX consistency and onboarding experience
- Monitor reduction in security review findings related to CLI tools
- Validate TUI functionality across different terminal emulators and platforms
- Test shell completion scripts in bash, zsh, and fish
- Verify VSCode file reference format compatibility across terminals
- Test daemon process management and background job tracking
- Validate cross-platform behavior on Windows, Linux, and macOS
- Test pager integration with various PAGER configurations

## Review Schedule

- Review 6 months after adoption (2026-12-07)
- Annually thereafter or when major language ecosystem changes occur
- Review when AXI specification updates or new agent platforms emerge

## Notes

- This ADR draws from established CLI best practices including [12 Factor App](https://12factor.net/config), [POSIX standards](https://pubs.opengroup.org/onlinepubs/9699919799/), and modern CLI frameworks.
- Implementation details belong in individual boilerplate template documentation.
- Current state of decisions belong in AGENTS.md.

## References

- [Agent eXperience Interface (AXI) Specification](https://github.com/kunchenguid/axi/blob/main/.agents/skills/axi/SKILL.md)
- [TOON Format Specification](https://toonformat.dev/reference/spec.html)
- [Agent Skills Registry](https://agentskills.io)
- [Job-Aide CLI Standards ADR](https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251210001-cli-standards-and-boilerplates.md)
- [12 Factor App: Config](https://12factor.net/config)
- [POSIX Exit Codes](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_08_02)
- [NO_COLOR standard](https://no-color.org/)
- [Color Control: colored (Python)](https://pypi.org/project/colored/)
- [Color Control: termcolor (Python)](https://pypi.org/project/termcolor/)
- [Color Control: console (Rust)](https://docs.rs/console/)
- [Color Control: ansi-colors (Node.js)](https://github.com/doowb/ansi-colors)
- [Color Control: color (Go)](https://github.com/fatih/color)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [Command Line Interface Guidelines](https://clig.dev/)
- [TUI Libraries: Bubble Tea (Go)](https://github.com/charmbracelet/bubbletea)
- [TUI Libraries: Textual (Python)](https://github.com/Textualize/textual)
- [TUI Libraries: ratatui (Rust - dashboard style)](https://github.com/ratatui-org/ratatui)
- [TUI Libraries: cursive (Rust - interactive CLI)](https://github.com/gyscos/cursive)
- [TUI Libraries: blessed (Node.js)](https://github.com/chjj/blessed)
- [Shell Completion: bash-completion](https://github.com/scop/bash-completion)
- [Shell Completion: zsh-completions](https://github.com/zsh-users/zsh-completions)
- [Shell Completion: fish-shell](https://fishshell.com/docs/current/completions.html)
- [Progress Bars: cli-progress (Go)](https://github.com/schollz/progressbar)
- [Progress Bars: tqdm (Python)](https://github.com/tqdm/tqdm)
- [Progress Bars: indicatif (Rust)](https://github.com/console-rs/indicatif)
- [Man Page Generation: ronn](https://github.com/rtomayko/ronn)
- [Man Page Generation: pandoc](https://pandoc.org/)
- [VSCode Link Format](https://code.visualstudio.com/docs/editor/command-line#_opening-vs-code-with-urls)
- [Smart Terminal Links](https://iterm2.com/documentation-escape-codes.html)
- [Pager Integration: less](https://man7.org/linux/man-pages/man1/less.1.html)
- [Daemon Process Management](https://man7.org/linux/man-pages/man1/daemon.1.html)
- [Cross-Platform Path Handling](https://doc.rust-lang.org/std/path/index.html)
- [Credential Storage: keyring](https://github.com/jaraco/keyring)

<!-- vim: set ft=markdown: -->
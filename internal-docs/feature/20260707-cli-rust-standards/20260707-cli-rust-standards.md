---
# Product Requirements Document (PRD)

## Introduction / Overview
- **Feature name:** Rust CLI Tool Standards Compliance
- **Summary:** Complete redesign and implementation of the Rust CLI boilerplate to achieve full compliance with CLI Tool Standards ADR (adr-20260607001-cli-tool-standards.md). This involves implementing all 35 standards including proper color control, configuration management with auto-initialization and auto-migration, install/uninstall functionality, shell completion, man pages, daemon process support, TUI mode, structured logging with format auto-detection, signal-based config reload, health checks for containers, privacy mode, audit logging, and comprehensive testing coverage.
- **Context:**
  - This is a template that will be used to scaffold all future Rust CLI tools in the monorepo
  - Current implementation covers basic CLI functionality but lacks 20+ critical standards
  - Full compliance is required to ensure consistency across all CLI tools and provide a production-ready starting point
  - Related to ADR 20260607001 which defines comprehensive cross-language CLI standards
  - Breaking changes are acceptable since this is a template affecting future tools, not existing production systems

## Goals
- Achieve 100% compliance with all 35 CLI Tool Standards defined in ADR 20260607001
- Provide comprehensive test coverage for all implemented features before completion
- Create a production-ready Rust CLI template that serves as a gold standard for CLI development
- Ensure the template supports all major CLI use cases: simple data processing, long-running services, and interactive configuration
- Complete implementation within a single release cycle (2-4 weeks)
- Establish clear patterns and abstractions that can be reused across different CLI tools

## User Stories

### As a developer scaffolding a new CLI tool
- I want the generated CLI to support all standard arguments (--help, --version, --usage) so that users have consistent expectations
- I want proper color control with --color=auto|always|never flags so that output works correctly in all environments
- I want shell completion scripts auto-generated so that users get a better command-line experience
- I want man pages included so that users can access documentation offline
- I want --install/--uninstall functionality so that setup and cleanup are automated

### As a developer building a data processing CLI
- I want stdin/stdout support with globbing so that my tool can work with files and pipes
- I want JSON output mode so that my tool can be used in automation pipelines
- I want proper logging modes (--verbose, --quiet, --debug) so that users can control output verbosity
- I want progress indicators for long operations so that users know the tool is working

### As a developer building a long-running service CLI
- I want daemon process support with job management so that background operations can be tracked
- I want --list-jobs and --cancel-job commands so that users can manage background work
- I want auto-spawning of daemons so that async operations work seamlessly
- I want resource limit flags (--max-memory, --max-cpu) so that operations can be constrained

### As a developer building an interactive configuration CLI
- I want TUI mode for complex configuration so that users can interactively set options
- I want dry-run mode so that users can preview changes before execution
- I want confirmation prompts for destructive operations so that users don't accidentally lose data
- I want configuration validation with clear error messages so that setup issues are easy to diagnose

### As a developer maintaining the CLI
- I want config file auto-migration so that schema changes don't break existing users
- I want audit logging so that operations can be tracked for security and debugging
- I want health check endpoints for container deployments so that orchestration systems can monitor the tool
- I want comprehensive test coverage so that regressions are caught early
- I want structured logging with format auto-detection so that logs work well in both terminal and automated environments
- I want signal-based config reload so that I can update configuration without restarting the service
- I want privacy mode so that sensitive data can be protected during collection and processing
- I want legacy deprecation policy so that breaking changes are managed gracefully with clear timelines

## Functional Requirements

### Standard Arguments (Standard #1)
- MUST support `--help`/`-h` at root command and all major subcommands
- MUST support `--version`/`-v` displaying version information
- MUST support `--usage` displaying brief usage summary
- Implementation: Use clap's built-in support for help/version, add custom usage flag

### Configuration Management (Standards #2, #3, #4, #21, #29)
- MUST implement configuration precedence: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults
- MUST support TOML as primary format (human-edited), YAML acceptable for complex structures, JSON for machine-to-machine
- MUST initialize default config file on first run with all settings commented out, including default values and explanations
- MUST provide `--install` flag that generates shell completion scripts, initializes default config files, and sets up required environment
- MUST provide `--uninstall` counterpart for cleanup
- MUST validate config files on load with clear, specific error messages including line numbers and suggestions
- MUST auto-migrate legacy configs to new format on schema changes, creating `.bak` backup, logging migration actions, and validating migrated config
- MUST support both legacy and new formats for at least one release cycle with deprecation warnings

### Input & Output (Standards #5, #6, #15, #16, #19)
- MUST support recursive `**/*` globbing plus stdin via `-` or piped input
- MUST process files or stdin interchangeably
- MUST output results to stdout, logs/progress/errors to stderr
- MUST provide `--json` output mode
- MUST support `--color=auto|always|never` flag (default: auto) with smart TTY detection in auto mode
- MUST include `color` setting in config file with same modes (auto|always|never)
- MUST honor `NO_COLOR` environment variable (takes precedence over all other color settings)
- MUST format file references with line numbers using VSCode-compatible format: `file:///absolute/path/to/file:line:column` or standard `file:line:column`
- MUST format all URLs in browser-compatible format with proper encoding
- MUST auto-pager for long output (respect `PAGER` env var, default to `less`)
- MUST provide `--no-pager` flag to bypass paging

### Logging & Signals (Standards #7, #8, #23, #30, #31)
- MUST support `--verbose`/`-v`, `--quiet`/`-q`, and `--debug` flags for different logging levels
- MUST suppress all non-essential output including progress indicators in `--quiet` mode
- MUST handle SIGINT gracefully with exit code `130`
- MUST use standard exit codes: `0` success, `1` generic error, `2` usage error, plus specific codes for different error types
- MUST use consistent `UPPER_CASE` prefix for all environment variables (e.g., `MYTOOL_DEBUG`, `MYTOOL_CONFIG`)
- MUST implement structured logging with format auto-detection (JSON for non-TTY, pretty for TTY)
- MUST support language-native env filters (RUST_LOG) alongside custom env vars
- MUST resolve log level with precedence: env vars > CLI flags > config file > defaults
- MUST support SIGHUP to reload config files without restart
- MUST validate new config before applying, log reload events, and handle validation errors gracefully (keep old config active)

### Advanced CLI Features (Standards #9, #10, #11, #12, #13, #20, #22)
- MUST provide TUI (Terminal User Interface) mode for complex CLIs with multiple configurable options
- MUST trigger TUI via `--interactive` or `--tui` flag
- MUST allow users to view and modify all arguments before execution in TUI
- MUST support `--dry-run` flag to preview changes without execution
- MUST require confirmation for destructive operations with `--force` flag to bypass
- MUST show progress bars or spinners for long-running operations
- MUST respect `--quiet` flag (no progress indicators in quiet mode)
- MUST provide daemon process support for long-running tasks (>30 seconds) with:
  - `--daemon` and `--no-daemon` flags as opposites
  - Auto-spawn daemon on first async operation (no flag required)
  - `--daemon` flag pre-launches daemon in background and waits for jobs
  - `--no-daemon` flag forces synchronous in-process operation (disables auto-spawning)
  - `--list-jobs` command to show background job status with optional job id filter
  - Return output from `--list-jobs` with job ID immediately when daemon performs background operation
  - `--cancel-job <id>` command to cancel specific background jobs
  - Instructions for monitoring job progress
  - Platform fallback with clear error message if daemon mode not supported
  - Config variable to override noisy behavior for unsupported platforms
- MUST organize commands hierarchically with consistent patterns under logical subcommands
- MUST detect terminal size on startup and handle resize events where possible

### Documentation & Integration (Standards #17, #18)
- MUST provide shell completion scripts for bash, zsh, and fish
- MUST prefer auto-generation but must be maintained to match current command structure
- MUST provide traditional Unix man pages accessible via `man <command>` or `--man` flag

### Cross-Platform & Security (Standards #24, #25, #26)
- MUST handle paths consistently across Windows/Linux/macOS with platform-appropriate separators
- MUST handle both forward and backward slashes
- MUST securely handle sensitive data with no logging of secrets
- MUST provide secure storage options
- MUST provide clear warnings about insecure config methods
- MUST provide `--max-memory` and `--max-cpu` flags for long-running operations where applicable

### Advanced Features (Standards #27, #28, #30, #31, #32, #33, #34, #35)
- MUST include language-appropriate tests covering: help output, globbing, stdin, config precedence, json vs human output, exit-code behavior, standard arguments, config file initialization, shell completion, error handling, daemon mode
- MUST separate collection (daemon/background) from processing (offline analysis) for CLIs that collect data and perform analysis
- MUST allow data collection in one environment and processing in another
- MUST provide export commands for collected data
- MUST provide analysis commands that operate on exported data without requiring collection daemon
- MUST provide health check endpoints for container deployments
- MUST provide privacy mode with anonymous lists for sensitive operations
- MUST provide audit logging with retention policies
- MUST implement legacy deprecation policy with clear migration paths
- MUST implement structured logging with format auto-detection (JSON for non-TTY, pretty for TTY)
- MUST support language-native env filters (RUST_LOG) alongside custom env vars
- MUST resolve log level with precedence: env vars > CLI flags > config file > defaults
- MUST support SIGHUP to reload config files without restart
- MUST validate new config before applying, log reload events, and handle validation errors gracefully (keep old config active)
- MUST provide health check mechanism (signal or HTTP endpoint) for container orchestration
- MUST validate operational state without side effects in health checks
- MUST support privacy mode with explicit ignore lists for sensitive identifiers
- MUST distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely)
- MUST provide configurable privacy toggles to disable specific data collection
- MUST provide optional append-only audit log (SQLite) with configurable retention period
- MUST auto-prune old audit data on startup
- MUST support export commands for audit log external analysis
- MUST specify clear end-of-support date for breaking changes (minimum 6 months from announcement)
- MUST log deprecation warnings to stderr during deprecation period
- MUST remove legacy support only after specified date

## Non-Functional Requirements

### Performance
- CLI startup time must be under 100ms for basic operations
- Config file loading and validation must complete in under 50ms
- Shell completion scripts must return results within 200ms
- Progress indicators must not significantly impact operation performance

### Security
- No secrets or credentials may be logged at any log level
- Config files must have appropriate file permissions (user-readable only)
- Sensitive data in memory must be zeroed when no longer needed
- Daemon processes must run with minimal required privileges
- Input validation must prevent injection attacks

### Usability
- All error messages must be actionable with specific suggestions for resolution
- Error format: `ERROR: <description> - <suggestion>`
- Help text must be clear and concise, avoiding jargon where possible
- Default behavior must be sensible for common use cases
- Configuration file must be self-documenting with comments

### Maintainability
- Code must follow Rust best practices and idioms
- Must use established Rust crates for CLI functionality (clap, anyhow, tracing, etc.)
- Must have comprehensive test coverage (>90% for new code)
- Must include inline documentation for all public APIs
- Must follow the project's existing code style and patterns

### Compatibility
- Must support Rust 2021 edition
- Must support Linux (Debian), Windows, and macOS
- Must work with common shells: bash, zsh, fish
- Must handle both TTY and non-TTY environments correctly
- Must respect common environment variables (PAGER, NO_COLOR, etc.)

## Technical Considerations

### Dependencies
- **CLI parsing**: clap 4.4+ with derive and env features
- **Error handling**: anyhow 1.0+, thiserror 1.0+
- **Config management**: serde 1.0+, toml 0.8+, directories 5.0+
- **Logging**: tracing 0.1+, tracing-subscriber 0.3+ with env-filter, json, ansi features
- **Structured logging**: tracing-subscriber with JSON layer for non-TTY output
- **Signal handling**: signal-hook or tokio::signal for SIGHUP config reload
- **Health checks**: HTTP server (axum/warp) or signal-based health check mechanism
- **Privacy mode**: Custom ignore list implementation with config support
- **Audit logging**: SQLite (rusqlite) for append-only audit log with retention
- **Color control**: console or ansi-term for proper --color=auto|always|never support
- **TUI**: ratatui for dashboard-style tools, cursive for interactive CLI programs
- **Progress indicators**: indicatif 0.17+
- **Globbing**: glob 0.3+
- **Shell completion**: clap_generate or clap_complete for auto-generation
- **Man pages**: help2man or similar tool for generating man pages from help text
- **Daemon management**: tokio 1.0+ for async runtime, custom job queue implementation
- **Testing**: assert_cmd 2.0+, predicates 3.0+, tempfile 3.8+

### Architecture
- Modular structure with separate modules for:
  - CLI argument parsing (cli.rs)
  - Configuration management (config.rs)
  - Logging setup (logging.rs)
  - Color control (color.rs)
  - Daemon/job management (daemon.rs)
  - TUI interface (tui.rs)
  - Shell completion (completion.rs)
  - Input/output handling (io.rs)
  - Error formatting (error.rs)
  - Structured logging (structured_log.rs)
  - Signal handling (signals.rs)
  - Health checks (health.rs)
  - Privacy mode (privacy.rs)
  - Audit logging (audit.rs)
  - Deprecation management (deprecation.rs)
- Trait-based abstractions for extensibility
- Clear separation between collection and processing phases

### Configuration Schema
- TOML-based configuration with clear section organization
- Version field in config for migration tracking
- Schema validation on load with detailed error messages
- Auto-migration system with backup creation

### Testing Strategy
- Unit tests for individual modules
- Integration tests for CLI commands using assert_cmd
- Property-based tests for configuration logic
- Cross-platform tests for path handling
- Performance benchmarks for startup time
- Manual testing checklist for TUI and daemon features

### Migration Path
- Version the config schema explicitly
- Provide migration functions for each schema version
- Create backups before migration
- Log all migration actions
- Support legacy configs for one release cycle with deprecation warnings

## Success Metrics
- 100% compliance with all 35 CLI Tool Standards
- Test coverage >90% for all new code
- All tests passing before completion
- CLI startup time <100ms
- Zero security vulnerabilities in dependency scan
- Successful generation of shell completion scripts for bash, zsh, fish
- Man pages generated and accessible
- Config file auto-initialization working on first run
- Config migration working for at least one schema version change
- Daemon mode spawning and job management functional
- TUI mode launching and accepting user input
- Dry-run mode showing correct preview of changes
- Progress indicators displaying correctly in long operations
- Color control working correctly in all modes (auto/always/never)
- NO_COLOR environment variable respected
- JSON output mode producing valid JSON
- Stdin/stdout/globbing all working correctly
- Cross-platform tests passing on Linux, Windows, macOS
- Structured logging auto-detecting TTY and switching formats correctly
- RUST_LOG environment variable respected alongside custom log levels
- SIGHUP signal triggering config reload without process restart
- Health check endpoint responding within 100ms with no side effects
- Privacy mode correctly ignoring specified identifiers
- Audit log writing append-only entries with configurable retention
- Auto-pruning of old audit data working on startup
- Deprecation warnings logged to stderr for legacy features
- Legacy support removed only after specified end-of-support date

## Open Questions
- Should the daemon mode use a specific IPC mechanism (Unix sockets, named pipes, HTTP)? Decision needed for cross-platform compatibility
- What is the maximum reasonable size for config files before performance degrades? Need to establish benchmarks
- Should TUI mode be optional via feature flag to reduce dependency bloat for simple CLIs?
- What is the preferred approach for man page generation - static files or dynamic generation from help text?
- How should audit logs be rotated and retained? Need to define retention policy

## Dependencies
- ADR 20260607001: CLI Tool Standards (defines all requirements)
- Existing Rust CLI boilerplate (current implementation to be redesigned)
- Copier template system (for template generation)
- Devbox and justfile patterns (for development environment)
- Unified logging standards (adr-20260331001 from job-aide project)

## Timeline / Milestones

### Week 1: Foundation & Core Features
- Implement standard arguments (#1)
- Implement configuration management system (#2, #3, #4, #21, #29)
- Implement input/output handling (#5, #6, #15, #16, #19)
- Implement logging and signal handling (#7, #8, #23, #30, #31)
- Implement structured logging with format auto-detection (#30)
- Implement signal-based config reload via SIGHUP (#31)
- Add comprehensive tests for all core features
- **Milestone**: Core CLI functionality complete and tested

### Week 2: Advanced Features
- Implement TUI mode (#9)
- Implement dry-run and confirmation prompts (#10, #11)
- Implement progress indicators (#12)
- Implement daemon process support (#13)
- Implement command organization and terminal awareness (#20, #22)
- Add comprehensive tests for advanced features
- **Milestone**: All advanced CLI features complete and tested

### Week 3: Integration & Documentation
- Implement shell completion scripts (#17)
- Implement man pages (#18)
- Implement cross-platform path handling (#24)
- Implement security features (#25, #26)
- Implement resource limits (#26)
- Implement health check mechanism for containers (#32)
- Add comprehensive integration tests
- **Milestone**: Integration features complete and tested

### Week 4: Final Features & Validation
- Implement testing requirements (#27)
- Implement collection/processing separation (#28)
- Implement privacy mode with anonymous lists (#33)
- Implement audit logging with retention (#34)
- Implement legacy deprecation policy (#35)
- Full test suite validation
- Performance benchmarking
- Security scanning
- Documentation updates
- **Milestone**: 100% standards compliance achieved, all tests passing, ready for release

---
*Generated from PRD template*

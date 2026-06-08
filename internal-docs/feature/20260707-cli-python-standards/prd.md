---
# Product Requirements Document (PRD)

## Introduction / Overview
- **Feature name:** Python CLI Standards Compliance
- **Summary:** Comprehensive implementation of all 29 CLI Tool Standards for the Python CLI boilerplate to ensure production-ready, consistent CLI tools across the monorepo.
- **Context:**
  - This feature brings the Python CLI boilerplate into full compliance with ADR-20260607001 (CLI Tool Standards)
  - Currently implements most standards through optional template flags
  - Target users: Developers generating CLI tools from the Python boilerplate template
  - Related ADR: adr-20260607001-cli-tool-standards.md

## Goals
- Achieve 100% compliance with all 29 CLI Tool Standards
- Provide comprehensive test coverage for all existing and new functionality
- Enable production-ready CLI tool generation with all expected features
- Maintain consistency with Go, Rust, and TypeScript CLI boilerplates
- Complete implementation within 1-2 weeks timeline

## User Stories
- As a developer generating a CLI tool from the Python boilerplate, I want shell completion scripts to be automatically generated so that users get tab completion out of the box
- As a CLI tool user, I want an `--install` flag to set up shell completions and default configuration so that I can get started quickly
- As a CLI tool user, I want proper color control with `--color=auto|always|never` so that output looks good in different environments
- As a developer, I want comprehensive test coverage for all CLI features so that I can trust the boilerplate code
- As a CLI tool user, I want progress indicators for long-running operations so that I know the tool is working
- As a CLI tool user, I want a TUI mode for complex configuration so that I can interactively set options
- As a CLI tool user, I want daemon mode for long-running tasks so that operations can run in the background
- As a developer, I want config file auto-migration so that schema changes don't break existing user configurations

## Functional Requirements

### High Priority (Core Missing Features)
1. **Config File Initialization**
   - Auto-create default config file on first run if none exists
   - Config file location: `$HOME/.config/{project_slug}/config.toml`
   - Include all settings commented out with default values and explanations
   - Support TOML format (primary) with YAML fallback for complex structures

2. **Install/Uninstall Flag**
   - Implement `--install` flag that:
     - Generates shell completion scripts for bash, zsh, and fish
     - Initializes default config files
     - Sets up required environment variables
     - Provides installation instructions
   - Implement `--uninstall` flag for cleanup
   - Use Click's built-in completion generation capabilities

3. **Proper Color Control**
   - Replace `--no-color` with `--color=auto|always|never` flag (default: auto)
   - Implement smart TTY detection in auto mode
   - Add `color` setting to config file with same modes
   - Honor `NO_COLOR` environment variable (takes precedence over all other settings)
   - Precedence: NO_COLOR env var > --color flag > config file setting > auto-detection

4. **Debug Flag**
   - Add `--debug` flag separate from `--verbose`
   - Debug mode should enable detailed diagnostic logging
   - Include stack traces and internal state information

5. **Shell Completion**
   - Generate completion scripts for bash, zsh, and fish using Click's completion commands
   - Auto-generate completions based on command structure
   - Include completions in `--install` flag output
   - Provide completion installation instructions

6. **Configuration Precedence Chain**
   - Implement full precedence: CLI args > env vars > local project config > user config (XDG) > system/enterprise config > hardcoded defaults
   - Support local project config: `.config/{project_slug}/config.toml` in project root
   - Support system/enterprise config: `/etc/{project_slug}/config.toml`
   - Ensure configuration library handles all precedence levels correctly

7. **Configuration Validation**
   - Validate config files on load
   - Report clear, specific error messages with line numbers
   - Provide suggestions for fixing configuration errors
   - Validate against schema before using config

### Medium Priority (Enhanced Features)
8. **Dry-Run Mode**
   - Implement `--dry-run` flag
   - Preview changes without executing them
   - Show exactly what would be done
   - Apply to all file operations and destructive actions

9. **Confirmation Prompts**
   - Require confirmation for destructive operations (delete, overwrite)
   - Implement `--force` flag to bypass prompts
   - Use consistent prompt format across all operations

10. **Progress Indicators**
    - Show progress bars for long-running operations
    - Use a Python progress bar library (e.g., rich.progress or tqdm)
    - Must respect `--quiet` flag (no progress in quiet mode)
    - Apply to file processing, network operations, etc.

11. **Error Message Formatting**
    - Standardize error format: `ERROR: <description> - <suggestion>`
    - Provide actionable suggestions for resolution
    - Include context (file, line number) where applicable
    - Use consistent error types and exit codes

12. **Man Pages**
    - Generate traditional Unix man pages
    - Accessible via `man {command}` or `--man` flag
    - Include all command documentation
    - Use Python doc generation tools

13. **Pager Integration**
    - Auto-pager for long output
    - Respect `PAGER` environment variable (default to `less`)
    - Provide `--no-pager` flag to bypass
    - Detect when output exceeds terminal height

14. **Terminal Size Awareness**
    - Detect terminal size on startup
    - Format output based on terminal width
    - Handle resize events where possible
    - Fall back to 80-column default

### Advanced Priority (Complex Features)
15. **TUI Mode**
   - Implement `--interactive` or `--tui` flag
   - Use a Python TUI library (textual or similar)
   - Allow interactive configuration and execution
   - Enable viewing and modifying all arguments before execution
   - Provide intuitive navigation and selection

16. **Daemon Process Support**
    - Implement `--daemon` and `--no-daemon` flags as opposites
    - Auto-spawn daemon on first async operation (no flag required)
    - `--daemon` flag pre-launches daemon in background and waits for jobs
    - `--no-daemon` flag forces synchronous in-process operation
    - Include `--list-jobs` command to show background job status
    - Include `--cancel-job <id>` command to cancel specific jobs
    - Return job ID immediately when daemon performs background operation
    - Provide instructions for monitoring job progress
    - Fall back to synchronous processing on unsupported platforms with clear error
    - Allow config variable to override noisy behavior for unsupported platforms

17. **File Reference Formatting**
    - Use VSCode-compatible format: `file:///absolute/path/to/file:line:column`
    - Support standard `file:line:column` format for terminal linking
    - Apply to all error messages and file references

18. **URL Formatting**
    - Ensure all URLs are browser-compatible
    - Use standard HTTP/HTTPS URLs with proper encoding
    - Support smart terminal linking where available

19. **Credential/Secret Handling**
    - Secure handling of sensitive data
    - No logging of secrets or credentials
    - Support secure storage options (keychain, encrypted files)
    - Clear warnings about insecure config methods

20. **Config File Auto-Migration**
    - Auto-migrate legacy configs to new format on schema changes
    - Create backup of old config with `.bak` suffix
    - Log all migration actions
    - Validate migrated config before use
    - Support both legacy and new formats for one release cycle
    - Provide deprecation warnings for legacy format

21. **Structured Logging with Format Auto-Detection**
    - Use structured logging (JSON or structured text)
    - Auto-detect format based on TTY (JSON for non-TTY, pretty for TTY)
    - Support language-native env filters (e.g., LOG_LEVEL)
    - Log level resolution: env vars > CLI flags > config file > defaults

22. **Signal-Based Config Reload**
    - Support SIGHUP to reload config files without restart
    - Validate new config before applying
    - Log reload events
    - Handle validation errors gracefully (keep old config active)

23. **Health Check for Containers**
    - Provide health check mechanism (signal or HTTP endpoint)
    - Support Docker HEALTHCHECK and Kubernetes probes
    - Validate operational state without side effects
    - Fast response (<100ms)

24. **Privacy Mode with Anonymous Lists**
    - Support privacy mode with explicit ignore lists
    - Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely)
    - Configurable privacy toggles to disable specific data collection

25. **Audit Logging with Retention**
    - Provide optional append-only audit log (SQLite or similar)
    - Configurable retention period
    - Auto-prune old data on startup
    - Support export commands for external analysis

26. **Legacy Deprecation Policy**
    - Specify clear end-of-support date (minimum 6 months from announcement)
    - Log deprecation warnings to stderr during deprecation period
    - Remove legacy support only after specified date

### Testing Requirements
27. **Comprehensive Test Coverage**
    - Test help output for all commands
    - Test globbing patterns and stdin handling
    - Test config precedence chain (CLI args > env vars > local > user > system > defaults)
    - Test JSON vs human output modes
    - Test exit code behavior (0, 1, 2, 130 for SIGINT)
    - Test standard arguments (--help, --version, --usage)
    - Test config file initialization on first run
    - Test shell completion generation
    - Test error handling and formatting
    - Test color control (auto/always/never) and NO_COLOR env var
    - Test debug flag behavior
    - Test dry-run mode
    - Test confirmation prompts and --force flag
    - Test progress indicators and quiet mode
    - Test daemon mode job management
    - Test TUI mode (if feasible in tests)
    - Test config validation error messages
    - Test config auto-migration
    - Test pager integration
    - Test terminal size awareness
    - Test credential handling (mock secure storage)
    - Test file reference formatting
    - Test URL formatting
    - Test structured logging format auto-detection
    - Test SIGHUP config reload
    - Test health check mechanism
    - Test privacy mode ignore lists
    - Test audit logging and retention
    - Test deprecation policy warnings

### Existing Functionality Tests
28. **Ensure Tests for Existing Features**
    - Test existing --verbose flag
    - Test existing --quiet flag
    - Test existing --no-color flag (for backward compatibility)
    - Test existing globbing with glob patterns
    - Test existing stdin handling
    - Test existing SIGINT handling (fix exit code to 130)
    - Test existing environment variable naming
    - Test existing cross-platform path handling
    - Test existing subcommand organization

## Non-Functional Requirements
- **Performance**: All features must not significantly impact CLI startup time (<100ms for basic operations)
- **Security**: No secrets or credentials logged; secure storage for sensitive data
- **Compatibility**: Breaking changes acceptable (per user choice), but provide migration guide
- **Maintainability**: Code must follow Python best practices and existing boilerplate patterns
- **Documentation**: All new features must be documented in code comments and help text
- **Testing**: 90%+ test coverage for all new code

## Technical Considerations
- **Dependencies**: Leverage existing Python ecosystem libraries as specified in ADR-20260607001:
  - **CLI Framework**: Click (pallets/click) for command structure and flags
  - **Config Management**: TOML (toml/toml) or pydantic for config handling
  - **Color Control**: colorama (tartley/colorama) or rich (Textualize/rich) with TTY detection
  - **Shell Completion**: Click's built-in completion generation
  - **TUI Library**: textual (Textualize/textual) for TUI mode
  - **Progress Indicators**: rich.progress (Textualize/rich) or tqdm (tqdm/tqdm)
  - **Credential Storage**: keyring (jaraco/keyring) for secure storage
  - **Daemon Process**: multiprocessing or asyncio for background tasks
  - **Globbing**: glob (standard library) or glob2 (miracle2k/glob2)
- **Config Management**: Extend existing TOML usage for full precedence chain
- **Shell Completion**: Use Click's built-in completion generation
- **TUI Library**: Use textual (https://github.com/Textualize/textual) for TUI mode
- **Progress Library**: Use rich.progress (https://github.com/Textualize/rich) or similar
- **Daemon Implementation**: Use Python's multiprocessing or asyncio with proper signal handling
- **Config Migration**: Implement version-based migration system in config loading
- **File Templates**: Update all Jinja2 templates in boilerplate/apps/cli/python/core/files/

## Success Metrics
- 100% compliance with all 29 CLI Tool Standards
- 90%+ test coverage for all CLI functionality
- All existing tests continue to pass
- New features work across Linux, macOS, and Windows
- Shell completion scripts generated correctly for bash, zsh, and fish
- Config file initialization works on first run
- Color control works correctly in all modes (auto/always/never)
- Daemon mode successfully manages background jobs
- TUI mode provides interactive configuration
- Config auto-migration preserves user settings

## Open Questions
- Should the daemon mode use a specific IPC mechanism (Unix sockets, named pipes, etc.)?
- What specific TUI features should be included in the initial implementation?
- Should config migration support multiple legacy versions or just the immediate previous version?

## Dependencies
- ADR-20260607001 (CLI Tool Standards) - must be followed exactly
- Existing Python CLI boilerplate structure - must be extended, not replaced
- Click and TOML libraries - already in use, will be extended
- Python ecosystem libraries for TUI and progress indicators

## Timeline / Milestones
- **Week 1**: Implement high-priority features (config initialization, install/uninstall, color control, debug flag, shell completion, config precedence, config validation)
- **Week 2**: Implement medium-priority features (dry-run, confirmation prompts, progress indicators, error formatting, man pages, pager integration, terminal awareness)
- **Week 2-3**: Implement advanced features (TUI mode, daemon support, file references, URLs, credentials, config migration, structured logging, config reload, health checks, privacy mode, audit logging, deprecation policy) + comprehensive testing

---
*Generated from PRD template*

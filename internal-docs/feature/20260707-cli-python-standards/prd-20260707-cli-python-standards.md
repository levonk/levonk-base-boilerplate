---
# Product Requirements Document (PRD)

## Introduction / Overview
- **Feature name:** Python CLI Standards Compliance
- **Summary:** Update the Python CLI boilerplate to fully comply with the CLI Tool Standards ADR (adr-20260607001), implementing all 35 standards including configuration management, install/uninstall functionality, advanced color control, daemon process support, structured logging, config reload, health checks, privacy mode, audit logging, and comprehensive testing.
- **Context:**
  - The Python CLI boilerplate currently implements basic CLI functionality but lacks many standards defined in the CLI Tool Standards ADR
  - This gap causes inconsistent UX across CLI tools in the monorepo and prevents the Python boilerplate from being production-ready
  - Related ADR: adr-20260607001-cli-tool-standards.md defines 35 comprehensive standards for CLI tools
  - This implementation is critical priority with immediate timeline (2-3 weeks) and must maintain full backward compatibility

## Goals
- Achieve 100% compliance with the CLI Tool Standards ADR (all 35 standards)
- Ensure all existing CLIs generated from the current boilerplate continue to work without modification
- Provide comprehensive test coverage for all new functionality
- Create a production-ready Python CLI boilerplate that matches the quality of other language implementations
- Enable advanced features like daemon mode, TUI support, structured logging, and audit logging for complex CLI applications

## User Stories
- As a developer using the Python CLI boilerplate, I want the generated CLI to automatically initialize configuration files on first run so that users have a clear starting point
- As a CLI user, I want an `--install` flag that sets up shell completions and default configuration so I can start using the tool immediately
- As a CLI user, I want proper color control with `--color=auto|always|never` flags so I can control output appearance in different environments
- As a developer, I want comprehensive test coverage for all CLI standards so I can confidently deploy the tool
- As a CLI user, I want daemon mode support for long-running operations so I can continue working while tasks complete in the background
- As a CLI user, I want clear error messages with suggestions so I can quickly resolve issues without consulting documentation
- As a developer, I want the boilerplate to maintain backward compatibility so existing generated CLIs don't break

## Functional Requirements

### Core CLI Standards (Priority 1)
1. **Standard Arguments Enhancement**
   - Ensure `--help`/`-h`, `--version`/`-v`, and `--usage` work at root command and all major subcommands
   - Add `--debug` flag separate from `--verbose` for detailed debugging output

2. **Configuration Management**
   - Implement config file initialization: create default config with commented settings on first run
   - Add config file validation on load with clear error messages including line numbers
   - Support config file auto-migration when schema evolves (backup old config, log migration)
   - Implement configuration precedence: CLI args > env vars > local config > user config (XDG) > system config > defaults
   - Add TOML as primary config format (YAML acceptable for complex structures, JSON for machine-to-machine)

3. **Install/Uninstall Functionality**
   - Implement `--install` flag that:
     - Generates shell completion scripts for bash/zsh/fish
     - Initializes default config files
     - Sets up required environment
   - Implement `--uninstall` counterpart for cleanup
   - Add shell completion auto-generation using Typer's built-in completion system

4. **Color Control Enhancement**
   - Replace `--nocolor` with proper `--color=auto|always|never` flag (default: auto)
   - Implement smart TTY detection in auto mode
   - Add `color` setting to config file with same modes (auto|always|never)
   - Ensure NO_COLOR environment variable takes precedence over all other color settings
   - Implement color mode resolution precedence: NO_COLOR env var > --color flag > config file setting > auto-detection

5. **Error Message Formatting**
   - Implement consistent error format: `ERROR: <description> - <suggestion>`
   - Add actionable suggestions for resolution in all error messages
   - Include file references with line numbers in VSCode-compatible format: `file:///absolute/path/to/file:line:column`
   - Ensure all URLs are in browser-compatible format with proper encoding

6. **Signal Handling Enhancement**
   - Maintain existing SIGINT handling with exit code 130
   - Add standard exit codes: 0 (success), 1 (generic error), 2 (usage error)
   - Add specific exit codes for different error types (network errors, validation errors, file not found, permission denied)

### Advanced CLI Standards (Priority 1)
7. **Daemon Process Support**
   - Implement `--daemon` and `--no-daemon` flags as opposites
   - Auto-spawn daemon on first async operation (no flag required)
   - `--daemon` flag pre-launches daemon in background and waits for jobs
   - `--no-daemon` flag forces synchronous in-process operation (disables auto-spawning)
   - Add `--list-jobs` command to show background job status with optional job ID filtering
   - Return job ID immediately when daemon performs background operation
   - Add `--cancel-job <id>` command to cancel specific background jobs
   - Provide instructions for monitoring job progress
   - Fall back to synchronous processing with clear error message if daemon not supported on platform
   - Allow config variable to override noisy behavior for unsupported platforms

8. **TUI Mode Support**
   - Add `--interactive` or `--tui` flag for terminal user interface mode
   - Implement TUI using `textual` or `rich` library for interactive configuration
   - Allow users to view and modify all arguments before execution
   - Make TUI mode optional via template choice for simple CLIs that don't need it

9. **Dry-Run Mode**
   - Implement `--dry-run` flag to preview changes without execution
   - Show exactly what would be done without making any changes
   - Apply dry-run to all destructive operations

10. **Confirmation Prompts**
    - Require confirmation for destructive operations (delete, overwrite)
    - Add `--force` flag to bypass prompts
    - Implement consistent prompt behavior across all destructive operations

11. **Progress Indicators**
    - Show progress bars or spinners for long-running operations (>30 seconds)
    - Must respect `--quiet` flag (no progress indicators in quiet mode)
    - Use `rich.progress` for consistent progress display

12. **Logging Modes Enhancement**
    - Maintain existing `--verbose`/`-v` and `--quiet`/`-q` flags
    - Add `--debug` flag for detailed debugging output separate from verbose
    - Ensure `--quiet` suppresses all non-essential output including progress indicators
    - Add structured logging support (JSON format) for machine-readable logs

13. **Shell Completion**
    - Generate shell completion scripts for bash, zsh, and fish using Typer's completion system
    - Ensure completions match current command structure
    - Include completion installation in `--install` flag

14. **Man Pages**
    - Generate traditional Unix man pages for documentation
    - Make accessible via `man <command>` or `--man` flag
    - Use standard man page format with sections: NAME, SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, SEE ALSO

15. **Pager Integration**
    - Auto-pager for long output (respect `PAGER` env var, default to `less`)
    - Provide `--no-pager` flag to bypass paging
    - Detect when output exceeds terminal height and auto-pager

16. **Subcommand Organization**
    - Ensure hierarchical command structure with consistent patterns
    - Group related commands under logical subcommands
    - Maintain consistent naming conventions across subcommands

17. **Terminal Size Awareness**
    - Detect terminal size on startup
    - Handle resize events where possible
    - Implement responsive output formatting based on terminal width

18. **Environment Variable Naming**
    - Ensure consistent `UPPER_CASE` prefix for all environment variables
    - Follow pattern: `{{PROJECT_SLUG}}_SETTING` (e.g., `MYTOOL_DEBUG`, `MYTOOL_CONFIG`)

19. **Cross-Platform Path Handling**
    - Maintain existing `pathlib.Path` usage
    - Ensure platform-appropriate separators
    - Handle both forward and backward slashes correctly

20. **Credential/Secret Handling**
    - Implement secure handling of sensitive data
    - Ensure no logging of secrets or credentials
    - Provide secure storage options (keyring integration)
    - Add clear warnings about insecure config methods

21. **Resource Limits**
    - Add `--max-memory` and `--max-cpu` flags where applicable
    - Implement memory/CPU usage guidelines for long-running operations
    - Add resource monitoring for daemon processes

22. **Collection vs Processing Separation**
    - For CLIs that collect data and perform analysis, separate collection (daemon/background) from processing (offline analysis)
    - Allow data collection in one environment and processing in another
    - Provide export commands for collected data
    - Add analysis commands that operate on exported data without requiring collection daemon

### Advanced Operational Standards (Priority 1)
23. **Structured Logging with Format Auto-Detection**
    - Implement structured logging (JSON or structured text) with format auto-detection based on TTY
    - Support Python-native env filters (e.g., `LOG_LEVEL`, `PYTHON_LOG`)
    - Implement log level resolution: env vars > CLI flags > config file > defaults
    - Add `--log-format` flag to choose between human and structured output

24. **Signal-Based Config Reload**
    - Support `SIGHUP` to reload config files without restart
    - Validate new config before applying
    - Log reload events with timestamps
    - Handle validation errors gracefully (keep old config active)
    - Add `--reload-config` command for manual config reload

25. **Health Check for Containers**
    - Provide health check mechanism (signal or HTTP endpoint) for container orchestration
    - Support Docker `HEALTHCHECK` and Kubernetes probes
    - Health check must validate operational state without side effects
    - Add `--health-check` command for manual health validation
    - Return appropriate exit codes for health status

26. **Privacy Mode with Anonymous Lists**
    - For CLIs that collect sensitive data, support privacy mode with explicit ignore lists
    - Distinguish between "unknown" (logged but not assigned) and "anonymous" (ignored entirely)
    - Add configurable privacy toggles to disable specific data collection
    - Implement `--privacy-mode` flag to enable privacy features
    - Add privacy settings to config file

27. **Audit Logging with Retention**
    - For CLIs that process significant data, provide optional append-only audit log (SQLite)
    - Implement configurable retention period
    - Auto-prune old data on startup
    - Support export commands for external analysis
    - Add `--audit-log` flag to enable audit logging
    - Add audit settings to config file

28. **Legacy Deprecation Policy**
    - Specify clear end-of-support date (minimum 6 months from announcement)
    - Log deprecation warnings to stderr during deprecation period
    - Remove legacy support only after specified date
    - Add deprecation tracking system for config format changes
    - Implement deprecation warnings in config validation

### Testing Requirements (Priority 1)
29. **Comprehensive Test Coverage**
    - Test help output for all commands and subcommands
    - Test globbing patterns including recursive `**/*`
    - Test stdin processing with `-` flag
    - Test config precedence (CLI args > env vars > local config > user config > defaults)
    - Test JSON vs human output modes
    - Test exit-code behavior for all error types
    - Test standard arguments (--help, --version, --usage)
    - Test config file initialization on first run
    - Test shell completion generation and installation
    - Test error handling and message formatting
    - Test daemon mode where feasible
    - Test color control (auto/always/never modes)
    - Test NO_COLOR environment variable handling
    - Test TTY detection for color mode
    - Test config file validation error messages
    - Test config file auto-migration
    - Test dry-run mode
    - Test confirmation prompts and --force flag
    - Test progress indicators and --quiet interaction
    - Test signal handling (SIGINT, SIGHUP)
    - Test file reference formatting (VSCode-compatible)
    - Test URL formatting
    - Test pager integration
    - Test terminal size awareness
    - Test credential/secret handling (no logging)
    - Test resource limits
    - Test collection vs processing separation
    - Test structured logging format auto-detection
    - Test log level resolution precedence
    - Test config reload via SIGHUP
    - Test health check mechanism
    - Test privacy mode with anonymous lists
    - Test audit logging with retention
    - Test legacy deprecation warnings

## Non-Functional Requirements
- **Performance:** CLI startup time must remain under 100ms for simple commands
- **Backward Compatibility:** All existing CLIs generated from current boilerplate must continue to work without modification
- **Security:** No credentials or secrets may be logged; secure storage must be used for sensitive data
- **Usability:** Error messages must be actionable and include suggestions for resolution
- **Maintainability:** Code must follow existing Python patterns in the boilerplate
- **Test Coverage:** Minimum 90% code coverage for all new functionality
- **Documentation:** All new features must be documented in the boilerplate README
- **Cross-Platform:** Must work on Linux, macOS, and Windows

## Technical Considerations
- **Dependencies:** Add required Python packages:
  - `textual` or `rich` for TUI mode (optional via template choice)
  - `keyring` for secure credential storage
  - `toml` for TOML config file parsing (already using Typer which includes this)
  - `pydantic` or `marshmallow` for config validation
  - `psutil` for resource monitoring and daemon management
  - `structlog` or `python-json-logger` for structured logging
  - `sqlite3` (built-in) for audit logging
  - `uvicorn` or similar for HTTP health check endpoint (optional)
- **Template Structure:** Update copier.yml to include new template choices:
  - `include_tui`: Boolean for TUI mode support
  - `include_daemon`: Boolean for daemon mode support
  - `include_advanced_config`: Boolean for advanced config features (migration, validation)
- **File Structure:** Add new template files:
  - `config.py.jinja` for config management module
  - `completion.py.jinja` for shell completion generation
  - `daemon.py.jinja` for daemon process management
  - `tui.py.jinja` for TUI mode (optional)
  - `man_page.py.jinja` for man page generation
  - `audit.py.jinja` for audit logging module
  - `health.py.jinja` for health check mechanism
  - `privacy.py.jinja` for privacy mode implementation
- **Backward Compatibility Strategy:**
  - Use feature flags in generated code to enable new features
  - Provide migration guide for updating existing generated CLIs
  - Ensure default behavior matches current implementation when new features are disabled
- **Testing Framework:** Continue using pytest with typer.testing.CliRunner
- **Config File Format:** Use TOML as primary format with this structure:
  ```toml
  [general]
  color = "auto"  # auto, always, never
  log_level = "info"  # debug, info, warn, error
  quiet = false
  
  [paths]
  config_dir = "~/.config/mytool"
  data_dir = "~/.local/share/mytool"
  
  [daemon]
  enabled = true
  max_jobs = 10
  
  [advanced]
  max_memory = "1G"
  max_cpu = 4
  ```

## Success Metrics
- **Compliance:** 100% of 35 CLI standards implemented and tested
- **Test Coverage:** Minimum 90% code coverage for new functionality
- **Backward Compatibility:** 0 breaking changes for existing generated CLIs
- **Performance:** CLI startup time under 100ms for simple commands
- **Documentation:** All new features documented in boilerplate README
- **Template Generation:** Successful generation of test CLI with all features enabled
- **Installation:** `--install` flag successfully sets up completions and config on all platforms
- **Operational:** Health checks, audit logging, and privacy mode working correctly

## Open Questions
- Should TUI mode be mandatory for all CLIs or optional via template choice? (Decision: Optional via template choice)
- What is the preferred library for TUI implementation: `textual` or `rich`? (Decision: Use `textual` for complex TUI, `rich` for simple prompts)
- Should daemon mode be enabled by default or require explicit opt-in? (Decision: Auto-spawn on first async operation, with --no-daemon to disable)
- How should we handle config file format changes in production? (Decision: Auto-migrate with backup, support both formats for one release cycle)
- Should audit logging be enabled by default or require explicit opt-in? (Decision: Disabled by default, opt-in via --audit-log flag)
- Should health check HTTP endpoint be included by default or optional? (Decision: Optional via template choice for containerized deployments)
- What structured logging library to use: `structlog` or `python-json-logger`? (Decision: Use `structlog` for flexibility and Python-native support)

## Dependencies
- **ADR Dependencies:** CLI Tool Standards ADR (adr-20260607001) must be accepted and stable
- **Template System:** Universal Shared Partials System (adr-20250131001) for sharing common CLI patterns
- **Python Packages:** Availability and stability of chosen dependencies (textual, keyring, psutil, etc.)
- **Testing:** pytest and typer.testing must support all required test scenarios
- **Documentation:** Technical writer availability for updating boilerplate documentation

## Timeline / Milestones
- **Week 1 (Days 1-5):** Core Standards Implementation
  - Day 1-2: Configuration management (initialization, validation, migration, reload)
  - Day 3: Install/uninstall functionality and shell completions
  - Day 4: Color control enhancement and error message formatting
  - Day 5: Signal handling enhancement and standard exit codes

- **Week 2 (Days 6-10):** Advanced Standards Implementation
  - Day 6-7: Daemon process support implementation
  - Day 8: TUI mode, dry-run, confirmation prompts, progress indicators
  - Day 9: Structured logging, health checks, privacy mode
  - Day 10: Audit logging, deprecation policy, remaining standards

- **Week 3 (Days 11-13):** Integration and Testing
  - Day 11: Man pages, pager integration, terminal awareness
  - Day 12: Comprehensive test coverage for all 35 standards
  - Day 13: Integration testing and documentation

- **Week 4 (Days 14-15):** Validation and Backward Compatibility
  - Day 14: Backward compatibility testing and migration guide
  - Day 15: Final testing, documentation review, and PRD completion

**Target Completion:** 15 working days (approximately 3 weeks)

---
*Generated from PRD template*

---
story_id: "03-002"
story_title: "Idempotent Operations"
story_name: "idempotent-ops"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260708-cli-go-aix/story-03-002-idempotent-ops"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["cli-commands", "business-logic"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli-commands", "axi"]
due: "2026-06-17"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement idempotent operations so that repeating commands doesn't cause errors when the desired state already exists. If an agent closes something already closed, acknowledge and move on with exit code 0. Reserve non-zero exit codes for situations where the agent's intent cannot be satisfied.

## Sub-Tasks

- [x] Identify all state-changing operations (create, update, delete, close, etc.)
- [x] Design idempotency strategy for each operation type
- [x] Implement state checking before applying changes
- [x] Add idempotent handling for create operations (skip if exists)
- [x] Add idempotent handling for update operations (skip if unchanged)
- [x] Add idempotent handling for delete operations (skip if already deleted)
- [x] Add idempotent handling for close operations (skip if already closed)
- [x] Implement success acknowledgment for no-op operations
- [x] Ensure exit code 0 for idempotent no-ops
- [x] Add descriptive messages for idempotent operations
- [x] Update all state-changing commands to be idempotent
- [x] Write unit tests for idempotent operation logic
- [x] Write integration tests for idempotent command behavior
- [x] Write tests for exit code behavior with idempotent operations
- [x] Update CLI help text to document idempotent behavior

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/idempotency/handler.go.jinja` — Idempotency logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/idempotency/handler_test.go.jinja` — Tests for idempotency (new file)
- `boilerplate/apps/cli/go/core/files/install.go.jinja` — Update install operations (install completions, init config)
- `boilerplate/apps/cli/go/core/files/daemon.go.jinja` — Update daemon operations (start/stop)
- `boilerplate/apps/cli/go/core/files/config.go.jinja` — Update config operations (init, migrate)
- `boilerplate/apps/cli/go/core/files/audit.go.jinja` — Update audit operations (export)
- `boilerplate/apps/cli/go/core/files/install_test.go.jinja` — Update tests for idempotency
- `boilerplate/apps/cli/go/core/files/daemon_test.go.jinja` — Update tests for idempotency
- `boilerplate/apps/cli/go/core/files/config_test.go.jinja` — Update tests for idempotency

## Acceptance Criteria

- [x] All state-changing operations are idempotent
- [x] State checking happens before applying changes
- [x] No-op operations return exit code 0
- [x] No-op operations provide descriptive acknowledgment messages
- [x] Idempotent handling works for all operation types
- [x] Exit code 0 is reserved for successful no-ops
- [x] Non-zero exit codes are only for unresolvable situations
- [x] All idempotent functionality has test coverage
- [x] Help text documents idempotent behavior

## Test Plan

- Unit: `go test ./internal/idempotency/...`
- Integration: Test idempotent behavior for all state-changing commands
- Manual: Verify idempotent operations with various scenarios

## Observability

- Add logging for idempotent operation detection at debug level
- Add metrics for idempotent operation frequency

## Compliance

- Ensure idempotent operations don't bypass security controls
- Validate that no-op acknowledgments don't leak sensitive information

## Risks & Mitigations

- Risk: Idempotency may hide actual errors — Mitigation: Clear distinction between no-op and error states
- Risk: State checking may impact performance — Mitigation: Optimize state queries, add caching where appropriate

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- No other dependencies (can be developed in parallel with 03-001, 03-003)

## Notes

- Idempotency should be consistent across all state-changing operations
- Document which operations are idempotent and their behavior
- Consider adding idempotency to CI/CD validation tests

## Identified State-Changing Operations

From analysis of the Go CLI boilerplate:

1. **Install Operations** (`install.go.jinja`):
   - Install shell completions to shell config files
   - Initialize config file if not exists
   - Create necessary directories

2. **Uninstall Operations** (`install.go.jinja`):
   - Remove shell completions from shell config files
   - Remove config files
   - Remove created directories

3. **Daemon Operations** (`daemon.go.jinja`):
   - Start daemon in background
   - Stop daemon
   - List background jobs
   - Cancel background jobs

4. **Config Operations** (`config.go.jinja`):
   - Initialize config file (InitConfigIfNeeded)
   - Migrate legacy config format
   - Reload config on SIGHUP

5. **Audit Operations** (`audit.go.jinja`):
   - Export audit log to file
   - Initialize audit database

## Idempotency Strategy Design

### Core Principles

1. **Check Before Act**: Always verify current state before attempting changes
2. **No-Op Success**: If desired state already exists, return success (exit code 0) with acknowledgment
3. **Descriptive Messages**: Clearly communicate when operation was skipped due to idempotency
4. **Error Distinction**: Only return non-zero exit codes for actual failures, not idempotent no-ops

### Operation-Specific Strategies

#### 1. Install Operations

**Install Shell Completions:**
- Check if completion script already exists in target shell config
- If exists: Skip with message "Completions already installed"
- If not exists: Install and confirm success

**Initialize Config File:**
- Check if config file exists at target path
- If exists: Skip with message "Config file already exists at {path}"
- If not exists: Create with defaults and confirm success

**Create Directories:**
- Check if directory exists
- If exists: Skip with message "Directory already exists: {path}"
- If not exists: Create and confirm success

#### 2. Uninstall Operations

**Remove Shell Completions:**
- Check if completion script exists in shell config
- If not exists: Skip with message "Completions not installed, nothing to remove"
- If exists: Remove and confirm success

**Remove Config Files:**
- Check if config file exists
- If not exists: Skip with message "Config file not found, nothing to remove"
- If exists: Remove and confirm success

**Remove Directories:**
- Check if directory exists
- If not exists: Skip with message "Directory not found: {path}"
- If exists: Remove and confirm success

#### 3. Daemon Operations

**Start Daemon:**
- Check if daemon is already running (pid file check, process check)
- If running: Skip with message "Daemon already running (PID: {pid})"
- If not running: Start and confirm success

**Stop Daemon:**
- Check if daemon is running
- If not running: Skip with message "Daemon not running, nothing to stop"
- If running: Stop and confirm success

**Cancel Job:**
- Check if job exists and is running
- If not found or already completed: Skip with message "Job {id} not found or already completed"
- If running: Cancel and confirm success

#### 4. Config Operations

**Initialize Config (InitConfigIfNeeded):**
- Check if config file exists
- If exists: Skip with message "Config file already exists"
- If not exists: Create with defaults and confirm success

**Migrate Legacy Config:**
- Check if config is in legacy format
- If already migrated: Skip with message "Config already in current format"
- If legacy: Migrate and confirm success

**Reload Config:**
- Check if config file changed since last load
- If unchanged: Skip with message "Config unchanged, reload not needed"
- If changed: Reload and confirm success

#### 5. Audit Operations

**Export Audit Log:**
- Check if output file already exists and has same content
- If exists and identical: Skip with message "Audit export already exists at {path}"
- If not exists or different: Export and confirm success

**Initialize Audit Database:**
- Check if audit database exists
- If exists: Skip with message "Audit database already initialized"
- If not exists: Initialize and confirm success

### Implementation Pattern

```go
// Generic idempotent operation pattern
func IdempotentOperation[T any](
    ctx context.Context,
    checkState func() (T, error),
    isDesiredState func(T) bool,
    applyChange func() error,
    skipMessage func(T) string,
    successMessage func() string,
) error {
    // Check current state
    state, err := checkState()
    if err != nil {
        return WrapError(err, ErrorTypeExecution, "Failed to check state", "Check permissions and system state")
    }

    // If already in desired state, skip with success
    if isDesiredState(state) {
        logger.Info(skipMessage(state))
        return nil // Exit code 0
    }

    // Apply change
    if err := applyChange(); err != nil {
        return WrapError(err, ErrorTypeExecution, "Failed to apply change", "Check permissions and system state")
    }

    logger.Info(successMessage())
    return nil // Exit code 0
}
```

### State Checking Functions

Each operation type will have specific state checking functions:

- `CheckCompletionsInstalled(shell string) (bool, error)`
- `CheckConfigExists(path string) (bool, error)`
- `CheckDirectoryExists(path string) (bool, error)`
- `CheckDaemonRunning() (bool, int, error)` // returns running status and PID
- `CheckJobExists(jobID string) (bool, error)`
- `CheckConfigFormat(path string) (string, error)` // returns "legacy" or "current"
- `CheckAuditDatabaseExists() (bool, error)`

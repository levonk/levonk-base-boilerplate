---
story_id: "01-002"
story_title: "Standard Exit Codes"
story_name: "standard-exit-codes"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 1
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-01-002-standard-exit-codes"
status: "done"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["index.ts", "error handling"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "error-handling"]
due: "2026-07-14"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement specific exit codes for different error types as defined in CLI Tool Standards ADR requirement #8. This includes standard exit codes for success (0), generic error (1), usage error (2), network error (3), validation error (4), file not found (5), permission denied (6), and SIGINT (130, already implemented).

## Sub-Tasks

- [x] Create error types module with specific error classes for each error type
- [x] Define exit code constants for each error type
- [x] Implement error handler that maps error types to exit codes
- [x] Update index.ts to use new error handling system
- [x] Add network error class with exit code 3
- [x] Add validation error class with exit code 4
- [x] Add file not found error class with exit code 5
- [x] Add permission denied error class with exit code 6
- [x] Ensure SIGINT handler continues to use exit code 130
- [x] Update error messages to include exit code information
- [x] Add unit tests for each error type and exit code mapping
- [x] Add integration tests for exit code behavior
- [x] Update help text to document exit code meanings

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI entry point with error handling
- `apps/cli/typescript/core/files/src/error.ts.jinja` - Error types module with exit code definitions
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for exit codes
- `apps/cli/typescript/core/files/src/error.test.ts.jinja` - Unit tests for error types

## Acceptance Criteria

- [x] Exit code 0 for successful execution
- [x] Exit code 1 for generic errors
- [x] Exit code 2 for usage errors (invalid arguments, missing required args)
- [x] Exit code 3 for network errors (connection failures, timeouts)
- [x] Exit code 4 for validation errors (invalid config, schema validation failures)
- [x] Exit code 5 for file not found errors
- [x] Exit code 6 for permission denied errors
- [x] Exit code 130 for SIGINT (Ctrl+C)
- [x] All error paths use appropriate exit codes
- [x] Error messages include helpful information about the error type

## Test Plan

- Unit: `vitest run src/error.test.ts` - Test error type to exit code mapping
- Integration: `vitest run src/index.test.ts` - Test exit codes for various error scenarios
- Manual: Test exit codes using `echo $?` after CLI execution

## Observability

- Log exit codes in debug mode for troubleshooting
- Include error type information in error messages

## Compliance

- Follows CLI Tool Standards ADR requirement #8 (Signals & Exit Codes)
- Aligns with standard Unix exit code conventions

## Risks & Mitigations

- Risk: Breaking existing scripts that expect specific exit codes
  - Mitigation: Document exit code changes clearly, provide migration guide
- Risk: Error classification ambiguity (which error type to use)
  - Mitigation: Provide clear guidelines for error type selection in code comments

## Dependencies

- None - this is a foundational story for Phase 1

## Notes

- SIGINT handler already exists with exit code 130, ensure it's not changed
- Consider using modern-errors library already in devDependencies for error handling
- Error types should be extensible for future error categories

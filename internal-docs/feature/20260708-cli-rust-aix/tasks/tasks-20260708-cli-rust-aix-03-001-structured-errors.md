---
story_id: "03-001"
story_title: "Structured Errors & Exit Codes"
story_name: "structured-errors"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260708-cli-rust-aix/story-03-001-structured-errors"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-002"]
parallel_safe: true
modules: ["error-handling", "output-formats"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "error-handling", "axi"]
due: "2026-06-17"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement structured error formatting with errors going to stdout in the same format as normal output, including actionable suggestions. Never let raw dependency output leak through. This enables agents to parse and act on failures programmatically.

## Sub-Tasks

- [x] Design structured error format specification
- [x] Implement error formatting function with structured output
- [x] Add actionable suggestion generation for common errors
- [x] Implement error validation before calling dependencies
- [x] Implement error translation to extract actionable meaning
- [x] Add error output channel separation (stdout for errors, stderr for diagnostics)
- [x] Update all error paths to use structured error format
- [x] Ensure raw dependency output never leaks through
- [x] Add suggestion references to CLI commands (not underlying tools)
- [x] Integrate structured errors into TOON output
- [x] Integrate structured errors into JSON output
- [x] Write unit tests for error formatting
- [x] Write unit tests for suggestion generation
- [x] Write integration tests for error output formatting
- [x] Write tests for error channel separation
- [x] Update CLI help text to document error format

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/internal/errors/formatter.rs` — Error formatting logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/errors/tests.rs` — Tests for error formatting (new file)
- `boilerplate/apps/cli/rust/core/src/internal/errors/suggestions.rs` — Suggestion generation logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/errors/suggestions_tests.rs` — Tests for suggestions (new file)
- `boilerplate/apps/cli/rust/core/src/internal/errors/validator.rs` — Error validation logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/errors/validator_tests.rs` — Tests for error validation (new file)
- `boilerplate/apps/cli/rust/core/src/internal/output/channels.rs` — Output channel separation (new file)
- `boilerplate/apps/cli/rust/core/src/cli/commands/*.rs` — Update error handling in all commands
- `boilerplate/apps/cli/rust/core/src/cli/commands/*_tests.rs` — Update error handling tests

## Acceptance Criteria

- [x] All errors are formatted in structured format
- [x] Error messages include actionable suggestions
- [x] Raw dependency output never leaks through
- [x] Error validation happens before calling dependencies
- [x] Error translation extracts actionable meaning
- [x] Suggestions reference CLI commands, not underlying tools
- [x] Errors go to stdout in structured format
- [x] Diagnostics go to stderr
- [x] Structured errors work for TOON output
- [x] Structured errors work for JSON output
- [x] All error functionality has test coverage
- [x] Help text documents error format

## Test Plan

- Unit: `cargo test --lib internal::errors`
- Unit: `cargo test --lib internal::output`
- Integration: Test error handling for all commands
- Manual: Verify error format with various error scenarios

## Observability

- Add logging for error formatting decisions at debug level
- Add metrics for error frequency and types

## Compliance

- Ensure error messages don't leak sensitive information
- Validate that error suggestions don't expose internal details

## Risks & Mitigations

- Risk: Error translation may lose important context — Mitigation: Preserve essential error information while removing noise
- Risk: Suggestion generation may not cover all error cases — Mitigation: Provide generic fallback suggestions

## Dependencies

- Requires: Mode selection (01-001) for context awareness
- Requires: TOON format (01-002) for error integration with TOON output
- No other dependencies (can be developed in parallel with 03-002, 03-003)

## Notes

- Error format should be consistent with the overall output format
- Consider adding error codes for programmatic error handling
- Document common error patterns and their suggestions

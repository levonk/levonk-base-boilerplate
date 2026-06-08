---
story_id: "03-001"
story_title: "Structured Errors & Exit Codes"
story_name: "structured-errors"
prd_name: "20260708-cli-go-aix"
prd_file: "internal-docs/feature/20260708-cli-go-aix/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260708-cli-go-aix/story-03-001-structured-errors"
status: "todo"
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

- [ ] Design structured error format specification
- [ ] Implement error formatting function with structured output
- [ ] Add actionable suggestion generation for common errors
- [ ] Implement error validation before calling dependencies
- [ ] Implement error translation to extract actionable meaning
- [ ] Add error output channel separation (stdout for errors, stderr for diagnostics)
- [ ] Update all error paths to use structured error format
- [ ] Ensure raw dependency output never leaks through
- [ ] Add suggestion references to CLI commands (not underlying tools)
- [ ] Integrate structured errors into TOON output
- [ ] Integrate structured errors into JSON output
- [ ] Write unit tests for error formatting
- [ ] Write unit tests for suggestion generation
- [ ] Write integration tests for error output formatting
- [ ] Write tests for error channel separation
- [ ] Update CLI help text to document error format

## Relevant Files

- `boilerplate/apps/cli/go/core/files/internal/errors/formatter.go` — Error formatting logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/errors/formatter_test.go` — Tests for error formatting (new file)
- `boilerplate/apps/cli/go/core/files/internal/errors/suggestions.go` — Suggestion generation logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/errors/suggestions_test.go` — Tests for suggestions (new file)
- `boilerplate/apps/cli/go/core/files/internal/errors/validator.go` — Error validation logic (new file)
- `boilerplate/apps/cli/go/core/files/internal/errors/validator_test.go` — Tests for error validation (new file)
- `boilerplate/apps/cli/go/core/files/internal/output/channels.go` — Output channel separation (new file)
- `boilerplate/apps/cli/go/core/files/cli/commands/*.go` — Update error handling in all commands
- `boilerplate/apps/cli/go/core/files/cli/commands/*_test.go` — Update error handling tests

## Acceptance Criteria

- [ ] All errors are formatted in structured format
- [ ] Error messages include actionable suggestions
- [ ] Raw dependency output never leaks through
- [ ] Error validation happens before calling dependencies
- [ ] Error translation extracts actionable meaning
- [ ] Suggestions reference CLI commands, not underlying tools
- [ ] Errors go to stdout in structured format
- [ ] Diagnostics go to stderr
- [ ] Structured errors work for TOON output
- [ ] Structured errors work for JSON output
- [ ] All error functionality has test coverage
- [ ] Help text documents error format

## Test Plan

- Unit: `go test ./internal/errors/...`
- Unit: `go test ./internal/output/...`
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

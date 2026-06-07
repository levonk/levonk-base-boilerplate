---
story_id: "08-001"
story_title: "Error Message Formatting"
story_name: "error-message-formatting"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 8
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-08-001-error-message-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002", "05-003"]
parallel_safe: true
modules: ["error handling"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-09-01"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement consistent, actionable error messages with suggestions using the format `ERROR: <description> - <suggestion>`. Apply this formatting to all error paths in the application. This implements CLI Tool Standards ADR requirement #14.

## Sub-Tasks

- [ ] Define error message format standard
- [ ] Implement error message formatter
- [ ] Add suggestion generation logic
- [ ] Update all error paths to use new format
- [ ] Add file references to error messages
- [ ] Add context information to error messages
- [ ] Implement error categorization
- [ ] Add unit tests for error formatting
- [ ] Add unit tests for suggestion generation
- [ ] Add integration tests for error messages
- [ ] Update help text to document error format
- [ ] Add error message documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/error.ts.jinja` - Error handling with formatting
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with error handling
- `apps/cli/typescript/core/files/src/error.test.ts.jinja` - Unit tests for error formatting
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for errors

## Acceptance Criteria

- [ ] All error messages follow format: `ERROR: <description> - <suggestion>`
- [ ] Error messages are actionable
- [ ] Error messages include helpful suggestions
- [ ] Error messages include file references where applicable
- [ ] Error messages include context information
- [ ] Error categorization works correctly
- [ ] Error format is consistent across all error paths
- [ ] Error messages are user-friendly

## Test Plan

- Unit: `vitest run src/error.test.ts` - Test error formatting
- Integration: `vitest run src/index.test.ts` - Test error messages in CLI
- Manual: Trigger various errors and verify format
- Manual: Verify suggestions are helpful

## Observability

- Error messages provide clear guidance
- Track error types for analytics
- Add metrics for error resolution success

## Compliance

- Follows CLI Tool Standards ADR requirement #14 (Error Message Formatting)
- Improves user experience with actionable error messages

## Risks & Mitigations

- Risk: Suggestions are not helpful
  - Mitigation: User testing, feedback collection, iterative improvement
- Risk: Error format is too rigid
  - Mitigation: Allow flexibility for complex errors, provide guidelines
- Risk: Error messages become too verbose
  - Mitigation: Keep suggestions concise, focus on most common issues

## Dependencies

- 01-002 (Standard Exit Codes) - Error handling system must be in place
- 05-003 (File Reference Formatting) - File references in errors

## Notes

- Use modern-errors library already in devDependencies for error handling
- Suggestions should be specific to the error type
- Consider adding error codes for reference
- Document common error patterns and suggestions

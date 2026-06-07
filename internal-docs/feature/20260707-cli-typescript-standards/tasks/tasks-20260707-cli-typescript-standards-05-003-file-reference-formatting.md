---
story_id: "05-003"
story_title: "File Reference Formatting"
story_name: "file-reference-formatting"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 5
parallel_id: 3
branch: "feature/current/20260707-cli-typescript-standards/story-05-003-file-reference-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["logger.ts", "error handling"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Format all file references with line numbers in VSCode-compatible format (`file:///absolute/path/to/file:line:column`) and support standard `file:line:column` format for terminal auto-linkification. Apply formatting to all error messages, log output, and user-facing file references. This implements CLI Tool Standards ADR requirement #15.

## Sub-Tasks

- [ ] Create file reference formatting utility module
- [ ] Implement VSCode-compatible file reference format
- [ ] Implement standard file:line:column format
- [ ] Add file reference formatting to error messages
- [ ] Add file reference formatting to log output
- [ ] Add file reference formatting to user-facing output
- [ ] Implement format selection based on environment
- [ ] Add unit tests for file reference formatting
- [ ] Add integration tests for file references in errors
- [ ] Update help text to document file reference format
- [ ] Add file reference format configuration option

## Relevant Files

- `apps/cli/typescript/core/files/src/file-ref.ts.jinja` - New file reference module (to be created)
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger with file reference formatting
- `apps/cli/typescript/core/files/src/error.ts.jinja` - Error handling with file references
- `apps/cli/typescript/core/files/src/file-ref.test.ts.jinja` - Unit tests for file references (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for file references

## Acceptance Criteria

- [ ] File references use VSCode-compatible format when appropriate
- [ ] File references use standard file:line:column format for terminals
- [ ] Error messages include formatted file references
- [ ] Log output includes formatted file references
- [ ] User-facing output includes formatted file references
- [ ] Format selection is automatic based on environment
- [ ] File references are clickable in supported terminals
- [ ] File references work with VSCode's file link protocol

## Test Plan

- Unit: `vitest run src/file-ref.test.ts` - Test file reference formatting
- Integration: `vitest run src/index.test.ts` - Test file references in output
- Manual: Verify file references are clickable in VSCode
- Manual: Verify file references work in terminal

## Observability

- File references improve debugging and navigation
- Log file reference format selection in debug mode
- Track file reference format usage

## Compliance

- Follows CLI Tool Standards ADR requirement #15 (File Reference Formatting)
- Improves developer experience with clickable file references

## Risks & Mitigations

- Risk: File reference format doesn't work on all systems
  - Mitigation: Provide fallback format, detect environment capabilities
- Risk: File references are too verbose
  - Mitigation: Use concise format where possible, provide configuration option
- Risk: File references break parsing tools
  - Mitigation: Make format configurable, document format clearly

## Dependencies

- 01-002 (Standard Exit Codes) - Error handling system must be in place

## Notes

- VSCode format: `file:///absolute/path/to/file:line:column`
- Standard format: `file:line:column` for terminal auto-linkification
- Consider environment detection for format selection
- File references should include absolute paths for reliability

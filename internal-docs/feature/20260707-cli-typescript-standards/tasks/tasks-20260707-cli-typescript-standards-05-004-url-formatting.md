---
story_id: "05-004"
story_title: "URL Formatting"
story_name: "url-formatting"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 5
parallel_id: 4
branch: "feature/current/20260707-cli-typescript-standards/story-05-004-url-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["utils/"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-08-11"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Ensure all URLs support copying to browser or smart terminal linking. Use standard HTTP/HTTPS URLs with proper encoding and make URLs clickable in terminal output where supported. This implements CLI Tool Standards ADR requirement #16.

## Sub-Tasks

- [ ] Create URL formatting utility module
- [ ] Implement URL validation and normalization
- [ ] Add proper URL encoding for special characters
- [ ] Implement terminal URL detection for clickable links
- [ ] Add URL formatting to error messages
- [ ] Add URL formatting to help text
- [ ] Add URL formatting to log output
- [ ] Implement OSC 8 escape sequences for terminal links
- [ ] Add fallback for terminals without URL support
- [ ] Add unit tests for URL formatting
- [ ] Add unit tests for URL encoding
- [ ] Add integration tests for URL display
- [ ] Update help text to document URL behavior

## Relevant Files

- `apps/cli/typescript/core/files/src/url.ts.jinja` - New URL formatting module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with URL integration
- `apps/cli/typescript/core/files/src/logger.ts.jinja` - Logger with URL formatting
- `apps/cli/typescript/core/files/src/url.test.ts.jinja` - Unit tests for URL formatting (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for URLs

## Acceptance Criteria

- [ ] URLs use standard HTTP/HTTPS format
- [ ] URLs are properly encoded for special characters
- [ ] URLs are clickable in supported terminals
- [ ] OSC 8 escape sequences are used for terminal links
- [ ] Fallback works for terminals without URL support
- [ ] URLs in error messages are formatted correctly
- [ ] URLs in help text are formatted correctly
- [ ] URLs in log output are formatted correctly
- [ ] URLs can be copied to browser

## Test Plan

- Unit: `vitest run src/url.test.ts` - Test URL formatting and encoding
- Integration: `vitest run src/index.test.ts` - Test URL display in output
- Manual: Verify URLs are clickable in terminal
- Manual: Test URL encoding for special characters

## Observability

- Log URL formatting mode in debug mode
- Track URL click-through for analytics
- Add metrics for URL formatting performance

## Compliance

- Follows CLI Tool Standards ADR requirement #16 (URL Formatting)
- Improves user experience with clickable URLs

## Risks & Mitigations

- Risk: OSC 8 escape sequences don't work on all terminals
  - Mitigation: Detect terminal capability, provide fallback
- Risk: URL encoding breaks existing URLs
  - Mitigation: Validate URLs before encoding, test thoroughly
- Risk: Clickable URLs interfere with output formatting
  - Mitigation: Use escape sequences properly, test on various terminals

## Dependencies

- None - this can be developed in parallel with other Phase 5 stories

## Notes

- OSC 8 escape sequence: `\x1b]8;;url\x1b\\text\x1b]8;;\x1b\\`
- Detect terminal capability for URL support
- Consider using terminal-link or similar library
- URLs should be validated before formatting

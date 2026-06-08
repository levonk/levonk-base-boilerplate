---
story_id: "03-004"
story_title: "URL Formatting"
story_name: "url-formatting"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 3
parallel_id: 4
branch: "feature/current/20260707-cli-go-standards/story-03-004-url-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "output"]
priority: "COULD"
risk_level: "low"
tags: ["feat", "output"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Ensure all URLs in CLI output are browser-compatible with standard HTTP/HTTPS URLs and proper encoding. Support smart terminal linking where available for clickable URLs.

## Sub-Tasks

- [x] Create URL formatting utility — `core/files/urls.go.jinja`
- [x] Implement URL validation — `core/files/urls.go.jinja`
- [x] Implement proper URL encoding — `core/files/urls.go.jinja`
- [x] Update all URL output to use formatter — `core/files/main.go.jinja`
- [x] Add smart terminal linking support — `core/files/urls.go.jinja`
- [x] Test URL formatting — `core/files/urls_test.go.jinja`
- [x] Test URL encoding — `core/files/urls_test.go.jinja`
- [x] Test terminal linking — `core/files/urls_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Update URL output
- `apps/cli/go/core/files/urls.go.jinja` — New file for URL formatting
- `apps/cli/go/core/files/urls_test.go.jinja` — New file for URL tests

## Acceptance Criteria

- [x] All URLs use standard HTTP/HTTPS format
- [x] URLs are properly encoded
- [x] URLs are clickable in supported terminals
- [x] Invalid URLs are handled gracefully
- [x] URL formatting is consistent across CLI

## Test Plan

- Unit: Test URL formatting functions
- Integration: Test URL display in actual output
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- URLs are formatted consistently
- Invalid URLs are logged

## Compliance

- Ensure URLs don't expose sensitive information
- Handle URL validation errors gracefully

## Risks & Mitigations

- Risk: URL encoding may break existing URLs — Mitigation: Test thoroughly
- Risk: Terminal linking may not work everywhere — Mitigation: Graceful fallback

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- URLs are formatted correctly
- URLs are clickable where supported
- All tests pass

## Commit Conventions

- `feat(output): add URL formatting`
- `feat(output): add terminal linking support`
- `test(output): add tests for URL formatting`

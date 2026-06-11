---
story_id: "03-004"
story_title: "URL Formatting"
story_name: "url-formatting"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 3
parallel_id: 4
branch: "feature/current/20260707-cli-python-standards/story-03-004-url-formatting"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "output"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-28"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Ensure all URLs are browser-compatible. Use standard HTTP/HTTPS URLs with proper encoding and support smart terminal linking where available.

## Sub-Tasks

- [x] Implement URL validation
- [x] Implement URL encoding
- [x] Ensure HTTP/HTTPS protocol
- [x] Add smart terminal linking
- [x] Add tests for URL formatting
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_main.py.jinja` - Main tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] All URLs are browser-compatible
- [ ] URLs use HTTP/HTTPS protocol
- [ ] URLs have proper encoding
- [ ] Smart terminal linking works where available
- [ ] Tests verify URL formatting

## Test Plan

- Unit: `pytest tests/test_main.py -v -k test_urls`
- Integration: `pytest tests/test_main.py -v -k test_url_formatting`
- Manual: Test URLs in terminal and browser

## Observability

- Log URL formatting issues

## Compliance

- Use secure HTTPS where possible
- Validate URLs before use

## Risks & Mitigations

- Risk: Terminal linking not supported — Mitigation: Graceful fallback
- Risk: URL encoding issues — Mitigation: Robust encoding library

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- URL formatting implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add URL formatting`

## Changelog

- 2025-07-08: initialized story file

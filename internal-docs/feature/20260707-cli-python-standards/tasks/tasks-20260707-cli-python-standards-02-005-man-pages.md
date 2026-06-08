---
story_id: "02-005"
story_title: "Man Pages"
story_name: "man-pages"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 5
branch: "feature/current/20260707-cli-python-standards/story-02-005-man-pages"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["docs", "main"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "docs"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Generate traditional Unix man pages accessible via `man {command}` or `--man` flag. Include all command documentation and use Python doc generation tools.

## Sub-Tasks

- [x] Add man page generation logic
- [x] Implement --man flag
- [x] Generate man pages for all commands
- [x] Install man pages to system location
- [x] Add tests for man page generation
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/man_page.py.jinja` - Man page module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_main.py.jinja` - Main tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Man pages generated for all commands
- [ ] `--man` flag displays man page
- [ ] Man pages accessible via `man` command
- [ ] Man pages include all command documentation
- [ ] Tests verify man page generation

## Test Plan

- Unit: `pytest tests/test_main.py -v -k test_man_page`
- Integration: `pytest tests/test_main.py -v -k test_man`
- Manual: Run `man <command>` and verify output

## Observability

- Log man page generation
- Log man page installation

## Compliance

- Follow man page format standards
- Include all necessary sections

## Risks & Mitigations

- Risk: Man page installation requires root — Mitigation: Graceful fallback
- Risk: Man page format varies by system — Mitigation: Use standard format

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Man pages implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(docs): add man page generation`

## Changelog

- 2025-07-08: initialized story file

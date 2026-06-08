---
story_id: "02-001"
story_title: "Dry-Run Mode"
story_name: "dry-run-mode"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 1
branch: "feature/current/20260707-cli-python-standards/story-02-001-dry-run-mode"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001", "01-006"]
parallel_safe: true
modules: ["main", "cmd"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement `--dry-run` flag to preview changes without executing them. Show exactly what would be done and apply to all file operations and destructive actions.

## Sub-Tasks

- [ ] Add --dry-run flag to CLI argument parser
- [ ] Implement dry-run mode in command execution
- [ ] Add preview output for operations
- [ ] Apply dry-run to all file operations
- [ ] Apply dry-run to destructive actions
- [ ] Add tests for dry-run mode
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_main.py.jinja` - Main tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] `--dry-run` flag previews changes without execution
- [ ] Preview shows exactly what would be done
- [ ] Dry-run applies to all file operations
- [ ] Dry-run applies to destructive actions
- [ ] No side effects in dry-run mode
- [ ] Tests verify dry-run behavior

## Test Plan

- Unit: `pytest tests/test_main.py -v -k test_dry_run`
- Integration: `pytest tests/test_main.py -v -k test_dry_run_mode`
- Manual: Run with --dry-run and verify no changes

## Observability

- Log dry-run mode activation
- Log previewed operations

## Compliance

- Ensure no side effects in dry-run mode
- Provide clear preview output

## Risks & Mitigations

- Risk: Dry-run misses some operations — Mitigation: Comprehensive testing
- Risk: Preview output too verbose — Mitigation: Configurable verbosity

## Dependencies & Sequencing

- Depends on: 01-001 (Config Initialization), 01-006 (Config Precedence Chain)
- Unblocks: None

## Definition of Done

- Dry-run mode implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add dry-run mode`

## Changelog

- 2025-07-08: initialized story file

---
story_id: "02-002"
story_title: "Confirmation Prompts"
story_name: "confirmation-prompts"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 2
parallel_id: 2
branch: "feature/current/20260707-cli-python-standards/story-02-002-confirmation-prompts"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["main", "prompt"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "ux"]
due: "2025-07-21"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Require confirmation for destructive operations (delete, overwrite). Implement `--force` flag to bypass prompts and use consistent prompt format across all operations.

## Sub-Tasks

- [ ] Add confirmation prompt logic
- [ ] Implement --force flag to bypass prompts
- [ ] Add consistent prompt format
- [ ] Apply prompts to destructive operations
- [ ] Add tests for confirmation prompts
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `tests/test_main.py.jinja` - Main tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Confirmation prompts for destructive operations
- [ ] `--force` flag bypasses prompts
- [ ] Consistent prompt format across operations
- [ ] Prompts show operation details
- [ ] Tests verify prompt behavior

## Test Plan

- Unit: `pytest tests/test_main.py -v -k test_confirmation`
- Integration: `pytest tests/test_main.py -v -k test_prompts`
- Manual: Test prompts with and without --force

## Observability

- Log confirmation prompts
- Log force flag usage

## Compliance

- Respect user choice in prompts
- Provide clear operation details

## Risks & Mitigations

- Risk: Prompts too frequent — Mitigation: Only for destructive operations
- Risk: --force flag overused — Mitigation: Clear documentation

## Dependencies & Sequencing

- Depends on: 01-001 (Config Initialization)
- Unblocks: None

## Definition of Done

- Confirmation prompts implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(ux): add confirmation prompts`

## Changelog

- 2025-07-08: initialized story file

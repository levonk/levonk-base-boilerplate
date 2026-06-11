---
story_id: "01-005"
story_title: "Shell Completion"
story_name: "shell-completion"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 5
branch: "feature/current/20260707-cli-python-standards/story-01-005-shell-completion"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "completion"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli"]
due: "2025-07-14"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement shell completion scripts for bash, zsh, and fish using Click's built-in completion generation capabilities. Auto-generate completions based on command structure and include them in `--install` flag output.

## Sub-Tasks

- [x] Enable Click completion in CLI
- [x] Implement completion script generation for bash
- [x] Implement completion script generation for zsh
- [x] Implement completion script generation for fish
- [x] Add completion installation instructions
- [x] Integrate with --install flag
- [x] Add tests for completion generation
- [x] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `apps/cli/python/core/files/{{project_slug}}/completion.py.jinja` - Completion module
- `tests/test_completion.py.jinja` - Completion tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] Completion scripts generated for bash, zsh, fish
- [ ] Completions auto-generated based on command structure
- [ ] Completion scripts included in --install output
- [ ] Installation instructions provided
- [ ] Completions work for all commands and flags
- [ ] Tests verify completion script generation

## Test Plan

- Unit: `pytest tests/test_completion.py -v -k test_generation`
- Integration: `pytest tests/test_main.py -v -k test_completion`
- Manual: Install completions and test tab completion

## Observability

- Log completion script generation
- Log completion installation status

## Compliance

- Use Click's built-in completion (secure and well-tested)
- Follow shell completion best practices

## Risks & Mitigations

- Risk: Click completion limitations — Mitigation: Extend with custom completions if needed
- Risk: Shell-specific syntax issues — Mitigation: Test on all supported shells

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Shell completion implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(cli): add shell completion`

## Changelog

- 2025-07-08: initialized story file

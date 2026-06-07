---
story_id: "04-001"
story_title: "Shell Completion and Man Pages"
story_name: "completion-manpages"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 4
parallel_id: 1
branch: "feature/current/cli-python-standards/story-04-001-completion-manpages"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["02-001"]
parallel_safe: true
modules: ["completion module", "man page module"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "documentation"]
due: "2026-07-22"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Enhance shell completion system and implement traditional Unix man pages. Ensure completions match current command structure and make man pages accessible via `man <command>` or `--man` flag.

## Sub-Tasks

- [ ] Enhance completion generation to handle all subcommands — `apps/cli/python/core/files/{{project_slug}}/completion.py.jinja`
- [ ] Ensure completions match current command structure — `completion.py.jinja`
- [ ] Create `man_page.py.jinja` template file with man page generation — `apps/cli/python/core/files/{{project_slug}}/man_page.py.jinja`
- [ ] Implement man page generation with standard sections (NAME, SYNOPSIS, DESCRIPTION, OPTIONS, EXAMPLES, SEE ALSO) — `man_page.py.jinja`
- [ ] Add `--man` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [ ] Integrate man page generation into install process — `completion.py.jinja`
- [ ] Add man page installation to platform-specific paths — `completion.py.jinja`
- [ ] Add tests for enhanced shell completions — `apps/cli/python/core/files/tests/test_completion.py.jinja`
- [ ] Add tests for man page generation — `tests/test_completion.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/completion.py.jinja` — Enhance completion generation
- `apps/cli/python/core/files/{{project_slug}}/man_page.py.jinja` — New man page module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add --man flag
- `apps/cli/python/core/files/tests/test_completion.py.jinja` — Add tests for completions and man pages

## Acceptance Criteria

- [ ] Shell completions handle all subcommands correctly
- [ ] Completions match current command structure
- [ ] Man pages generated with standard sections
- [ ] `--man` flag displays man page content
- [ ] Man pages install to correct platform-specific paths
- [ ] Man pages accessible via `man <command>` after install
- [ ] All tests pass for completions and man pages

## Test Plan

- Unit: `pytest tests/test_completion.py::test_subcommand_completion`
- Unit: `pytest tests/test_completion.py::test_man_page_generation`
- Unit: `pytest tests/test_completion.py::test_man_page_installation`
- Integration: Test completions with all subcommands
- Integration: Test man page installation on different platforms

## Observability

- Track completion usage patterns
- Log man page installation for debugging

## Compliance

- Man pages follow standard Unix format
- Completions respect user shell environment

## Risks & Mitigations

- Risk: Completions may become outdated as commands change — Mitigation: Auto-generate from command structure
- Risk: Man page paths vary across platforms — Mitigation: Use platformdirs for consistent path resolution

## Dependencies & Sequencing

- Depends on: 02-001 (Install/Uninstall Functionality)
- Unblocks: None (standalone documentation feature)

## Definition of Done

- Shell completions enhanced for all subcommands
- Man page generation implemented
- `--man` flag working
- Man pages install correctly
- Tests pass for completions and man pages
- Documentation updated for man page usage

## Commit Conventions

- `feat(completion): enhance shell completions for all subcommands`
- `feat(man): add man page generation`
- `feat(man): add --man flag to display man pages`
- `test(completion): add tests for enhanced completions and man pages`

---
story_id: "02-001"
story_title: "Install/Uninstall Functionality"
story_name: "install-uninstall"
prd_name: "cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd-20260707-cli-python-standards.md"
phase: 2
parallel_id: 1
branch: "feature/current/cli-python-standards/story-02-001-install-uninstall"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-001"]
parallel_safe: true
modules: ["completion module", "config module"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "install"]
due: "2026-07-17"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement `--install` and `--uninstall` flags that handle shell completion script generation, default config file initialization, and environment setup. This provides a complete installation experience for CLI users.

## Sub-Tasks

- [x] Create `completion.py.jinja` template file with completion generation functions — `apps/cli/python/core/files/{{project_slug}}/completion.py.jinja`
- [x] Implement bash completion generation using Typer's completion system — `completion.py.jinja`
- [x] Implement zsh completion generation using Typer's completion system — `completion.py.jinja`
- [x] Implement fish completion generation using Typer's completion system — `completion.py.jinja`
- [x] Add platform-specific completion installation paths — `completion.py.jinja`
- [x] Add `--install` flag to main command in `__main__.py.jinja` — `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja`
- [x] Add `--uninstall` flag to main command in `__main__.py.jinja` — `__main__.py.jinja`
- [x] Implement install logic: generate completions, initialize config, setup environment — `__main__.py.jinja`
- [x] Implement uninstall logic: remove completions, cleanup config, restore environment — `__main__.py.jinja`
- [x] Add tests for install/uninstall functionality — `apps/cli/python/core/files/tests/test_completion.py.jinja`

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/completion.py.jinja` — New completion module
- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` — Add install/uninstall flags and logic
- `apps/cli/python/core/files/{{project_slug}}/config.py.jinja` — Use for config initialization during install
- `apps/cli/python/core/files/tests/test_completion.py.jinja` — New test file for completion functionality

## Acceptance Criteria

- [x] `--install` flag generates shell completions for bash, zsh, and fish
- [x] `--install` flag initializes default config file
- [x] `--install` flag sets up required environment
- [x] `--uninstall` flag removes shell completions
- [x] `--uninstall` flag cleans up config files
- [x] `--uninstall` flag restores environment to pre-install state
- [x] Completion scripts work correctly for all three shells
- [x] Platform-specific installation paths handled correctly
- [x] All tests pass for install/uninstall scenarios

## Test Plan

- Unit: `pytest tests/test_completion.py::test_install`
- Unit: `pytest tests/test_completion.py::test_uninstall`
- Unit: `pytest tests/test_completion.py::test_bash_completion`
- Unit: `pytest tests/test_completion.py::test_zsh_completion`
- Unit: `pytest tests/test_completion.py::test_fish_completion`
- Integration: Test install/uninstall on different platforms

## Observability

- Log install/uninstall actions for debugging
- Track installation success/failure rates

## Compliance

- Shell completions respect user permissions
- Config initialization follows XDG standards
- Uninstall does not remove user data without confirmation

## Risks & Mitigations

- Risk: Shell completion paths vary across platforms — Mitigation: Use platformdirs for consistent path resolution
- Risk: Install may fail due to permissions — Mitigation: Provide clear error messages with sudo suggestions
- Risk: Uninstall may remove user customizations — Mitigation: Only remove files created by install, preserve user modifications

## Dependencies & Sequencing

- Depends on: 01-001 (Config Management System)
- Unblocks: 04-001 (Shell Completion and Man Pages)

## Definition of Done

- Install/uninstall flags implemented and working
- Shell completions generated for bash, zsh, and fish
- Config initialization integrated with install
- Platform-specific paths handled correctly
- Tests pass for all install/uninstall scenarios
- Documentation updated for install/uninstall usage

## Commit Conventions

- `feat(install): add --install flag with completion generation`
- `feat(install): add --uninstall flag with cleanup`
- `feat(completion): implement shell completion generation`
- `test(install): add tests for install/uninstall functionality`

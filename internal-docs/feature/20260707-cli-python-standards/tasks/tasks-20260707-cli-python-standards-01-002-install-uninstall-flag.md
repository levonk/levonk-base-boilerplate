---
story_id: "01-002"
story_title: "Install/Uninstall Flag"
story_name: "install-uninstall-flag"
prd_name: "20260707-cli-python-standards"
prd_file: "internal-docs/feature/20260707-cli-python-standards/prd.md"
phase: 1
parallel_id: 2
branch: "feature/current/20260707-cli-python-standards/story-01-002-install-uninstall-flag"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "install"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli"]
due: "2025-07-14"
created_at: "2025-07-08"
updated_at: "2025-07-08"
---
## Summary

Implement `--install` and `--uninstall` flags for the Python CLI to manage shell completions and configuration setup. The `--install` flag generates shell completion scripts for bash, zsh, and fish, initializes default config files, and provides installation instructions. The `--uninstall` flag performs cleanup.

## Sub-Tasks

- [ ] Add --install and --uninstall flags to CLI argument parser
- [ ] Implement shell completion generation for bash, zsh, fish
- [ ] Add completion script installation logic
- [ ] Implement config file initialization on install
- [ ] Add uninstall cleanup logic
- [ ] Add installation instructions output
- [ ] Add tests for install/uninstall functionality
- [ ] Update documentation

## Relevant Files

- `apps/cli/python/core/files/{{project_slug}}/__main__.py.jinja` - CLI entry point
- `apps/cli/python/core/files/{{project_slug}}/completion.py.jinja` - Completion module
- `tests/test_completion.py.jinja` - Completion tests
- `apps/cli/python/core/files/README.md.jinja` - User documentation

## Acceptance Criteria

- [ ] `--install` flag generates completion scripts for bash, zsh, fish
- [ ] `--install` initializes config file if advanced config enabled
- [ ] `--install` provides clear installation instructions
- [ ] `--uninstall` removes completion scripts
- [ ] `--uninstall` provides cleanup instructions
- [ ] Install/uninstall works across Linux, macOS, Windows
- [ ] Tests verify completion script generation and installation

## Test Plan

- Unit: `pytest tests/test_completion.py -v -k test_install`
- Integration: `pytest tests/test_main.py -v -k test_install_uninstall`
- Manual: Run `cli --install` and verify completions work

## Observability

- Log installation actions
- Log completion script paths
- Log any errors during install/uninstall

## Compliance

- Respect user shell configuration
- Use safe file operations
- Provide clear user feedback

## Risks & Mitigations

- Risk: Shell detection fails — Mitigation: Default to bash with warning
- Risk: Completion script paths vary by OS — Mitigation: Use platform-specific detection

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None

## Definition of Done

- Install/uninstall flags implemented and tested
- Documentation updated
- All tests passing
- Story marked as done in index

## Commit Conventions

- Use conventional commits: `feat(cli): add install/uninstall flags`

## Changelog

- 2025-07-08: initialized story file

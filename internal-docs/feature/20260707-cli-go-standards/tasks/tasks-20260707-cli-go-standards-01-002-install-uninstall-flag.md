---
story_id: "01-002"
story_title: "Install/Uninstall Flag"
story_name: "install-uninstall-flag"
prd_name: "20260707-cli-go-standards"
prd_file: "internal-docs/feature/20260707-cli-go-standards/prd.md"
phase: 1
parallel_id: 2
branch: "feature/current/20260707-cli-go-standards/story-01-002-install-uninstall-flag"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["main", "install"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "install"]
due: "2026-07-21"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Implement `--install` and `--uninstall` flags to automate CLI tool setup and cleanup. The install flag generates shell completion scripts for bash/zsh/fish, initializes default config files, and provides installation instructions. The uninstall flag removes these artifacts.

## Sub-Tasks

- [ ] Add --install and --uninstall flags to root command — `core/files/main.go.jinja`
- [ ] Create install command handler function — `core/files/install.go.jinja`
- [ ] Implement shell completion generation using cobra — `core/files/install.go.jinja`
- [ ] Add completion script installation logic — `core/files/install.go.jinja`
- [ ] Implement config file initialization in install — `core/files/install.go.jinja`
- [ ] Create uninstall command handler — `core/files/install.go.jinja`
- [ ] Add uninstall cleanup logic — `core/files/install.go.jinja`
- [ ] Generate installation instructions output — `core/files/install.go.jinja`
- [ ] Test install flag generates completions — `core/files/install_test.go.jinja`
- [ ] Test uninstall flag removes artifacts — `core/files/install_test.go.jinja`
- [ ] Test install idempotency — `core/files/install_test.go.jinja`

## Relevant Files

- `apps/cli/go/core/files/main.go.jinja` — Add install/uninstall flags
- `apps/cli/go/core/files/install.go.jinja` — New file for install/uninstall logic
- `apps/cli/go/core/files/install_test.go.jinja` — New file for install tests
- `apps/cli/go/core/files/completion.bash.jinja` — New template for bash completion
- `apps/cli/go/core/files/completion.zsh.jinja` — New template for zsh completion
- `apps/cli/go/core/files/completion.fish.jinja` — New template for fish completion

## Acceptance Criteria

- [ ] `--install` flag generates shell completion scripts for bash, zsh, and fish
- [ ] `--install` initializes default config files
- [ ] `--install` provides clear installation instructions
- [ ] `--uninstall` removes completion scripts and config files
- [ ] Install is idempotent (can run multiple times safely)
- [ ] Uninstall handles missing artifacts gracefully
- [ ] Completion scripts work with cobra's command structure

## Test Plan

- Unit: Test install/uninstall functions
- Integration: Test actual file creation and removal
- Lint: `go vet ./...`
- Types: N/A (Go is compiled)

## Observability

- Log installation steps
- Log uninstallation steps
- Log any errors during install/uninstall

## Compliance

- Respect user's home directory permissions
- Only remove files that were created by install
- Provide clear warnings before uninstall

## Risks & Mitigations

- Risk: Shell completion scripts may not work on all systems — Mitigation: Test on multiple platforms
- Risk: Uninstall may remove user-customized configs — Mitigation: Warn user and preserve custom configs

## Dependencies & Sequencing

- Depends on: None
- Unblocks: None (standalone feature)

## Definition of Done

- Install flag works for bash, zsh, and fish
- Uninstall flag cleans up properly
- All tests pass
- Clear user instructions provided

## Commit Conventions

- `feat(install): add --install and --uninstall flags`
- `feat(install): add shell completion generation`
- `test(install): add tests for install/uninstall functionality`

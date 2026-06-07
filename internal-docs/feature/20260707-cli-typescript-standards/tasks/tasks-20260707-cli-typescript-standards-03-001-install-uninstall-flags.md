---
story_id: "03-001"
story_title: "Install/Uninstall Flags"
story_name: "install-uninstall-flags"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 3
parallel_id: 1
branch: "feature/current/20260707-cli-typescript-standards/story-03-001-install-uninstall-flags"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-003"]
parallel_safe: true
modules: ["index.ts", "install/"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "cli", "installation"]
due: "2026-07-28"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Add `--install` and `--uninstall` flags to handle CLI installation tasks. The `--install` flag generates shell completion scripts, initializes default config files, and sets up any required environment. The `--uninstall` flag provides cleanup functionality. This implements CLI Tool Standards ADR requirement #4.

## Sub-Tasks

- [ ] Create install module with installation logic
- [ ] Add `--install` flag to index.ts
- [ ] Add `--uninstall` flag to index.ts
- [ ] Implement shell completion script generation (delegates to completion module)
- [ ] Implement default config file initialization
- [ ] Implement environment setup logic
- [ ] Add installation status tracking
- [ ] Implement uninstall cleanup logic
- [ ] Add user confirmation for destructive uninstall operations
- [ ] Add unit tests for install logic
- [ ] Add unit tests for uninstall logic
- [ ] Add integration tests for install/uninstall workflow
- [ ] Update help text to document install/uninstall flags
- [ ] Add logging for installation steps

## Relevant Files

- `apps/cli/typescript/core/files/src/install.ts.jinja` - New install module (to be created)
- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with install/uninstall flags
- `apps/cli/typescript/core/files/src/install.test.ts.jinja` - Unit tests for install module (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for install/uninstall

## Acceptance Criteria

- [ ] `--install` flag generates shell completion scripts
- [ ] `--install` flag initializes default config files
- [ ] `--install` flag sets up required environment
- [ ] `--uninstall` flag removes completion scripts
- [ ] `--uninstall` flag removes config files (with user confirmation)
- [ ] `--uninstall` flag cleans up environment changes
- [ ] Installation steps are logged to user
- [ ] Uninstall requires user confirmation for destructive operations
- [ ] Install/uninstall status is clearly communicated

## Test Plan

- Unit: `vitest run src/install.test.ts` - Test install/uninstall logic
- Integration: `vitest run src/index.test.ts` - Test install/uninstall workflow
- Manual: Run --install and verify completion scripts are generated
- Manual: Run --uninstall and verify cleanup

## Observability

- Log each installation step
- Track installation status in config file
- Add metrics for installation success/failure

## Compliance

- Follows CLI Tool Standards ADR requirement #4 (Install Flag)
- Provides clean installation and uninstallation experience

## Risks & Mitigations

- Risk: Install/uninstall may affect system-wide configuration
  - Mitigation: Require user confirmation, scope changes to user directory
- Risk: Incomplete uninstall leaves artifacts
  - Mitigation: Comprehensive cleanup logic, document what is removed
- Risk: Install fails partway through leaving inconsistent state
  - Mitigation: Transaction-like installation, rollback on failure

## Dependencies

- 01-003 (Config File Initialization) - Install needs config initialization logic

## Notes

- Install should be idempotent (safe to run multiple times)
- Uninstall should be conservative (require confirmation for destructive actions)
- Consider using a state file to track installation status
- Install output should guide users through next steps

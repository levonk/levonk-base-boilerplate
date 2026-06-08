---
story_id: "03-002"
story_title: "Shell Completion Scripts"
story_name: "shell-completion-scripts"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 3
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-03-002-shell-completion-scripts"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["completions/"]
priority: "MUST"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-07-28"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Generate shell completion scripts for bash, zsh, and fish using commander's built-in completion support. Ensure completions are maintained to match current command structure and add completion installation instructions. This implements CLI Tool Standards ADR requirement #17.

## Sub-Tasks

- [x] Create completions module for script generation
- [x] Implement bash completion script generation using commander
- [x] Implement zsh completion script generation using commander
- [x] Implement fish completion script generation using commander
- [x] Add completion script output directory logic
- [x] Add completion installation instructions
- [x] Add completion script validation
- [x] Add unit tests for bash completion generation
- [x] Add unit tests for zsh completion generation
- [x] Add unit tests for fish completion generation
- [x] Add integration tests for completion script installation
- [x] Update help text to include completion setup instructions
- [~] Add completion script version tracking

## Relevant Files

- `apps/cli/typescript/core/files/src/completions.ts.jinja` - Completions module with bash, zsh, and fish script generation
- `apps/cli/typescript/core/files/src/completions.test.ts.jinja` - Unit tests for completions (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for completions
- `apps/cli/typescript/core/files/completions/` - Directory for generated completion scripts (to be created)

## Acceptance Criteria

- [ ] Bash completion script is generated correctly
- [ ] Zsh completion script is generated correctly
- [ ] Fish completion script is generated correctly
- [ ] Completions match current command structure
- [ ] Completion scripts include all subcommands and options
- [ ] Completion installation instructions are clear
- [ ] Completion scripts are validated for syntax errors
- [ ] Completion scripts work with expected shell behavior

## Test Plan

- Unit: `vitest run src/completions.test.ts` - Test completion script generation
- Integration: `vitest run src/index.test.ts` - Test completion installation
- Manual: Source bash completion and test tab completion
- Manual: Source zsh completion and test tab completion
- Manual: Source fish completion and test tab completion

## Observability

- Log completion script generation in verbose mode
- Track completion script version in generated files
- Add metrics for completion script usage

## Compliance

- Follows CLI Tool Standards ADR requirement #17 (Shell Completion)
- Improves CLI discoverability and usability

## Risks & Mitigations

- Risk: Completion scripts become out of sync with command structure
  - Mitigation: Auto-generate from commander, add validation
- Risk: Completion scripts don't work on all shell versions
  - Mitigation: Test on multiple shell versions, document requirements
- Risk: Completion script installation is complex for users
  - Mitigation: Provide clear instructions, automate where possible

## Dependencies

- None - this can be developed in parallel with other Phase 3 stories

## Notes

- Commander has built-in completion support, leverage it
- Completion scripts should be generated at build time or runtime
- Consider using oclif or similar for more advanced completion features
- Completion scripts should handle dynamic command discovery

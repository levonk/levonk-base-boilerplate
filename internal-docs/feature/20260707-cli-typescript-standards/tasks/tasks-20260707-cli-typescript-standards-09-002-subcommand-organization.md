---
story_id: "09-002"
story_title: "Subcommand Organization"
story_name: "subcommand-organization"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 9
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-09-002-subcommand-organization"
status: "todo"
assignee: ""
reviewer: ""
dependencies: []
parallel_safe: true
modules: ["index.ts"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "cli", "ux"]
due: "2026-09-08"
created_at: "2026-07-07"
updated_at: "2026-07-07"
---

## Summary

Improve hierarchical command structure with consistent patterns. Group related commands under logical subcommands following CLI Tool Standards ADR requirement #20. This enhances CLI discoverability and usability.

## Sub-Tasks

- [ ] Review current command structure
- [ ] Design hierarchical command organization
- [ ] Group related commands under subcommands
- [ ] Implement consistent command patterns
- [ ] Add command aliases for common operations
- [ ] Improve command help text
- [ ] Add command examples in help
- [ ] Implement command discovery
- [ ] Add unit tests for command structure
- [ ] Add integration tests for subcommands
- [ ] Update help text to document command organization
- [ ] Add command structure documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with command structure
- `apps/cli/typescript/core/files/src/commands/` - Subcommand modules (to be created)
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for commands
- `apps/cli/typescript/core/files/src/commands.test.ts.jinja` - Unit tests for commands (to be created)

## Acceptance Criteria

- [ ] Commands are organized hierarchically
- [ ] Related commands are grouped under subcommands
- [ ] Command patterns are consistent
- [ ] Command aliases work correctly
- [ ] Help text is clear and consistent
- [ ] Command examples are helpful
- [ ] Command discovery works
- [ ] Command structure is documented

## Test Plan

- Unit: `vitest run src/commands.test.ts` - Test command structure
- Integration: `vitest run src/index.test.ts` - Test subcommand behavior
- Manual: Test command discovery and help
- Manual: Verify command organization is intuitive

## Observability

- Command organization improves discoverability
- Track command usage for analytics
- Add metrics for command help requests

## Compliance

- Follows CLI Tool Standards ADR requirement #20 (Subcommand Organization)
- Improves CLI usability and discoverability

## Risks & Mitigations

- Risk: Command reorganization breaks existing workflows
  - Mitigation: Maintain backward compatibility with aliases, document changes
- Risk: Command organization is not intuitive
  - Mitigation: User testing, feedback collection, iterative improvement
- Risk: Too many subcommand levels
  - Mitigation: Keep hierarchy shallow (2-3 levels max)

## Dependencies

- None - this can be developed in parallel with other Phase 9 stories

## Notes

- Use commander's subcommand support
- Consider user mental models when organizing
- Keep command names short and memorable
- Document command structure in help text

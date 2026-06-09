---
story_id: "09-002"
story_title: "Subcommand Organization"
story_name: "subcommand-organization"
prd_name: "20260707-cli-typescript-standards"
prd_file: "internal-docs/feature/20260707-cli-typescript-standards/prd.md"
phase: 9
parallel_id: 2
branch: "feature/current/20260707-cli-typescript-standards/story-09-002-subcommand-organization"
status: "done"
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

- [x] Review current command structure
- [x] Design hierarchical command organization
- [x] Group related commands under subcommands
- [x] Implement consistent command patterns
- [x] Add command aliases for common operations
- [x] Improve command help text
- [x] Add command examples in help
- [x] Implement command discovery
- [x] Add unit tests for command structure
- [x] Add integration tests for subcommands
- [x] Update help text to document command organization
- [x] Add command structure documentation

## Relevant Files

- `apps/cli/typescript/core/files/src/index.ts.jinja` - Main CLI with command structure
- `apps/cli/typescript/core/files/src/index.test.ts.jinja` - Integration tests for commands
- `apps/cli/typescript/core/files/docs/command-organization.md.jinja` - Command structure documentation

## Acceptance Criteria

- [x] Commands are organized hierarchically
- [x] Related commands are grouped under subcommands
- [x] Command patterns are consistent
- [x] Command aliases work correctly
- [x] Help text is clear and consistent
- [x] Command examples are helpful
- [x] Command discovery works
- [x] Command structure is documented

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

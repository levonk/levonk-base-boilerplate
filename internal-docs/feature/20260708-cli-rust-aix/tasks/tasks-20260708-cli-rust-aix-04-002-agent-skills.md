---
story_id: "04-002"
story_title: "Agent Skill Support"
story_name: "agent-skills"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260708-cli-rust-aix/story-04-002-agent-skills"
status: "done"
assignee: ""
reviewer: ""
dependencies: ["01-002"]
parallel_safe: true
modules: ["skill-generation", "documentation"]
priority: "SHOULD"
risk_level: "low"
tags: ["feat", "documentation", "axi"]
due: "2026-06-18"
created_at: "2026-06-08"
updated_at: "2026-06-08"
---

## Summary

Implement agent skill support for discoverability via agentskills.io. Generate `SKILL.md` from the same content as no-args home view. Add `--check-skill` build step to CI that fails if committed skill is stale. Strip live state from skill and rewrite command examples to non-interactive form.

## Sub-Tasks

- [x] Design SKILL.md template and structure
- [x] Implement `--generate-skill` command
- [x] Implement skill generation from CLI help and examples
- [x] Implement live state stripping logic
- [x] Rewrite command examples to non-interactive form (e.g., `cargo run -- ...`)
- [x] Add trigger-shaped frontmatter (name and description)
- [x] Implement `--check-skill` command for CI validation
- [x] Add skill generation to CI/CD pipeline
- [x] Document both hook and skill paths in README
- [x] Make clear user only needs one (hook or skill)
- [x] Write unit tests for skill generation logic
- [x] Write unit tests for live state stripping
- [x] Write integration tests for skill validation
- [x] Update CLI help text to document skill commands

## Relevant Files

- `boilerplate/apps/cli/rust/core/files/src/internal/skill/mod.rs.jinja` — Skill module (created)
- `boilerplate/apps/cli/rust/core/files/src/internal/skill/generator.rs.jinja` — Skill generation logic (created)
- `boilerplate/apps/cli/rust/core/files/src/internal/skill/stripper.rs.jinja` — Live state stripping logic (created)
- `boilerplate/apps/cli/rust/core/files/src/internal/skill/validator.rs.jinja` — Skill validation logic (created)
- `boilerplate/apps/cli/rust/core/files/src/cli/commands/skill.rs.jinja` — Skill commands (new file)
- `boilerplate/apps/cli/rust/core/files/src/cli/commands/skill_tests.rs.jinja` — Tests for skill commands (new file)
- `boilerplate/apps/cli/rust/core/files/.github/workflows/skill-check.yml.jinja` — CI workflow for skill validation (new file)
- `boilerplate/apps/cli/rust/core/files/README.md.jinja` — Update with skill documentation

## Acceptance Criteria

- [x] `--generate-skill` command outputs valid SKILL.md content
- [x] SKILL.md is generated from no-args home view content
- [x] Live state is stripped from generated skill
- [x] Command examples are rewritten to non-interactive form
- [x] SKILL.md includes trigger-shaped frontmatter
- [x] `--check-skill` command validates skill freshness
- [x] CI workflow fails if committed skill is stale
- [x] README documents both hook and skill paths
- [x] README clarifies user only needs one integration method
- [x] All skill functionality has test coverage
- [x] Help text documents skill commands

## Test Plan

- Unit: `cargo test --lib internal::skill`
- Integration: Test skill generation from CLI help
- Integration: Test skill validation with stale skill
- Manual: Verify generated SKILL.md format
- Manual: Test CI workflow with skill changes

## Observability

- Add logging for skill generation decisions at debug level
- Add metrics for skill generation frequency

## Compliance

- Ensure generated SKILL.md doesn't leak sensitive information
- Validate that skill generation doesn't expose internal implementation details

## Risks & Mitigations

- Risk: Skill generation may drift from actual CLI behavior — Mitigation: CI validation check
- Risk: Non-interactive command examples may not work in all environments — Mitigation: Provide multiple example formats

## Dependencies

- Requires: TOON format (01-002) for skill content formatting
- No other dependencies (can be developed in parallel with 04-001)

## Notes

- Skill generation should be automated to prevent drift
- Document skill format specification for consistency
- Consider adding skill generation to release process

---
story_id: "04-002"
story_title: "Agent Skill Support"
story_name: "agent-skills"
prd_name: "20260708-cli-rust-aix"
prd_file: "internal-docs/feature/20260708-cli-rust-aix/prd.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260708-cli-rust-aix/story-04-002-agent-skills"
status: "todo"
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

- [ ] Design SKILL.md template and structure
- [ ] Implement `--generate-skill` command
- [ ] Implement skill generation from CLI help and examples
- [ ] Implement live state stripping logic
- [ ] Rewrite command examples to non-interactive form (e.g., `cargo run -- ...`)
- [ ] Add trigger-shaped frontmatter (name and description)
- [ ] Implement `--check-skill` command for CI validation
- [ ] Add skill generation to CI/CD pipeline
- [ ] Document both hook and skill paths in README
- [ ] Make clear user only needs one (hook or skill)
- [ ] Write unit tests for skill generation logic
- [ ] Write unit tests for live state stripping
- [ ] Write integration tests for skill validation
- [ ] Update CLI help text to document skill commands

## Relevant Files

- `boilerplate/apps/cli/rust/core/src/internal/skill/generator.rs` — Skill generation logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/skill/tests.rs` — Tests for skill generation (new file)
- `boilerplate/apps/cli/rust/core/src/internal/skill/stripper.rs` — Live state stripping logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/skill/stripper_tests.rs` — Tests for state stripping (new file)
- `boilerplate/apps/cli/rust/core/src/internal/skill/validator.rs` — Skill validation logic (new file)
- `boilerplate/apps/cli/rust/core/src/internal/skill/validator_tests.rs` — Tests for skill validation (new file)
- `boilerplate/apps/cli/rust/core/src/cli/commands/skill.rs` — Skill commands (new file)
- `boilerplate/apps/cli/rust/core/src/cli/commands/skill_tests.rs` — Tests for skill commands (new file)
- `boilerplate/apps/cli/rust/core/.github/workflows/skill-check.yml` — CI workflow for skill validation (new file)
- `boilerplate/apps/cli/rust/core/README.md` — Update with skill documentation

## Acceptance Criteria

- [ ] `--generate-skill` command outputs valid SKILL.md content
- [ ] SKILL.md is generated from no-args home view content
- [ ] Live state is stripped from generated skill
- [ ] Command examples are rewritten to non-interactive form
- [ ] SKILL.md includes trigger-shaped frontmatter
- [ ] `--check-skill` command validates skill freshness
- [ ] CI workflow fails if committed skill is stale
- [ ] README documents both hook and skill paths
- [ ] README clarifies user only needs one integration method
- [ ] All skill functionality has test coverage
- [ ] Help text documents skill commands

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

---
story_id: "04-002"
story_title: "Installable Agent Skill"
story_name: "agent-skills"
prd_name: "20260708-cli-typescript-aix"
prd_file: "internal-docs/feature/20260708-cli-typescript-aix/prd.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260708-cli-typescript-aix/story-04-002-agent-skills"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["01-002", "04-001"]
parallel_safe: true
modules: ["skills", "docs"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "skills", "docs"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement installable agent skill support. Generate `SKILL.md` from same content as no-args home view, add `--check-skill` build step to CI, strip live state from skill, rewrite command examples to non-interactive form, and include trigger-shaped frontmatter.

## Sub-Tasks

- [ ] Implement skill template generator — `src/skills/generator.mts`
- [ ] Add `--generate-skill` command — `src/commands/generate-skill.mts`
- [ ] Implement live state stripping logic — `src/skills/state-stripper.mts`
- [ ] Implement command example rewriter — `src/skills/example-rewriter.mts`
- [ ] Add trigger-shaped frontmatter generation — `src/skills/frontmatter.mts`
- [ ] Add `--check-skill` CI script — `scripts/check-skill.mjs`
- [ ] Integrate skill check into CI pipeline — `.github/workflows/ci.yml`
- [ ] Add tests for skill generation — `tests/skills/generator.test.mts`
- [ ] Add tests for state stripping — `tests/skills/state-stripper.test.mts`
- [ ] Add tests for example rewriting — `tests/skills/example-rewriter.test.mts`

## Relevant Files

- `apps/cli/typescript/core/files/src/skills/generator.mts.jinja` — New file for skill generation
- `apps/cli/typescript/core/files/src/skills/state-stripper.mts.jinja` — New file for state stripping
- `apps/cli/typescript/core/files/src/skills/example-rewriter.mts.jinja` — New file for example rewriting
- `apps/cli/typescript/core/files/src/skills/frontmatter.mts.jinja` — New file for frontmatter generation
- `apps/cli/typescript/core/files/src/commands/generate-skill.mts.jinja` — New file for generate-skill command
- `apps/cli/typescript/core/files/scripts/check-skill.mjs.jinja` — New file for CI skill check
- `apps/cli/typescript/core/files/.github/workflows/ci.yml.jinja` — CI workflow (updated)
- `apps/cli/typescript/core/files/tests/skills/generator.test.mts.jinja` — New file for generator tests
- `apps/cli/typescript/core/files/tests/skills/state-stripper.test.mts.jinja` — New file for stripper tests
- `apps/cli/typescript/core/files/tests/skills/example-rewriter.test.mts.jinja` — New file for rewriter tests

## Acceptance Criteria

- [ ] `SKILL.md` generated from same content as no-args home view
- [ ] `--check-skill` build step fails if committed skill is stale
- [ ] Live state stripped from skill (static only, no dynamic data)
- [ ] Command examples rewritten to non-interactive form (e.g., `npx -y mytool ...`)
- [ ] Trigger-shaped frontmatter included (name and description)
- [ ] `--generate-skill` command outputs SKILL.md content
- [ ] Skill generation integrated into CI/CD pipeline
- [ ] Skill installation supported via agentskills.io
- [ ] Documentation updated for both hook and skill paths
- [ ] All tests pass

## Test Plan

- Unit: Test skill generation logic
- Unit: Test state stripping logic
- Unit: Test example rewriting logic
- Integration: Test `--generate-skill` command
- Integration: Test `--check-skill` CI script
- Integration: Test skill installation via agentskills.io
- Lint: `eslint . --ext .mts`
- Types: `tsc --noEmit`

## Observability

- Log skill generation events
- Log skill check results

## Compliance

- No regulatory constraints
- No sensitive data handling

## Risks & Mitigations

- Risk: Skill generation may not match no-args view — Mitigation: Use same source, sync automatically
- Risk: State stripping may remove too much — Mitigation: Careful logic, comprehensive tests
- Risk: Example rewriting may break examples — Mitigation: Preserve intent, only change invocation form

## Dependencies & Sequencing

- Depends on: 01-002 (TOON Format), 04-001 (Session Hooks)
- Unblocks: 05-001 (Content First)

## Definition of Done

- Skill generation implemented
- `--generate-skill` command implemented
- `--check-skill` CI script implemented
- State stripping implemented
- Example rewriting implemented
- Frontmatter generation implemented
- CI integration complete
- All tests pass
- Documentation updated

## Commit Conventions

- `feat(skills): implement skill template generator`
- `feat(skills): add --generate-skill command`
- `feat(skills): implement live state stripping`
- `feat(skills): implement command example rewriter`
- `feat(skills): add trigger-shaped frontmatter generation`
- `feat(ci): add --check-skill build step`
- `test(skills): add tests for skill generation`

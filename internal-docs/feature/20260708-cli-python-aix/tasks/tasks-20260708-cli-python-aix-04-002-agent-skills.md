---
story_id: "04-002"
story_title: "Installable Agent Skill"
story_name: "agent-skills"
prd_name: "20260708-cli-python-aix"
prd_file: "internal-docs/feature/20260708-cli-python-aix/prd.md"
phase: 4
parallel_id: 2
branch: "feature/current/20260708-cli-python-aix/story-04-002-agent-skills"
status: "todo"
assignee: ""
reviewer: ""
dependencies: ["04-001"]
parallel_safe: true
modules: ["skills.py", "skill_generator.py"]
priority: "MUST"
risk_level: "medium"
tags: ["feat", "skills", "agent"]
due: "2026-07-22"
created_at: "2026-07-08"
updated_at: "2026-07-08"
---

## Summary

Implement installable agent skill support. Generate `SKILL.md` from same content as no-args home view. Add `--check-skill` build step to CI. Strip live state from skill. Rewrite command examples to non-interactive form. Include trigger-shaped frontmatter.

## Sub-Tasks

- [x] Implement `--generate-skill` command — `cli/skills.py`
- [x] Generate SKILL.md from CLI help and examples — `skills/generator.py`
- [x] Use template-based generation — `skills/template.py`
- [x] Strip live state from skill (static only) — `skills/generator.py`
- [x] Rewrite command examples to non-interactive form — `skills/generator.py`
- [x] Include trigger-shaped frontmatter (name, description) — `skills/template.py`
- [x] Implement `--check-skill` command for CI — `cli/skills.py`
- [x] Fail if committed skill is stale — `skills/checker.py`
- [ ] Add to CI/CD pipeline for automatic skill updates — `.github/workflows/ci.yml`
- [ ] Support skill installation via agentskills.io — `skills/installer.py`
- [ ] Document both hook and skill paths in README — `docs/README.md`
- [x] Test skill generation — `tests/test_skills.py`
- [x] Test skill checking in CI — `tests/test_skills.py`
- [x] Test skill template rendering — `tests/test_skills.py`

## Relevant Files

- `apps/cli/python/core/files/cli/skills.py.jinja` — Skill commands
- `apps/cli/python/core/files/skills/generator.py.jinja` — Skill generator
- `apps/cli/python/core/files/skills/template.py.jinja` — Skill template
- `apps/cli/python/core/files/skills/checker.py.jinja` — Skill checker for CI
- `apps/cli/python/core/files/skills/installer.py.jinja` — Skill installer
- `apps/cli/python/core/files/.github/workflows/ci.yml.jinja` — CI workflow
- `apps/cli/python/core/files/docs/README.md.jinja` — Documentation
- `apps/cli/python/core/files/tests/test_skills.py.jinja` — Skill tests

## Acceptance Criteria

- [x] `--generate-skill` outputs SKILL.md content
- [x] SKILL.md generated from CLI help and examples
- [x] Live state stripped from skill
- [x] Command examples in non-interactive form
- [x] Trigger-shaped frontmatter included
- [x] `--check-skill` fails if skill is stale
- [ ] CI includes skill check step
- [ ] Skill installation via agentskills.io supported
- [ ] Both hook and skill paths documented
- [x] All tests pass

## Test Plan

- Unit: Test skill generation logic
- Unit: Test skill template rendering
- Unit: Test skill checking logic
- Integration: Test actual skill generation
- Integration: Test actual skill checking in CI
- Lint: `ruff check .` and `black --check .`
- Types: `mypy .`

## Observability

- Log skill generation events
- Log skill check events
- Track skill usage if telemetry added later

## Compliance

- No regulatory constraints
- No sensitive data in skill files

## Risks & Mitigations

- Risk: Skill template becomes outdated — Mitigation: CI check fails if stale
- Risk: Live state leaks into skill — Mitigation: Comprehensive stripping, test thoroughly
- Risk: Command examples not non-interactive — Mitigation: Rewrite logic, test examples

## Dependencies & Sequencing

- Depends on: 04-001 (Session Hooks)
- Unblocks: 05-001 (Content First)

## Definition of Done

- Skill generation implemented
- Skill checking in CI
- Skill template complete
- Documentation updated
- Comprehensive test coverage

## Commit Conventions

- `feat(skills): add --generate-skill command`
- `feat(skills): add --check-skill command for CI`
- `test(skills): add tests for skill generation`

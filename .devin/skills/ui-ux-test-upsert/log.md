# Directory Update Log

## 2026-08-08

* **Initialization**: Created the `ui-ux-test-upsert` skill to fill the gap
  in the testing skill ecosystem — `unit-test-writing` handles unit tests
  (Osherove style), `regression-test-mining` mines history for missing
  regression tests, `code-quality-validation` runs existing suites, but no
  skill created UI/UX tests or enforced the two-tier quality standard
  (requirements coverage + usability).
* **Design decision**: Named `ui-ux-test-upsert` (not `ui-ux-test-writing`)
  to mirror the `cicd-upsert` naming pattern — this skill creates and wires
  tests into CI, it does not just author test code. It is a peer to
  `unit-test-writing` in the test-writing ecosystem but with a broader
  scope: test creation + CI integration + quality gate enforcement.
* **Design decision**: Two-tier model — requirements coverage (deterministic,
  no API keys, always runs) and usability (AI-driven, BYOK, graceful skip
  when keys missing). This ensures the quality gate never blocks development
  due to missing LLM keys while still enforcing that all UI requirements are
  represented.
* **Tool selection**: agent-browser (web, MIT, CLI-first) + agent-device
  (mobile, MIT, CLI-first) for coverage; Stagehand (web, MIT, BYOK) +
  finalrun-agent (mobile, Apache-2.0, CLI-first, BYOK) for usability.
  AutoMobile (Apache-2.0, MCP-first) as alternative for mobile UX
  exploration. Selection criteria: CLI-first, open-source, free or BYOK,
  active maintenance.
* **Creation**: Authored [SKILL.md.tmpl](SKILL.md.tmpl) with frontmatter
  (`name`, `description` with "Do NOT trigger on" clause, `version`,
  `date`, `tags`, `see-also` pointing to `unit-test-writing` as sibling,
  `project-adopter` as dependent, `code-quality-validation` and
  `cicd-upsert` as complements, `project-detection` as dependency,
  `regression-test-mining` as related, and the `cicd-testing-practices`
  knowledge bundle as reference), `base-ai-wrapper` and `trigger-guard`
  includes, and the Refresh section.
* **Creation**: Authored [INSTRUCTIONS.md.tmpl](INSTRUCTIONS.md.tmpl) with
  the two-tier model explanation, tool selection matrix, Quick Start
  (8-step workflow), input modes, graceful missing-key handling, and a
  "What This Skill Does Not Do" section. Materializes the
  `cicd-testing-practices` knowledge bundle via `includeTree` for offline
  access.
* **Creation**: Materialized shared scripts via `.tmpl` includes:
  `scripts/refresh.sh.tmpl`, `scripts/cli-tool-discovery.sh.tmpl`,
  `scripts/scan-artifacts.sh.tmpl`, `scripts/resolve-reference.sh.tmpl`,
  and `references/nono-profile.json.tmpl`.
* **Creation**: Authored reference files:
  - [references/requirements-extraction.md](references/requirements-extraction.md)
    — how to parse PRDs, user stories, and acceptance criteria into
    structured UI requirements
  - [references/coverage-test-generation.md](references/coverage-test-generation.md)
    — how to map requirements to agent-browser/agent-device verification
    commands with test file templates
  - [references/usability-task-definition.md](references/usability-task-definition.md)
    — how to define natural-language user tasks without step-by-step
    instructions (good vs bad examples, anti-patterns)
  - [references/usability-test-generation.md](references/usability-test-generation.md)
    — how to produce Stagehand/finalrun-agent test specs from usability
    tasks with templates
  - [references/ci-integration.md](references/ci-integration.md) — CI
    pipeline wiring with graceful missing-key handling (key detection
    script, GitHub Actions workflows for web and mobile, pre-commit hooks)
  - [references/input-modes.md](references/input-modes.md) —
    from-requirements, from-existing-suite, and from-scratch workflows

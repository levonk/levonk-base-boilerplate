---
date:
  created: "2026-09-02"
  completed: ""
  last-activity: "2026-09-02"
---

# Add Dependabot config template to boilerplate Copier templates

**Date**: 2026-09-02
**Session**: Post-research on Dependabot's current capabilities. The boilerplate repo provides Copier templates for new projects but has no dependabot.yml template. New projects created from the boilerplate start without Dependabot, requiring manual setup.
**Status**: In progress — handoff created, awaiting execute-upsert execution.

## Current State

### Completed
- **Research complete** on Dependabot's `directories` key and composite action coverage.
- **Boilerplate structure analyzed** — Copier templates live in `repo/` and `apps/` and `_shared/` directories with `.jinja` extensions.

### Blocking Issues
1. **No dependabot.yml template exists** in the boilerplate — new projects start without automated dependency updates.
2. **Boilerplate's own `.github/dependabot.yml` is missing** — the boilerplate repo itself has 5 workflow files but no Dependabot config.

## Git State

**Commit at handoff**: `79db3acf968968306a43f44eeacaddeddf31c4de` (captured via `git rev-parse HEAD`)

**Note**: The working tree has uncommitted changes from a prior session (static-checks workflow, devbox partials, copier.yml). These should be committed before starting story work.

## Required Reading

Before any other action, read `/Users/micro/p/gh/levonk/levonk-base-boilerplate/AGENTS.md` — it is the root of this project's progressively-disclosed informational files. Follow its Usage Protocol and re-read the chain for any path you touch.

## Project Overview

### Objective

1. Add a `dependabot.yml.jinja` Copier template to the boilerplate so new projects get a modern Dependabot config out of the box.
2. Add `.github/dependabot.yml` to the boilerplate repo itself for dogfooding.
3. The template should use the `directories` (plural) key with wildcard support and cover both workflows and composite actions.

### Current Status

The boilerplate has workflow templates in multiple locations:
- `_shared/dot_github/workflows/` — shared workflow templates
- `repo/pnpm-monorepo/files/.github/workflows/` — pnpm monorepo workflows
- `apps/cli/rust/core/files/.github/workflows/` — Rust CLI app workflows
- `apps/cli/go/core/files/.github/workflows/` — Go CLI app workflows

No dependabot template exists in any of these locations.

## Key Decisions Made

### Template location

The dependabot.yml template should live in `_shared/dot_github/` (matching the existing `_shared/dot_github/workflows/` pattern) so all project types inherit it. The file name follows the Copier convention: `dependabot.yml.jinja`.

### Template content — modern `directories` key

The template should generate the modern config with:
- `directories` (plural) key for github-actions — NOT `directory` (singular)
- `/.github/actions/*` wildcard entry for composite action coverage
- `groups` config to batch updates into single PRs
- `assignees` configurable via Copier variable
- Ecosystem entries generated based on project type (detected via Copier conditionals)

### Copier variables

The template should use Copier conditionals to generate ecosystem entries based on the project type:
- `github-actions` — always (all projects have workflows)
- `cargo` — when Rust project
- `npm` — when Node/pnpm project
- `gomod` — when Go project
- `pip` or `uv` — when Python project

### `.github/workflows` vs `.github/actions` — two different things

- `.github/workflows/` = workflow files (triggers, jobs, steps)
- `.github/actions/` = composite actions (reusable step groups)
- They are NOT redundant. Dependabot's `directory: "/"` only scans workflows, NOT composite actions.
- The `directories` key with `/.github/actions/*` wildcard covers composite actions (GA since June 2024).

## Technical Context

### Stack/Tools
- Copier templates (Jinja2 syntax with `{% %}` and `{{ }}`)
- The boilerplate uses `_shared/` for cross-project-type templates
- `partials/` directories contain reusable Jinja2 partials

### Important Files
- `_shared/dot_github/workflows/` — existing shared workflow templates (pattern to follow)
- `repo/pnpm-monorepo/copier.yml` — Copier config for pnpm monorepo (may need new variables for dependabot settings)
- `apps/cli/rust/core/files/.github/workflows/` — Rust CLI workflow templates
- `.github/dependabot.yml` — CREATE for dogfooding
- `.github/workflows/ci.yml` — existing CI workflow
- `.github/workflows/lint.yml` — existing lint workflow
- `.github/workflows/release.yml` — existing release workflow
- `.github/workflows/pre-release.yml` — existing pre-release workflow
- `.github/workflows/update-models-md.yml` — existing model update workflow

### Environment Notes
- The boilerplate repo uses devbox — run commands through `devbox run --`
- Copier templates use Jinja2 syntax
- Test templates by running `copier copy` against a temp directory

## Next Steps (Priority Order)

1. Commit pending working tree changes (static-checks workflow, devbox partials, copier.yml).
2. Create `_shared/dot_github/dependabot.yml.jinja` template with Copier conditionals for ecosystem selection.
3. Add Copier variables for dependabot settings (assignees, schedule interval) to relevant `copier.yml` files.
4. Create `.github/dependabot.yml` for the boilerplate repo itself (dogfooding).
5. Update `AGENTS.md` if it documents the template structure.

## Task List

**Mark legend:**
- `[ ]` — task pending
- `[~]` — task in progress
- `[x]` — task done (verified complete)
- `[!]` — task blocked (note the blocker inline)

```markdown
- [ ] Commit pending working tree changes (static-checks workflow, devbox partials, copier.yml updates)
- [ ] Create _shared/dot_github/dependabot.yml.jinja template with directories key, composite action coverage, groups config, Copier conditionals for ecosystem selection
- [ ] Add Copier variables for dependabot settings (assignees, schedule_interval) to relevant copier.yml files
- [ ] Create .github/dependabot.yml for boilerplate repo itself (github-actions + cargo ecosystems, directories key, groups, assignees)
- [ ] Verify template renders correctly with copier copy against a temp directory
```

**Maintenance protocol (receiving session):**
1. Verify in-progress marks before starting.
2. Defer to execute-upsert for execution.
3. Mark done only when verified.
4. Record blockers inline.
5. Update the list as work reveals new tasks.

## Definition of Done

- [ ] **[manual]** `_shared/dot_github/dependabot.yml.jinja` exists and uses `directories` (plural) key
- [ ] **[manual]** Template includes `/.github/actions/*` for composite action coverage
- [ ] **[manual]** Template uses Copier conditionals to generate ecosystem entries based on project type
- [ ] **[manual]** Template includes `groups` config to batch updates
- [ ] **[manual]** `.github/dependabot.yml` exists in the boilerplate repo with `directories` key
- [ ] **[manual]** `copier copy` renders the template correctly (verified against a temp directory)
- [ ] **[manual]** Pending working tree changes committed before story work

**Not Done (common false-completion signals):**
- Template uses `directory` (singular) instead of `directories` (plural)
- Template doesn't include composite action coverage (`/.github/actions/*`)
- Template hardcodes ecosystems instead of using Copier conditionals
- Dogfooding config missing (boilerplate repo itself has no dependabot.yml)
- Template not tested with `copier copy`

## Execution Plan

Every task below is executed via the `execute-upsert` skill.

| Story slug | Type | Base SHA | DoD |
|------------|------|----------|-----|
| add-dependabot-template | standard | 79db3acf | Template created with directories key, Copier conditionals, dogfooding config added, renders correctly |

## Open Questions

1. Should the template always include `/.github/actions/*` or only when the project type uses composite actions? (Recommendation: always include it — if no composite actions exist, the wildcard matches nothing and Dependabot silently skips it. This is safer than conditionally including it.)
2. Should the schedule interval be a Copier variable or hardcoded to weekly? (Recommendation: Copier variable with default "weekly" — some projects may want daily or monthly.)

## Do Not

- Do not use `directory` (singular) in the template — always use `directories` (plural)
- Do not use `/**` — known Dependabot bug #13660 causes duplicate PRs
- Do not omit `groups` config — without it, every dependency update creates a separate PR
- Do not forget composite action coverage — `directory: "/"` does NOT scan `.github/actions/*`
- Do not hardcode all ecosystems — use Copier conditionals so the generated config matches the project type

## Suggested Skills

- `execute-upsert` — for executing the story with worktree-per-story discipline
- `code-review-guidance` — for reviewing the template changes

## Additional Context

### Research Sources

- [Dependabot multi-directory + wildcard support (June 2024)](https://github.blog/changelog/2024-06-25-simplified-dependabot-yml-configuration-with-multi-directory-key-directories-and-wildcard-glob-support/)
- [Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [dependabot-core#6345: Local actions in .github/actions/ are not checked](https://github.com/dependabot/dependabot-core/issues/6345)

### Related Handoffs

- **skills-src handoff**: `202609021249-add-dependabot-config-and-update-project-adopter.md` — adds dependabot.yml to skills-src and updates project-adopter skill
- **project-lint handoff**: `202609021249-dependabot-scanner-modernization.md` — extends dependabot scanner to warn on legacy directory key and missing composite action coverage

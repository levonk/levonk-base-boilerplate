---
date:
  created: "2026-09-02"
  completed: ""
  last-activity: "2026-09-02"
---

# Adopt apmw-core ecosystem mapping in boilerplate Copier templates

**Date**: 2026-09-02
**Session**: Post-research comparing project detection systems. apmw is extracting its detection engine into a reusable `apmw-core` crate. The boilerplate Copier templates currently hardcode ecosystem-to-manifest mappings in Jinja2 conditionals. This handoff covers referencing apmw-core's ecosystem mapping instead of duplicating it.
**Status**: In progress — handoff created, awaiting apmw-core publication. **Blocked on apmw-core being published to crates.io** (see [apmw handoff](https://github.com/levonk/apmw/blob/main/.agents/handoffs/todo/202609021309-extract-apmw-core-add-features-publish.md)).

## Current State

### Completed
- **Research complete** — apmw's ecosystem mapping (Node, Python, Rust, Go, Jvm, Swift, Dotnet, Flutter, Polyglot) with canonical managers is the most structured of any detection system.
- **apmw-core extraction planned** — handoff created in apmw repo to extract detect+ecosystem+version into a standalone crate and publish to crates.io.
- **Dependabot template handoff created** — `202609021249-add-dependabot-template-to-boilerplate.md` covers adding a dependabot.yml Copier template, but currently hardcodes the ecosystem mapping.

### Blocking Issues
1. **apmw-core is not yet published** — can't reference its ecosystem mapping until it's on crates.io.
2. **Boilerplate templates hardcode ecosystem mappings** — the dependabot template (planned) and potentially other templates each hardcode which manifest files map to which ecosystems.

## Git State

**Commit at handoff**: `091b90af041890abd4a935f73992454767bc6922` (captured via `git rev-parse HEAD`)

## Required Reading

Before any other action, read `/Users/micro/p/gh/levonk/levonk-base-boilerplate/AGENTS.md` — it is the root of this project's progressively-disclosed informational files. Follow its Usage Protocol and re-read the chain for any path you touch.

Also read the [apmw detection comparison](https://github.com/levonk/apmw/blob/main/internal-docs/research/202609021315-project-detection-comparison.md) for context.

## Project Overview

### Objective

Reference apmw-core's ecosystem mapping in boilerplate Copier templates instead of hardcoding manifest-to-ecosystem mappings in Jinja2 conditionals. This ensures the boilerplate stays in sync with apmw's detection logic as new ecosystems are added.

### Current Status

The boilerplate generates projects from Copier templates. Each template type (Rust, Go, Python, Node, etc.) generates different config files. The planned dependabot.yml template needs to know which ecosystems to generate entries for based on the project type — this is currently hardcoded as Jinja2 conditionals.

The boilerplate itself is not a Rust project — it's a Copier template repository. It can't depend on `apmw-core` as a Cargo dependency. Instead, it can:

1. **Reference apmw-core's ecosystem mapping as documentation** — the template's Jinja2 conditionals are informed by apmw-core's mapping, and a comment in the template links to the apmw-core source.
2. **Generate a data file from apmw-core** — a script runs `apmw detect --json` or reads apmw-core's ecosystem mapping and generates a YAML data file that the Copier template references.
3. **Keep the Jinja2 conditionals but document the source of truth** — the template hardcodes the mapping (as it must, since Copier templates can't call Rust crates), but a comment links to apmw-core's ecosystem module as the canonical source.

**Recommendation**: Option 3. Copier templates are static Jinja2 — they can't call Rust crates at template-render time. The Jinja2 conditionals must stay, but they should be documented as derived from apmw-core's ecosystem mapping, with a link to the source. When apmw-core adds a new ecosystem, the boilerplate template needs to be updated — but at least the source of truth is clear.

## Key Decisions Made

### Copier templates can't depend on Rust crates

Copier templates are Jinja2 files rendered by Python's Copier library. They can't call Rust crates at render time. The ecosystem mapping must be hardcoded in Jinja2 conditionals. What we CAN do:

1. Document that the mapping is derived from apmw-core's `ecosystem` module
2. Add a comment in the template linking to the apmw-core source
3. Add a test/script that verifies the boilerplate's mapping matches apmw-core's mapping (a drift detector)

### Drift detection script

Create a script (`scripts/check-ecosystem-drift.sh`) that:
1. Reads apmw-core's ecosystem mapping (from the published crate or from the apmw repo)
2. Reads the boilerplate's Jinja2 conditionals
3. Compares them and reports drift

This is the same pattern as `just check-submodule-drift` in skills-src — non-blocking warning that the mapping has diverged.

### What the boilerplate gets from apmw-core

| apmw-core feature | Boilerplate benefit |
|-------------------|-------------------|
| Ecosystem mapping (9 ecosystems) | Dependabot template generates correct ecosystem entries |
| Version info extraction | Template can include version constraints in generated config |
| Workspace detection | Template can generate workspace-aware config for monorepo templates |

### What stays in the boilerplate

- Jinja2 conditionals for ecosystem selection (can't call Rust from Copier)
- Copier variables for project type selection
- Template structure and file generation logic

## Technical Context

### Stack/Tools
- Copier templates (Jinja2 syntax)
- `_shared/` directory for cross-project-type templates
- `partials/` directories for reusable Jinja2 partials

### Important Files
- `_shared/dot_github/dependabot.yml.jinja` — CREATE (from dependabot handoff): the dependabot template with ecosystem conditionals
- `scripts/check-ecosystem-drift.sh` — CREATE: drift detection script
- `AGENTS.md` — UPDATE: document apmw-core as the ecosystem mapping source of truth

### Environment Notes
- The boilerplate repo uses devbox — run commands through `devbox run --`
- Copier templates use Jinja2 syntax
- Test templates by running `copier copy` against a temp directory

## Next Steps (Priority Order)

**BLOCKED on apmw-core publication.** The dependabot template (from the existing handoff) can be created first with hardcoded mappings, then updated to reference apmw-core once published.

1. Create the dependabot.yml.jinja template (from existing handoff `202609021249-add-dependabot-template-to-boilerplate.md`).
2. Add comments in the template linking to apmw-core's ecosystem module as the source of truth.
3. Create `scripts/check-ecosystem-drift.sh` to detect when the boilerplate's mapping diverges from apmw-core's.
4. Update `AGENTS.md` to document apmw-core as the ecosystem mapping source.

## Task List

**Mark legend:**
- `[ ]` — task pending
- `[~]` — task in progress
- `[x]` — task done (verified complete)
- `[!]` — task blocked (note the blocker inline)

```markdown
- [ ] Add comments in dependabot.yml.jinja linking to apmw-core's ecosystem module as the source of truth
- [!] Create scripts/check-ecosystem-drift.sh to detect mapping drift from apmw-core (blocked: apmw-core not yet published)
- [ ] Update AGENTS.md to document apmw-core as the ecosystem mapping source of truth
- [ ] Verify template renders correctly with copier copy against a temp directory
```

**Maintenance protocol (receiving session):**
1. Verify in-progress marks before starting.
2. The dependabot template can be created with hardcoded mappings first (from the existing handoff), then updated with apmw-core references.
3. The drift detection script is blocked on apmw-core publication.
4. Defer to execute-upsert for execution.
5. Mark done only when verified.

## Definition of Done

- [ ] **[manual]** `dependabot.yml.jinja` has comments linking to apmw-core's ecosystem module
- [ ] **[manual]** `scripts/check-ecosystem-drift.sh` exists and detects mapping drift
- [ ] **[manual]** `AGENTS.md` documents apmw-core as the ecosystem mapping source of truth
- [ ] **[manual]** `copier copy` renders the template correctly

**Not Done (common false-completion signals):**
- Template has apmw-core comments but the mapping doesn't actually match apmw-core's
- Drift detection script exists but doesn't actually compare against apmw-core's mapping
- AGENTS.md mentions apmw-core but doesn't explain the source-of-truth relationship

## Execution Plan

Every task below is executed via the `execute-upsert` skill. The template comments can be added immediately; the drift detection script is blocked on apmw-core publication.

| Story slug | Type | Base SHA | DoD | Blocked on |
|------------|------|----------|-----|------------|
| reference-apmw-core-in-templates | standard | 091b90a | Template has apmw-core comments, AGENTS.md updated | Nothing (can start now) |
| add-ecosystem-drift-detection | standard | (after above) | Drift detection script exists and works | apmw-core published |

## Open Questions

1. Should the drift detection script read apmw-core's mapping from the published crate (via `cargo doc --open` or similar) or from the apmw repo directly? (Recommendation: from the apmw repo — clone it and read `crates/apmw-core/src/ecosystem/mod.rs` directly. Simpler than extracting from a compiled crate.)
2. Should the drift detection be blocking (CI fails on drift) or non-blocking (warning only)? (Recommendation: non-blocking warning, same as `just check-submodule-drift` in skills-src.)

## Do Not

- Do not try to call apmw-core from Jinja2 templates — Copier templates can't call Rust crates
- Do not remove the Jinja2 ecosystem conditionals — they must stay (Copier is Python, not Rust)
- Do not make the boilerplate depend on apmw-core as a Cargo dependency — it's not a Rust project
- Do not start the drift detection script until apmw-core is published

## Suggested Skills

- `execute-upsert` — for executing each story with worktree-per-story discipline
- `code-review-guidance` — for reviewing the changes before merge

## Additional Context

### Related Handoffs

- **apmw handoff**: [202609021309-extract-apmw-core-add-features-publish.md](https://github.com/levonk/apmw/blob/main/.agents/handoffs/todo/202609021309-extract-apmw-core-add-features-publish.md) — MUST complete first for drift detection
- **apmw research**: [project-detection-comparison.md](https://github.com/levonk/apmw/blob/main/internal-docs/research/202609021315-project-detection-comparison.md) — why apmw-core was chosen
- **boilerplate dependabot handoff**: `202609021249-add-dependabot-template-to-boilerplate.md` — the dependabot template that should reference apmw-core
- **project-lint handoff**: `202609021636-adopt-apmw-core-as-detection-source.md` — project-lint adopts apmw-core as Rust dependency
- **skills-src handoff**: `202609021636-adopt-apmw-core-in-project-detection-skill.md` — the bash skill calls `apmw detect --json`

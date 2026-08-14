# Directory Update Log

## 2026-08-05

* **Initialization**: Created the `regression-test-mining` skill to fill the
  gap identified in the skills catalog — no existing skill mines git history
  for bug-fix commits to generate regression tests. `unit-test-writing`
  teaches *how* to write a good unit test (Osherove style) but not *what to
  test* from history; `code-quality-validation` runs existing suites but
  does not create new tests from history; `refactor-planning` identifies
  code smells, not bug-fix commits.
* **Design decision**: Standalone skill, not a phase inside
  `unit-test-writing`. The trigger ("mine history for missing tests") is
  distinct from `unit-test-writing`'s trigger ("write a test for this
  specific unit"). Bundling would muddy the Osherove-scoped contract and
  over-trigger. The new skill dispatches `unit-test-writing` as a
  dependency for authoring.
* **Creation**: Authored [SKILL.md.tmpl](SKILL.md.tmpl) with frontmatter
  (`name`, `description` with "Do NOT trigger on" clause, `version`,
  `date`, `tags`, `see-also` pointing to `unit-test-writing`,
  `git-repository-management`, `project-detection`,
  `code-quality-validation`, `refactor-planning`, and the
  `cicd-testing-practices` knowledge bundle), `base-ai-wrapper` and
  `trigger-guard` includes, and the Refresh section.
* **Creation**: Authored [INSTRUCTIONS.md.tmpl](INSTRUCTIONS.md.tmpl) with
  the 7-step mining pipeline (Mine → Classify → Inventory → Detect
  framework → Dispatch unit-test-writing → Verify → Report), input modes,
  and a "What This Skill Does Not Do" section.
* **Creation**: Authored the mining script
  [scripts/mine-bug-fixes.sh.tmpl](scripts/mine-bug-fixes.sh.tmpl) — the
  single AI→script handoff for history mining. Collects conventional `fix:`
  commits, `Fixes #N` / `Closes #N` / `Resolves #N` trailers, reverts, and
  supports `--blame`, `--bisect <sha>`, `--from-file <path>`, `--since`,
  `--max-count`, and `--json` output. Uses the shared `wrapper-helpers.sh`
  and `rtk-helpers.sh` includes for devbox/rtk wrapping.
* **Creation**: Materialized shared scripts via `.tmpl` includes:
  `scripts/refresh.sh.tmpl`, `scripts/cli-tool-discovery.sh.tmpl`,
  `scripts/scan-artifacts.sh.tmpl`, and
  `references/nono-profile.json.tmpl`.
* **Creation**: Authored reference files:
  - [references/commit-classification.md](references/commit-classification.md)
    — the COVERED / GAP / UNREPRODUCIBLE / COSMETIC decision tree
  - [references/framework-detection.md](references/framework-detection.md)
    — the test framework detection matrix and per-framework conventions
  - [references/sha-referencing.md](references/sha-referencing.md) — how to
    reference the fix commit SHA in each test framework
  - [references/blame-mining.md](references/blame-mining.md) — when and how
    to use `git blame` to find bug-introducing commits (slow, opt-in)
  - [references/input-modes.md](references/input-modes.md) — full-history,
    single-commit, and commit-list input modes

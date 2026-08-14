# Directory Update Log

## 2026-08-01

* **Bundled dependency**: Added `code-quality-validation` skill as a bundled
  dependency via `includeTreeForCache` so the reviewer can run the automated
  validation pipeline (lint, format, test, security) before the manual
  checklist. Updated `see-also` relationship from `related` to
  `bundled-dependency`.
* **Automated Validation Pass**: Added a new section and Quick Start step
  instructing the reviewer to run the bundled `quality-validator.sh` pipeline.
  Updated the Review Process Workflow to include an explicit "Automated
  validation pass" step (step 3) before the checklist pass. Updated the
  Automated Review Workflow to run the validation pass before the manual
  checklist.
* **Reviewer Personas**: Incorporated the four review personas (Security
  Sentinel, Architectural Guardian, Performance Profiler, Maintainability
  Mentor) from the retired `software-dev/quality/ai-quality-embedded-agents.md`
  design doc. Each persona maps to a checklist category and a deterministic
  counterpart in the `code-quality-validation` pipeline.
* **Scripts**: Added `scripts/resolve-reference.sh.tmpl` for the three-tier
  fallback resolver (needed because the skill now bundles another skill via
  `includeTree`).
* **Version**: Bumped from 1.3.0 to 1.4.0.

## 2026-07-18

* **Initialization**: Created the `code-review-guidance` skill from the
  `rules/software-dev/general/code-review.md` rule. Expanded the 42-line
  checklist into a structured skill with categories (infrastructure, schemas,
  integrations, security, performance, accessibility, cross-cutting concerns)
  and a review process workflow.
* **Creation**: Authored [SKILL.md.tmpl](SKILL.md.tmpl) with frontmatter,
  base-ai-guidance include, quick start, review checklist, and review process
  workflow.
* **Creation**: Authored [references/review-checklist.md](references/review-checklist.md)
  — expanded checklist with examples and edge cases per category.

# Converting an Existing Skill to a Workflow

When the user provides an existing skill directory and wants it turned back into a workflow, use this path instead of creating from scratch. The goal is to preserve the skill's git history while transforming it into a workflow. This is the reverse of `ai-upsert`'s Mode B (Convert Workflow to a Skill).

## Table of Contents

1. [When Conversion Is Appropriate](#when-conversion-is-appropriate)
2. [Frontmatter Requirement — Switch Back to Workflow Schema](#frontmatter-requirement--switch-back-to-workflow-schema)
3. [Process — Preserve History, Separate the Rename from Optimizations](#process--preserve-history-separate-the-rename-from-optimizations)
4. [Why Separate Commits](#why-separate-commits)

## When Conversion Is Appropriate

Conversion is appropriate when the skill no longer needs the resources that workflows cannot bundle:

- **No `scripts/`** — the skill's scripts are either unused, or their functionality can be inlined as prose steps in the content template.
- **No `references/`** — the skill's reference material is small enough to live in the content template directly, or is no longer needed.
- **No `evals/`** — the skill's evals are no longer needed (workflows don't have a description-triggering surface to eval).
- **No `assets/`** — the skill has no bundled assets.

If the skill relies on any of these, conversion loses functionality. **Warn the user** and suggest keeping it as a skill instead. Conversion is irreversible in the sense that the bundled resources would need to be recreated if the workflow is later converted back to a skill.

## Frontmatter Requirement — Switch Back to Workflow Schema

Skills use `name`, `description`, `triggers`, `version` frontmatter. Workflows use `workflow`, `slug`, `description`, `use`, `role`, `date`, `tags`, `see-also`. The conversion must:

- **Add**: `workflow` (display name), `slug` (kebab-case id), `use` (when to invoke)
- **Remove**: `name`, `triggers`, `version` (skill-only fields)
- **Keep**: `description` (may need rewording — workflows use `use` for the trigger surface, `description` for the summary), `date`, `tags`, `see-also`
- **Remove includes**: `trigger-guard.md.tmpl` (skill-specific), `base-ai-guidance.md.tmpl` (skill-specific — workflows use `base-workflow-guidance.md.tmpl` instead)
- **Add include**: `base-workflow-guidance.md.tmpl` (bundles the workflow-specific framework)

## Process — Preserve History, Separate the Rename from Optimizations

1. **Verify conversion is appropriate** — check that the skill does not rely on `scripts/`, `references/`, `evals/`, or `assets/` that workflows cannot bundle. If it does, warn the user and stop.
2. **Create the wrapper location** at `config/ai/workflows/<category>/<name>.md.tmpl` — use `mkdir -p` on the parent directory, but do NOT create the file yet (the `git mv` in step 3 will place it).
3. **`git mv` the skill's `SKILL.md` to the wrapper path** (renaming to `<name>.md.tmpl`). This preserves the skill's git history so `git log --follow <name>.md.tmpl` traces back through the original skill.
   ```bash
   git mv <skill-dir>/SKILL.md <workflow-dir>/<name>.md.tmpl
   ```
4. **Commit the rename as a standalone commit** — pure rename, no content changes. This keeps the history-preserving move distinct from the optimizations that follow.
   ```bash
   git commit -m "Rename <skill-name>/SKILL.md to <name>.md.tmpl"
   ```
5. **Apply workflow-based optimizations as separate commits**, one logical change per commit, so each optimization is independently reviewable and revertable:
   - **Frontmatter**: Convert from skill schema to workflow schema — add `workflow`, `slug`, `use`; remove `name`, `triggers`, `version`; reword `description` for the workflow context. Strip skill-only includes (`trigger-guard`, `base-ai-guidance`) and add `base-workflow-guidance`.
   - **Structure**: Move body content to the content template at `config/ai/templates/<category>/<name>-template.md`. The wrapper should contain only frontmatter + a single `includeTemplate` call. Restructure the body for the linear step format (Initialize, Plan, Apply, Verify, Deliver) if it was structured as a skill's step-overview with references.
   - **Resource cleanup**: If the skill had `scripts/`, `references/`, `evals/`, `assets/` directories, decide whether to delete them (conversion loses them) or warn the user. Delete only after explicit confirmation.
   - **Includes**: Add `{{ include "workflows/ai/includes/base-workflow-guidance.md" . }}` to the wrapper.

## Why Separate Commits

The `git mv` commit is a pure history-preserving move; the optimization commits are content transformations. Mixing them loses the clean lineage and makes reverts of individual optimizations impossible.

# Workflow Anatomy

## Directory Structure

A workflow consists of a Template/Wrapper file pair:

```
<category>/
├── <name>.md.tmpl              # Wrapper: frontmatter + includeTemplate call
└── (template lives elsewhere)

config/ai/templates/<category>/
└── <name>-template.md          # Content template (no frontmatter)
```

## Wrapper Frontmatter (YAML)

Required fields:
- **workflow**: Display name
- **slug**: kebab-case identifier
- **description**: What the workflow does
- **use**: When to invoke the workflow
- **date**:
  - **created**: Creation date (YYYY-MM-DD)
  - **knowledge-basis**: Last tech verification date (YYYY-MM-DD)
  - **last-used**: Last usage date (YYYY-MM-DD) — update on each use

**Example**:
```yaml
---
workflow: "AI Agent Create"
slug: "ai-agent-create"
description: "Create expert agents that channel specific expertise"
use: "When needing an agent for specialized tasks"
date:
  created: "2025-12-20"
  knowledge-basis: "2026-06-25"
  last-used: "2026-06-25"
---
```

## Template/Wrapper Pattern

The wrapper file in `config/ai/workflows/<category>/<name>.md.tmpl` contains frontmatter and a single `includeTemplate` call pulling in the content template from `config/ai/templates/<category>/<name>-template.md`. This separation lets the template be reused across wrappers and keeps frontmatter concerns (triggering, metadata) distinct from content concerns (steps, logic).

## What the Scaffolder Creates

`scripts/init_workflow.py <name> --path <dir>` creates:

1. `<dir>/<name>.md.tmpl` — wrapper with frontmatter TODOs and `includeTemplate` call
2. `config/ai/templates/<category>/<name>-template.md` — content template with section headers
3. Prints next-steps guidance for filling in the placeholders

## Project-Local Workflows (No Templater)

Not all workflows go through the skills-src build pipeline. Project-specific
workflows deployed directly in a project's `.agents/workflows/` directory are
**plain `.md` files** — no `.tmpl` extension, no `includeTemplate` call, no
Template/Wrapper split. The entire workflow (frontmatter + body) lives in a
single `.md` file.

This pattern is used when:

- The workflow is specific to one project and will never be distributed
- The project does not use the skills-src templater
- The workflow references project-local files and skills by path

**Key differences from templated workflows:**

| Aspect | Templated (`.md.tmpl`) | Project-local (`.md`) |
|--------|------------------------|-----------------------|
| Extension | `.md.tmpl` | `.md` |
| File split | Wrapper + content template | Single file |
| `includeTemplate` | Required | Not used |
| Build pipeline | `just build current` | None — edited directly |
| Distribution | Via `skills-releases` | Travels with the project repo |

When auditing a project-local `.md` workflow, skip the Template/Wrapper
integrity checks (no `includeTemplate` call to verify, no content template to
check). All other audit items (frontmatter, step structure, context
declaration, stale text, dates) still apply.

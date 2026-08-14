# Template-Specific Guidelines

This document provides template-specific guidance that complements the universal
creation framework included via `base-ai-guidance`.

## Required Frontmatter Fields

Every template must have clear frontmatter:

- `template`: Human-readable name for the template.
- `slug`: kebab-case identifier.
- `description`: What the template structures and when to use it.
- `use`: When to invoke this template.
- `engine`: Rendering engine (e.g., `go-template`, `markdown-only`).
- `outputs_to`: Paths or glob patterns where rendered artifacts will live.
- `date`: `created`, `knowledge-basis`, `last-used` (YYYY-MM-DD format).
- `variables.schema`: Entries with `name`, `type`, `required`, `default`, and
  `description`.

## Optional Frontmatter Fields

- `tags`: Categorization tags (e.g., `ai/template/<category>/<slug>`).
- `see-also`: Related templates, skills, or workflows.
- `partials`: References to partial/include files used by the template.
- `conflicts`: Conflict resolution strategies.
- `validation`: Validation rules for template variables.
- `tools`: Tools required for rendering.

## Variable Schema Format

Each entry in `variables.schema`:

```yaml
variables:
  schema:
    - name: "title"
      type: "string"
      required: true
      default: ""
      description: "The title of the generated document"
    - name: "sections"
      type: "array"
      required: false
      default: []
      description: "Array of section objects with heading and body"
```

## Meta-Template Contract

Use `config/ai/templates/meta/template-template.md` as the contract for new or
significantly revised templates. The meta-template defines:

- Required frontmatter fields and their format.
- Section structure expectations.
- Variable schema format.
- Rendering rule documentation.

## Template Usability

Each template must:
- Be safely usable by workflows like `ai-prompt-create` without additional
  explanation.
- Document conflicts, validation, and tools as needed.
- Have a `date.last-used` field that is updated on each use (YYYY-MM-DD format).

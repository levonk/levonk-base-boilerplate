# Template Audit Checklist

Use this checklist when auditing an existing template in Mode C (update/audit).
The shared audit methodology (propose-confirm-apply discipline) is wired in via
the `audit-methodology` include in SKILL.md; this file covers the
template-specific checks.

## Frontmatter Completeness

- [ ] `template` field present and human-readable.
- [ ] `slug` field present and kebab-case.
- [ ] `description` field present and states what the template structures.
- [ ] `use` field present and states when to invoke.
- [ ] `engine` field present and valid (`go-template`, `markdown-only`, etc.).
- [ ] `outputs_to` field present and points to valid paths/globs.
- [ ] `date.created`, `date.knowledge-basis`, `date.last-used` present (YYYY-MM-DD).
- [ ] `tags` present and follow naming convention.
- [ ] `see-also` entries valid (no circular dependencies, correct relationship
      types).

## Variable Schema Validity

- [ ] `variables.schema` entries well-formed (`name`, `type`, `required`,
      `default`, `description`).
- [ ] No stale or orphaned variables (all defined variables are used in the
      template body).
- [ ] No undocumented variables (all variables used in the body are defined in
      the schema).
- [ ] Required variables have no default; optional variables have sensible
      defaults.
- [ ] Variable types are valid (`string`, `array`, `object`, `boolean`,
      `number`).

## Meta-Template Pattern Compliance

- [ ] Frontmatter aligns with `templates/meta/template-template.md` structure.
- [ ] Section structure follows the meta-template contract.
- [ ] Rendering rules documented if non-trivial.
- [ ] Partials/includes documented if used.

## Template Still Used

- [ ] At least one calling workflow or prompt references this template.
- [ ] No calling workflow references the template with a stale path or name.
- [ ] The template's `outputs_to` paths are still valid destinations.

## Rendering Behavior

- [ ] Template renders cleanly with representative variables (dry-run if
      possible).
- [ ] No leaked template delimiters in rendered output.
- [ ] Rendered output is lint-clean where applicable.
- [ ] Conflict strategies and backup policies respected.

## Stale Text

- [ ] No references to renamed or deleted files.
- [ ] No outdated version numbers or dates.
- [ ] No TODOs or placeholder text left in the template body.

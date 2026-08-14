# Prompt Audit Checklist

When auditing an existing prompt (Mode C), check the following:

## Frontmatter

- [ ] Required fields present: `description`, `version`, `date` (created/updated/last-used), `tags`
- [ ] `date.last-used` reflects the current date (YYYY-MM-DD)
- [ ] `date.knowledge-basis` reflects the last content change
- [ ] Tags are accurate and follow the `ai/prompt/...` convention

## Naming Convention

- [ ] Filename follows
  `{project-slug}-prompt-{YYYYMMDDHHMM}-{step}-{parallel}-{prompt-slug}.md`
- [ ] Companion README exists in `internal-docs/prompts/doc/` with matching
  base name (readme substituted for prompt)

## Content Quality

- [ ] Prompt still relevant to current project goals
- [ ] Contextual information present (why, what, who, end goal)
- [ ] Explicit, specific instructions (unambiguous language, clear order)
- [ ] Sequential steps use numbered lists for multi-step workflows
- [ ] File/output instructions use explicit relative paths
- [ ] Success/verification block present (criteria + validation steps)

## Patterns and Templates

- [ ] Patterns still valid (coding/analysis/research) — update if task type
  has shifted
- [ ] Skeleton structure still appropriate for task complexity
- [ ] Extended thinking triggers included only where complex reasoning is
  needed
- [ ] Aligned with existing templates under `config/ai/templates/` where
  possible

## README Accuracy

- [ ] Companion README still documents design decisions accurately
- [ ] References and future-adjustment notes still current
- [ ] No stale links or obsolete context

## Self-Containment

- [ ] Each prompt is self-contained and executable independently
- [ ] Parallel/sequential step numbering is correct for the current task
  decomposition

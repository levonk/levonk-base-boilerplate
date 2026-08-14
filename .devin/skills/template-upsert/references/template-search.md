# Template-Specific Search

When researching before creating or improving a template:

1. **Local**: Scan `config/ai/templates/` for existing templates with similar
   purpose, variables, or output format. Check frontmatter `description` and
   `use` fields.
2. **Cross-check with prompts**: Existing prompts may already encode the
   pattern the template would capture. If so, extract the pattern into a
   template rather than creating from scratch. Look in `config/ai/prompts/`
   and `internal-docs/prompts/` for recurring structures.
3. **Cross-check with workflows**: Workflows may inline template-like structures
   that could be extracted into reusable templates. Check `config/ai/workflows/`
   for repeated patterns.
4. **skills.sh / GitHub**: Search for "template" + pattern keywords. Many
   template patterns are published as part of skills or workflow bundles.
5. **Meta-template review**: Review `config/ai/templates/meta/template-template.md`
   to understand the canonical structure before searching — this helps you
   recognize templates that already follow the contract vs. ad-hoc structures
   that need conversion.

### Search Strategy

- Start with the **pattern keywords** from the user's request (e.g., "YouTube
  note", "coding prompt pattern", "analysis report").
- Search for those keywords in template `description` and `use` fields.
- If no exact match, search for **adjacent patterns** — a template for "meeting
  notes" might be adaptable to "YouTube notes" with minor variable changes.
- Document findings: which templates are close, which are exact matches, which
  are in adjacent domains.

### Deduplication

If an existing template already captures the pattern:
- **Exact match**: Use the existing template; do not create a new one.
- **Close match**: Propose extending/refining the existing template rather than
  creating a sibling, unless the user explicitly wants a separate template.
- **Adjacent match**: Consider whether the existing template's variable schema
  can be generalized to cover both use cases.

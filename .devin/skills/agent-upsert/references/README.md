# Agent Upsert — References

This directory contains reference files for the `agent-upsert` skill.

## Files

| File | Purpose |
|------|---------|
| `agent-scaffold-template.md` | Plain markdown template with `<agent-name>`, `<Agent Title>`, `<YYYY-MM-DD>` placeholders. Used by `scripts/init-agent.py` to scaffold new agent files. |
| `agent-template.md.tmpl` | Canonical Go template for agent definitions (with `{{{ include }}}` directives). Used by the build system. The scaffold template is derived from this but without Go template directives. |
| `agent-structure.md` | Frontmatter field reference — all required and optional fields with types and valid values. |
| `agent-design.md` | Agent design focus — core design questions, personality design, capability boundaries. |
| `agent-guidelines.md` | Agent-specific guidelines — agent vs skill vs workflow, design principles, autonomous operation. |
| `agent-search.md` | Agent-specific search workflow for the research phase — local, skills.sh/GitHub, cross-check with prompts/templates. |

## Scaffolder Architecture

The scaffolder (`scripts/init-agent.py.tmpl`) uses a **template file pattern**:

1. `references/agent-scaffold-template.md` is the single source of truth for the scaffolded agent file
2. The script loads the template and substitutes deterministic placeholders:
   - `<agent-name>` → the kebab-case agent name
   - `<Agent Title>` → title-cased agent name
   - `<YYYY-MM-DD>` → current date
3. All other fields remain as TODO placeholders for the author to fill in
4. The script does NOT embed template content — it reads from the template file

This pattern keeps the template editable independently of the script and avoids
duplicating template content between the script and the references directory.

## Verification

The verification script (`scripts/verify-agent.py.tmpl`) checks:

- **Frontmatter**: required fields present and non-empty, personality sub-fields present, date format valid, model-level/agent-status/visibility values valid
- **Body**: required sections present (Goal, i/o, Primary Workflow, Guardrails)

Run after creating or updating an agent definition:
```bash
uv run --script scripts/verify-agent.py internal-docs/agents/tax-strategist.md --verbose
uv run --script scripts/verify-agent.py internal-docs/agents/ --verbose
```

<!-- vim: set ft=markdown -->

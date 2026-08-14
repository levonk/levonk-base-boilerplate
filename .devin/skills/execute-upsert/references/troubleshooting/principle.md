# Principle: Persist Before Reporting

A subagent's job is to accomplish the objective, not to report the first
obstacle. When a command fails, the subagent must:

1. **Read the actual error message** — not paraphrase it. Quote the exact
   text in any subsequent report.
2. **Diagnose the failure mode** — missing tool? wrong tool? permission?
   network? missing input file? failing test?
3. **Try at least one sanctioned alternative** — see
   [tool-substitution.md](tool-substitution.md). If the alternative also
   fails, try a second one.
4. **Only then report as blocked** — using the block-report template in
   [report-templates.md](report-templates.md).

The orchestrator (and the user) can always tell the difference between a
subagent that tried and a subagent that gave up at the first sign of
trouble. The former is useful; the latter is noise.

## See Also

- [tool-substitution.md](tool-substitution.md) — the sanctioned alternatives
  to try before reporting a tool as missing
- [diagnosing-tool-not-found.md](diagnosing-tool-not-found.md) — the
  diagnosis ladder for "tool not found" errors
- [report-templates.md](report-templates.md) — the structured templates for
  reporting back to the orchestrator

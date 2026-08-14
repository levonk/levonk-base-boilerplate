# Worked Examples

Four worked examples covering the common troubleshooting scenarios. Read
these when learning the pattern; experienced subagents can skip them.

## Example 1: Missing `rg`

A subagent tries to search the codebase:

```bash
$ rg "parseConfig"
zsh: command not found: rg
```

**Wrong response**: "Search failed, `rg` is not installed. Task blocked."

**Right response**: Use the agent's `grep` tool instead. If that's also
unavailable, try `cli-tool-discovery.sh rg` to find a wrapper. If still
nothing, report:

```markdown
## Block Report

**Objective**: Find all callers of `parseConfig()` in `src/`.

**What I tried**:
1. `rg "parseConfig"` → `command not found: rg`
2. Agent `grep` tool → returned 0 matches (tool may be misconfigured)
3. `cli-tool-discovery.sh rg` → no wrapper found in devbox/mise/asdf

**Root cause (hypothesis)**: `ripgrep` is not installed and no wrapper is
available in the current environment.

**Recommended next step**:
  - Option A: Install via `devbox global add ripgrep` and re-dispatch.
  - Option B: Run the search from inside `devbox shell` where `rg` is
    declared in `devbox.json`.
```

## Example 2: `npx` in a pnpm workspace

A subagent tries to run an ad-hoc tool:

```bash
$ npx ts-node scripts/migrate.ts
```

**Wrong response**: Runs `npx`, which fetches `ts-node` from npm without
vetting, violating the project's universal contract.

**Right response**: Use `pnpm dlx ts-node scripts/migrate.ts` on the host.
If inside a container, use `bunx ts-node scripts/migrate.ts`. The
subagent should never reach for `npx` in a pnpm workspace — the
substitution is automatic, not a last resort.

## Example 3: Devbox command fails

A subagent tries to run a build:

```bash
$ just build
zsh: command not found: devbox
```

**Wrong response**: "Devbox is not installed. Task blocked."

**Right response**: Walk the diagnosis ladder — check
`~/.local/share/devbox/global/shims/devbox`, add it to `PATH`, retry. Only
report as blocked if the binary genuinely doesn't exist on disk. See the
infrahub `AGENTS.md` "Environment Setup Rule" for the exact PATH-fix
snippet.

## Example 4: Successful workaround with memory capture

A subagent completes a story but hit a snag along the way. The story
required running a TypeScript build:

```bash
$ pnpm build
# succeeds, but earlier attempt:
$ npx tsx scripts/migrate.ts
# failed with: npx: command not found in devbox shell
```

The subagent substituted `pnpm dlx tsx scripts/migrate.ts` and the story
completed. The subagent's return includes both the success summary and a
workaround report:

```markdown
## Workaround Report

**Obstacle**: `npx tsx scripts/migrate.ts` failed with "command not found"

**Actual error**: `zsh: command not found: npx`

**Workaround that worked**: `pnpm dlx tsx scripts/migrate.ts`

**Why the workaround was needed**: The project uses pnpm as its package
  manager (per AGENTS.md universal contract); `npx` is not installed and
  is disallowed in pnpm workspaces. `pnpm dlx` is the sanctioned ad-hoc
  runner.
```

The orchestrator reviews the return. The workaround meets the trigger
criteria (sanctioned path wasn't documented for `tsx` specifically; the
substitution is likely to recur for other ad-hoc TS scripts). The
orchestrator spawns a memory subagent that adds the following to
`.agents/knowledge/developer.md` under "Known Gotchas":

```markdown
### npx not available — use pnpm dlx for ad-hoc TS scripts

**Symptom**: `npx tsx <script>` fails with `command not found: npx`.

**Cause**: The project uses pnpm as its package manager per the AGENTS.md
universal contract. `npx` is not installed and is disallowed in pnpm
workspaces.

**Fix**: Use `pnpm dlx tsx <script>` for ad-hoc TypeScript script
execution on the host. Inside a container, use `bunx tsx <script>`.

**Learned from**: story-4 (database migration script execution)
```

The orchestrator commits this as a separate doc commit:

```
docs: add npx-not-available gotcha to developer docs

Captured during story-4 execution. The executing subagent hit `npx:
command not found` and worked around it via `pnpm dlx tsx`. Documented
so the next agent doesn't reach for npx in this pnpm workspace.
```

The next story's subagent (story-5, which also needs to run a TS script)
reads the updated developer doc and uses `pnpm dlx tsx` directly — no
iteration, no failed `npx` attempt.

## See Also

- [principle.md](principle.md) — the discipline behind these responses
- [tool-substitution.md](tool-substitution.md) — the canonical substitution
  table
- [report-templates.md](report-templates.md) — the templates used in these
  examples
- [capturing-learnings.md](capturing-learnings.md) — the memory-capture
  flow shown in Example 4

# Parallel Dispatch — When Multiple Stories Are Dependency-Ready

When Phase 4 finds multiple `[ ] Todo` stories whose dependencies are all
`[x] Done`, dispatch them as parallel background subagents — one per story,
each in its own git worktree — instead of running them sequentially. This
dramatically reduces wall-clock time for phases with parallel-safe stories.

## When to Parallel-Dispatch

Parallel dispatch is appropriate when ALL of the following hold:

1. **Two or more `[ ] Todo` stories** have all dependencies in `[x] Done`
   (or `[!] Blocked` but the story can proceed without them).
2. **The stories do not modify the same files** — check each story's
   "Relevant Files" section (or the PRD's module breakdown). Stories that
   touch shared files (barrel exports, config files, shared utilities) will
   conflict on merge and should be serialized.
3. **The project's test suite supports per-worktree execution** — the
   worktree must be able to run tests independently (symlinked dependencies,
   separate build output).

If only one story is runnable, or stories share files, fall back to the
sequential execution loop described in SKILL.md Phase 4.

## Worktree Setup

For each runnable story:

```bash
# 1. Create a worktree on a new story branch from the integration branch
git worktree add -b <story-branch> /tmp/<project>-worktrees/<story-slug> <base-sha>

# 2. Symlink shared dependencies so the worktree can build and test
#    without re-installing. Adapt to the project's package manager:
ln -sfn <main-repo>/node_modules <worktree>/node_modules

# 3. For monorepos with workspace packages, symlink those too:
ln -sfn <main-repo>/node_modules/@<scope> <worktree>/node_modules/@<scope>
```

For non-JavaScript projects, adapt the dependency symlink (e.g., `target/`
for Rust, `.venv/` for Python). The goal is: the worktree can run the
project's test/lint/build commands without a full install.

## Dispatching Background Subagents

Dispatch one background subagent per worktree. Each subagent receives the
same inputs as a sequential dispatch (see SKILL.md Phase 4 step 3), plus:

- **Worktree path**: The absolute path to the worktree it should work in.
- **Branch name**: The story branch it should commit to.
- **Constraint**: Work ONLY in the assigned worktree. Do NOT modify files
  outside the worktree. Do NOT modify shared barrel/export files (e.g.,
  `src/index.ts`, `src/lib.ts`) — the orchestrator reconciles those during
  merge.

## Progress Emission (Critical)

**While background subagents are running, emit a progress update after each
subagent completion notification.** Do not go silent during the wait. A
silent orchestrator looks stalled to the user, even when work is progressing
normally.

After each subagent completes, report:

```markdown
### Progress Update

- **Completed**: story NN-NNN — <story title>
  - Tests: <count> passed, <count> failed
  - Status: [x] Done / [!] Blocked
- **Still running**: <N> subagent(s) — story NN-NNN, story NN-NNN
- **Next**: waiting for remaining subagents, then merge reconciliation
```

This pattern prevents the "looks stalled" problem where the user sees no
output for minutes while subagents run in the background.

## Merge Reconciliation

After all parallel subagents complete (or return `BLOCKED`):

1. **Merge each story branch back into the integration branch sequentially.**
   Use `git merge --no-ff` to preserve the story's commit history.

2. **Expect conflicts in shared files.** Even when stories target different
   modules, they may touch shared files (barrel exports, config
   registrations, shared test helpers). Conflicts here are expected, not
   exceptional.

3. **Resolve conflicts by keeping BOTH sides' additions.** When two stories
   add exports/registrations to the same file, keep both blocks. Never
   delete a story's work to resolve a conflict — if a story added an
   export, that export is needed.

4. **Watch for symbol/export name collisions.** Parallel subagents
   independently choose symbol names and may collide (e.g., two stories
   both export `FetchFn`). After merging all branches:
   - Run the project's typecheck (or equivalent static analysis).
   - If collision errors appear (e.g., TypeScript TS2308, duplicate symbol
     errors), rename the newer module's colliding symbol with a
     module-specific prefix (e.g., `FetchFn` → `ActorFetchFn`).
   - Update all references to the renamed symbol within that module.

5. **Run full validation across all affected packages/modules.** After all
   merges: run typecheck + tests + lint across the entire project (not just
   the individual story modules). Fix any integration issues that arise
   from the merge.

6. **Commit the reconciliation** as a single merge-commit:
   ```
   chore: reconcile parallel story merges

   - Merged story NN-NNN, NN-NNN, NN-NNN into integration branch
   - Resolved export collisions in <file>
   - Renamed <symbol> to <prefixed-symbol> in <module>
   - Full typecheck + tests pass across all packages
   ```

7. **Update the task index** to reflect the merged state of all stories.

## Blocked Stories in Parallel Mode

If a subagent returns `BLOCKED`:
- Mark the story `[!] Blocked` in the index with the `blocked_reason`.
- Write the `## Blocker` section into the story file.
- Do NOT block the other parallel subagents — let them finish.
- Include the blocked story in the Phase 5 Blocker Report along with any
  sequentially-blocked stories.

## Verifying Subagent Liveness (on Resume After a Crash)

**Worktree existence does NOT mean agents are working.** A worktree only
proves the setup step ran. If the orchestrator crashed and was restarted,
the subagents are dead but the worktrees remain as tombstones.

Before assuming any in-flight worktree has active work, verify liveness
with these signals (strongest first):

1. **Git commits in the worktree branch** — `git -C <wt> log --oneline -1`.
   If HEAD == the base SHA the worktree was created from, no work was
   committed. An agent that has been "working" for hours with zero commits
   is stuck or dead.
2. **File modification recency** — `find <wt> -type f -not -path
   '*/node_modules/*' -not -path '*/.git/*' -newermt '10 minutes ago'`.
   Nothing modified in the last 10 minutes = not actively working.
3. **Uncommitted change count trend** — `git -C <wt> status --porcelain |
   wc -l`. A stagnant count over time = no progress.

**One-liner to check all worktrees at once:**

```bash
for wt in /tmp/<project>-worktrees/*/; do
  slug=$(basename "$wt")
  head=$(git -C "$wt" rev-parse --short HEAD)
  changes=$(git -C "$wt" status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  recent=$(find "$wt" -type f -not -path '*/node_modules/*' -not -path '*/.git/*' -newermt '10 minutes ago' 2>/dev/null | wc -l | tr -d ' ')
  echo "$slug  head=$head  uncommitted=$changes  recent=$recent"
done
```

Interpretation:

- `head == base` + `recent == 0` → **dead**. Reclaim the worktree: commit
  any partial work if useful, then re-dispatch a fresh subagent.
- `recent > 0` → **alive**. The subagent is actively writing files. Wait
  for it.
- `head != base` → has committed work. Progress was made — inspect the
  diff before deciding whether to keep or re-dispatch.

**On resume after a crash:**

1. Run the liveness check above.
2. For dead worktrees with partial uncommitted work: inspect the diff. If
   the partial work is usable, commit it as a checkpoint. If not, discard
   it (`git -C <wt> checkout -- . && git -C <wt> clean -fd`).
3. Re-dispatch fresh subagents for the stories that had dead worktrees.
   Do NOT assume the old subagent's partial state — start clean from the
   base SHA unless the committed checkpoint is solid.

This liveness check applies to the parallel-dispatch worktrees created in
the "Worktree Setup" section above. For sequential execution (single
story branch, no worktree), the Phase 4 "Resume Detection" step in
SKILL.md handles branch existence checks — liveness verification is not
needed because the orchestrator itself is the single worker.

## Cleanup

After merge reconciliation is complete, remove the worktrees:

```bash
git worktree remove /tmp/<project>-worktrees/<story-slug>
```

Do this only after the merge is committed and validated — if the merge
needs to be redone, the worktree is the recovery point.

## See Also

- [SKILL.md Phase 4](../SKILL.md) — the sequential execution loop that this
  parallel mode optimizes
- [triage-heuristic.md](triage-heuristic.md) — request size assessment
- [documentation-update.md](documentation-update.md) — Phase 6 documentation
  updates after execution completes

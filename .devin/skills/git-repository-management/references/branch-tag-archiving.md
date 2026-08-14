# Branch & Tag Archiving

### When to Archive

Branches and tags accumulate over time: auto-generated IDE branches
(`cascade/...`), pre-push snapshot branches (`scratch/merge/...`), and
checkpoint tags (`tags/auto/...`) are the most common sources of clutter.
Archive them when:

- The branch is **merged** into the main development branch (`env/dev`,
  `main`, or the repo's equivalent) and no longer needed for reference.
- The branch is **stale** — no commits in N months and no open PR references it.
- The tag points to a commit that is **already in the main branch's history**
  (the checkpoint it marked has been absorbed).
- The user explicitly asks to "clean up", "archive", or "prune" branches or
  tags.

### Archive Format

```
archive/branches/{type}/YYYY/MM/YYYYMMDD-{slug}[-pre|-post]
archive/tags/{type}/YYYY/MM/YYYYMMDD-{slug}[-pre|-post]
```

Where:

- `{type}` — Conventional-commit type that best characterizes the branch/tag:
  `feat`, `fix`, `chore`, `doc`, `refactor`, `perf`, `test`, `build`, `ci`,
  `style`, `revert`, plus two extensions:
  - `auto` — IDE/tool-generated branches (e.g., `cascade/...`) with no human
    author intent.
  - `scratch` — Pre-push snapshot branches and other transient checkpoints.
- `YYYY/MM` — Year and month derived from the branch/tag's **last commit date**
  (not the current date). This groups archives by when the work actually
  happened, not when the archive operation ran.
- `YYYYMMDD` — Same date as above, zero-padded.
- `{slug}` — Kebab-case slug derived from the original branch/tag name. Strip
  prefixes (`cascade/`, `scratch/merge/`, `tags/auto/`, etc.) and collapse the
  remainder into a readable slug. Max 50 characters.
- `[-pre|-post]` — Preserve the `pre`/`post` suffix if the original name had
  one (common for checkpoint tags). Omit otherwise.

### Examples

```
# Branches
cascade/repository-path-users-micro-windsurf-0032d9
  → archive/branches/auto/2026/07/20260715-repo-path-windsurf-0032d9

scratch/merge/2026/07/202607290312-push-pre
  → archive/branches/scratch/2026/07/20260729-push-pre

chore/skills-repo-extraction-cleanup
  → archive/branches/chore/2026/07/20260707-skills-repo-extraction-cleanup

# Tags
tags/auto/grm/2026/06/20260628074700-ai-skill-upsert-devbox-rtk-pre
  → archive/tags/auto/2026/06/20260628-ai-skill-upsert-devbox-rtk-pre

tags/feat/2026/06/27/add-tagging-phase
  → archive/tags/feat/2026/06/20260627-add-tagging-phase
```

### The Levonk Ownership Exception

**Default**: Apply the archive format above to all repos.

**Exception**: If the repository's upstream remote is **not** owned by the
`levonk/` GitHub account (or the user's equivalent primary account), **defer to
the repo's own archiving convention** instead. Many upstream projects have
their own branch naming, tagging, and release conventions that would be
disrupted by injecting `archive/` refs.

Detection:

```bash
# Get the upstream owner from the remote URL
upstream_owner=$(git remote get-url origin 2>/dev/null \
  | sed -n 's|.*github\.com[:/]([^/]+)/.*|\1|p')
```

If `upstream_owner` is not `levonk` (case-insensitive), the script should:

1. **Skip archiving** unless the user explicitly passes `--force`.
2. **Print a notice** explaining that the repo appears to be an upstream/fork
   and the user should follow the project's own conventions.
3. **Exit 0** (not an error — just a no-op with guidance).

### Workflow

The archiving workflow has three phases, each a single AI→script handoff:

#### Phase 1: Identify (git-archive.sh --identify)

The script scans all local branches, remote-tracking branches, and tags,
classifies each as archive-eligible or keep, and prints a structured list.
The AI agent reviews the list and decides what to archive.

**Squash-merge detection**: The script uses both `git merge-base --is-ancestor`
(fast-path for true merges) and `git cherry` (catches squash-merged branches
whose commits are not ancestors of main but whose patch content is already in
main). This is critical for workflows that use squash merges (common in GitHub
PR workflows) — without `git cherry`, squash-merged branches would be
misclassified as "unmerged" and kept forever.

**Flags**:
- `--skip <b1,b2,...>` — Exclude specific branches from consideration
  (comma-separated). Combined with the protected-branch list.
- `--fetch` — Fetch from origin (with `--prune`) before identifying, so
  remote-tracking refs are current. Default is no fetch (use `--no-fetch`
  to be explicit).
- `--main-branch <branch>` — Override the auto-detected main branch.
- `--force` — Skip the upstream-ownership check (see The Levonk Ownership
  Exception below).

**Remote branches**: The script also scans `git branch -r` for
remote-tracking branches that have no local counterpart. These are labeled
with `remote-merged` or `remote-unmerged` status.

Classification rules:

| Ref type | Archive if | Keep if |
|----------|-----------|---------|
| `cascade/...` | Always (auto-generated) | Never — these are always safe |
| `scratch/...` | Merged into main branch | Unmerged with uncommitted work |
| `tags/auto/...` | Points to commit in main history | Points to orphaned commit |
| `tags/feat/`, `tags/tasks/` | User confirms | Active task in progress |
| Other branches | Merged into main + stale (>30 days) | Active development branch |
| `env/dev`, `main`, `master` | Never | Always keep |

#### Phase 2: Archive (git-archive.sh --archive)

For each ref the AI selects:

1. **Rename** the branch/tag to the archive path (`git branch -m` / `git tag`
   + `git tag -d`).
2. **Push** the archive ref to the remote (`git push origin <archive-path>`).
3. **Delete** the old remote ref (`git push origin --delete <old-name>`).
4. **Print** `ARCHIVED:<old>→<new>` for each operation.

The script accepts a list of refs on stdin (one per line) or via `--ref`
repeated flags. It never archives anything not explicitly listed.

**Confirmation**: The script prompts for confirmation before archiving unless
`--yes` (or `-y`) is passed. In a non-interactive context (no TTY on stdin),
it aborts with `SKIPPED:USER_ABORTED` unless `--yes` is passed. This prevents
accidental bulk archival when the script is called by an AI agent without
explicit user approval.

**Post-action guidance**: After archiving, the script prints a notice
reminding collaborators to run `git fetch --prune` to sync their local refs.

#### Phase 3: Prune (git-archive.sh --prune, optional)

After a retention period (default 6 months, configurable via
`--retention-months N`), delete archive refs that are older than the threshold:

1. List all `archive/branches/` and `archive/tags/` refs.
2. Parse the `YYYY/MM` from the path.
3. Delete refs older than the retention period (local + remote).
4. Print `PRUNED:<ref>` for each deletion.

**Pruning is destructive.** The script requires `--confirm` to actually delete;
without it, prints what would be pruned and exits 0.

### Dry Run

All phases support `--dry-run`: the script prints what it would do without
making any changes. Always run `--dry-run` first when working with an
unfamiliar repo.

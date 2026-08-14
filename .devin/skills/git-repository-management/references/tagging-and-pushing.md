# Tag and Push Details

### Tagging HEAD
Tags are created only on explicit user request. Two forms:

```bash
# Conventional path: tags/<category>/YYYY/MM/DD/<slug>
./scripts/git-tag.sh --category fix --slug sidebar-overflow

# Explicit path (any user-supplied string)
./scripts/git-tag.sh --path v1.2.3 --message "Release 1.2.3"
```

The script:
- Validates `category` against the conventional-commit list and `slug` against kebab-case when the default scheme is used.
- Refuses to overwrite an existing tag (exit 1, `TAG_FAILED:TAG_EXISTS`).
- Creates an **annotated** tag (`git tag -a`) at HEAD.
- Does NOT push the tag. Push explicitly with `git push origin <tag-path>` when the user wants it published.

### Automatic Run Tagging (CRITICAL)

**Every run of this skill MUST create a minimum of 2 tags**, automatically and without asking the user for permission:

1. **Pre-run tag**: Created BEFORE any commits are made
2. **Post-run tag**: Created AFTER all commits are made

Any additional tags the user explicitly requests are created in addition to these 2 automatic tags.

#### Tag Format

```
tags/auto/grm/YYYY/MM/YYYYMMDDHHmmss-{slug}-{pre|post}
```

Where:
- `grm` — Skill identifier (`git-repository-management`); namespaces auto-tags per skill so consumers can filter `tags/auto/grm/*` vs `tags/auto/execute-upsert/*` etc.
- `YYYY/MM` — Current year and month (e.g., `2026/06`)
- `YYYYMMDDHHmmss` — Full timestamp (e.g., `20260627162000`)
- `{slug}` — General slug describing all commits combined in this run (kebab-case, max 50 chars)
- `{pre|post}` — Literal `pre` for the pre-run tag, `post` for the post-run tag

#### Example Tags

```
tags/auto/grm/2026/06/20260627162000-add-nixify-advanced-features-pre

tags/auto/grm/2026/06/20260627162045-add-nixify-advanced-features-post
```

#### Tag Creation Commands

```bash
# Pre-run tag (before any commits)
TAG_PREFIX="tags/auto/grm/$(date -u +%Y/%m)/$(date -u +%Y%m%d%H%M%S)"
git tag -a "${TAG_PREFIX}-${SLUG}-pre" -m "Pre-run checkpoint: ${SLUG}"

# Post-run tag (after all commits)
TAG_PREFIX="tags/auto/grm/$(date -u +%Y/%m)/$(date -u +%Y%m%d%H%M%S)"
git tag -a "${TAG_PREFIX}-${SLUG}-post" -m "Post-run checkpoint: ${SLUG}"
```

#### Tagging Rules

- **Automatic**: Tags are created without asking the user
- **Minimum 2 per run**: Pre and post tags are always created
- **User-requested tags**: Any tags the user asks for are created in addition to the automatic ones
- **Push**: When pushing, include tags with `git push --tags` or `git push origin <tag>`
- **Slug derivation**: The slug should summarize all commits in the run (e.g., if commits are "Add nixify features" and "Update workflow rules", the slug could be `nixify-features-workflow-rules`)
- **Annotated tags**: Always use `git tag -a` (annotated tags) with a descriptive message

## Usage Patterns

### Complete Repository Management (3 Handoffs)
The AI agent orchestrates the complete workflow with minimal handoffs:

```bash
# Handoff 1: Collect all data
./scripts/git-collect.sh

# AI analyzes data and makes decisions:
# - Groups changes into logical commits
# - Writes commit messages
# - Handles quality check failures
# - Derives a slug for the run (optional — defaults to branch name)

# Handoff 2: Execute all commits (auto-creates pre/post tags)
# NOTE: Use \n\n to separate subject from body — the script enforces
# mandatory commit bodies and rejects bodyless commits with NO_BODY.
# Pass --slug for a descriptive run slug; it's also used by git-push.sh.
echo "COMMIT:Add user authentication\n\n- Implement login endpoint with JWT generation\n- Add session validation middleware\n- Cover with auth tests
FILES:src/auth/login.py
FILES:src/auth/session.py
FILES:tests/auth/test_login.py
COMMIT:Update API documentation\n\n- Document the new /auth/login endpoint\n- Add JWT token format section to README
FILES:docs/api/authentication.md
FILES:README.md" | ./scripts/git-commit-batch.sh --slug add-jwt-auth

# Handoff 3: Push (auto-tags pushed via --follow-tags)
./scripts/git-push.sh origin main --slug add-jwt-auth

# Handoff 4 (only if user asked for a tag): tag HEAD
./scripts/git-tag.sh --category feat --slug add-jwt-auth --message "Mark JWT auth rollout"
# Or with an explicit path:
./scripts/git-tag.sh --path v1.2.3 --message "Release 1.2.3"
git push --tags
```

### Complete Repository Cleanup
```bash
# Handle entire repository from dirty to clean
devbox run ./scripts/git-repo-manager.sh complete
```

### Analysis Only
```bash
# Just analyze current state without committing
devbox run ./scripts/git-repo-manager.sh analyze
```

### Dry Run Mode
```bash
# Plan commits without executing
devbox run ./scripts/git-repo-manager.sh organize --dry-run
```

### Environment Integration
The skill automatically detects and integrates with:
- **Devbox**: Preferred environment for optimal experience
- **Mise**: Alternative environment manager
- **Nix**: Flake-based environments
- **Native**: Direct system execution

## Script Command Reference

### Minimal Handoff Architecture
Only 3 scripts needed to minimize AI-script handoffs:

**git-collect.sh** - Single data collection handoff
- Collects all repository data in one call
- Returns: changes, quality checks, branch info, diff stats
- Usage: `./scripts/git-collect.sh [repo_root]`
- Output: Structured data for AI analysis

**git-commit-batch.sh** - Single commit execution handoff
- Executes multiple commits from AI-provided decisions
- Creates automatic pre/post run tags (`tags/auto/grm/YYYY/MM/TS-<slug>-{pre,post}`)
- Input: STDIN with commit messages and file groupings
- With `--amend`: exactly one COMMIT block; stages files and amends HEAD
  instead of creating a new commit. Use after a quality-check failure to fix
  the last commit without polluting history with a "fix the fix" commit.
  Pre/post auto-tags still fire for rollback safety.
- Usage: `printf 'COMMIT:<subject>\\n\\n- <body line>\\nFILES:<file1>\nFILES:<file2>\n' | ./scripts/git-commit-batch.sh [--slug <slug>] [--amend] [repo_root]`
- Output: Execution results for each commit, `AUTO_TAG_PRE:<tag>`, `AUTO_TAG_POST:<tag>`

**git-push.sh** - Push commits (fetch-rebase-push with auto-resolution)
- Creates a backup branch at `scratch/merge/YYYY/MM/YYYYMMDDHHmm-{slug}-pre` before any changes
- Fetches remote, then tries rebase with `-X auto` (auto-resolve trivial conflicts)
- If rebase conflicts remain, aborts and tries merge with `-X auto` as fallback
- If merge also has conflicts, **leaves the merge in conflicted state** and reports:
  - `CONFLICTED_FILES:` — list of files with conflicts
  - `CONFLICT_MARKERS:` — conflict regions with line numbers for each file (for AI analysis)
  - `MERGE_STATE:IN_PROGRESS` — merge is active, not aborted
  - `NEXT_STEPS:` — instructions for AI to resolve, stage, commit, and re-run push
  - `ABORT_CMD:` — how to discard the merge if needed
- Uses `--follow-tags` so auto-tags from `git-commit-batch.sh` are pushed with the commits
- The AI agent should resolve conflicts, `git add` resolved files, `git commit --no-edit`, then re-run the push script
- Usage: `./scripts/git-push.sh [remote] [branch] [repo_root] [--slug <slug>]`
- Output: `PUSH_SUCCESS:<remote>/<branch>` with backup branch info, or `PUSH_FAILED:MERGE_CONFLICTS_NEED_RESOLUTION` with conflict details

**git-tag.sh** - Tag HEAD (on user request only)
- Creates an annotated tag at HEAD. Two modes:
  - Default scheme: `--category <cat> --slug <slug>` builds `tags/<cat>/YYYY/MM/DD/<slug>` (zero-prefixed MM/DD).
  - Explicit path: `--path <tag>` uses the supplied string verbatim.
- Optional `--message <msg>` (defaults to `Tag <path>`).
- Validates category against conventional-commit types and slug against kebab-case (default scheme only).
- Refuses to overwrite an existing tag.
- Usage:
  - `./scripts/git-tag.sh --category feat --slug add-jwt-auth [repo_root]`
  - `./scripts/git-tag.sh --path v1.2.3 --message "Release 1.2.3" [repo_root]`
- Output: `TAG_PATH`, `TARGET` (SHA), `TAG_SUCCESS:<path>` or `TAG_FAILED:<reason>`
- **Does not push the tag.** Publish with `git push origin <tag-path>` when the user wants it on the remote.

**git-rollback.sh** - Roll back to a tag or SHA (with backup branch)
- Creates a backup branch at `scratch/rollback/YYYY/MM/YYYYMMDDHHmm-{slug}-pre` before any changes
- Performs `git reset --hard <target>` to roll back to the specified tag or SHA
- The backup branch preserves the pre-rollback state for recovery
- Usage: `./scripts/git-rollback.sh --to <tag-or-sha> [--slug <slug>] [repo_root]`
- Output: `ROLLBACK_SUCCESS:<target>`, `BACKUP_BRANCH:<branch>`, or `ROLLBACK_FAILED:<reason>`
- **Does not push.** The backup branch is local. Push it if you need it on the remote.
- **Recovery**: `git checkout <backup-branch>` or `git reset --hard <backup-branch>` to undo the rollback.

**Environment Detection:**
The `git-collect.sh` script automatically detects and uses available environment managers:
- Devbox (devbox.json)
- Mise (mise.toml, .mise.toml, .tool-versions)
- Nix (flake.nix)
- Native (fallback)

**Repository Root Discovery:**
All scripts automatically discover the repository root from any subdirectory using `git rev-parse --show-toplevel`. You can also pass the target path explicitly as the last argument.
- `complete`: Run complete workflow end-to-end

### VSCode Management Functions
- `is_vscode_running()`: Detects if VSCode is already running
- `launch_vscode_safely()`: Launches VSCode only when needed, reuses existing instance
- `check_vscode_buffers()`: Checks for unsaved files in running VSCode instances

### git-status-helper.sh
Helper script for detailed git status analysis when git-status-digest.sh is unavailable:
- Porcelain output parsing
- Change categorization and counting
- Diff generation for review

### Use RTK When Available (CRITICAL)

**ALWAYS** use the `rtk` (Rust Token Killer) tool as a proxy for `git` and other supported commands when it is available on the system. RTK reduces LLM token consumption by 60-90% by filtering and compressing command outputs.

- **Detection**: Check availability with `command -v rtk` before use
- **Git commands**: Use `rtk git <args>` instead of `git <args>` (e.g., `rtk git status`, `rtk git diff`, `rtk git log`)
- **Quality checks**: Use `rtk <tool> <args>` for supported tools (eslint, prettier, npm, cargo, pytest, etc.)
- **Fallback**: If `rtk` is not available, use the raw command directly
- **No user permission needed**: This is automatic — do not ask the user whether to use rtk
- **All scripts**: The deterministic scripts (`git-collect.sh`, `git-commit-batch.sh`, `git-push.sh`) already include rtk detection and will use it automatically when available

#### Supported RTK Commands

RTK optimizes output for 100+ commands. Key ones for this skill:

| Command | RTK Usage | Savings |
|---------|-----------|---------|
| `git status` | `rtk git status` | 75-93% |
| `git diff` | `rtk git diff` | 70% |
| `git log` | `rtk git log` | 80-92% |
| `git add` | `rtk git add` | 92% |
| `git commit` | `rtk git commit` | 92% |
| `git push` | `rtk git push` | 92% |
| `eslint` | `rtk eslint` | 80% |
| `prettier` | `rtk prettier` | 80% |
| `npm test` | `rtk npm test` | 90% |
| `cargo test` | `rtk cargo test` | 90% |
| `pytest` | `rtk pytest` | 90% |

See: <https://github.com/rtk-ai/rtk> for full command coverage.

#### Implementation in Scripts

All three deterministic scripts include this pattern:

```bash
if command -v rtk >/dev/null 2>&1; then
    RTK_AVAILABLE=1
else
    RTK_AVAILABLE=0
fi

git_cmd() {
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        rtk git "$@"
    else
        git "$@"
    fi
}
```

The AI agent should also prefer `rtk` when running git commands directly (outside the scripts).

## Integration with Development Loop

This skill is designed to integrate seamlessly with the AI Development Loop:
- **Data Collection**: Script collects repository state and quality check results
- **AI Analysis**: AI analyzes data and makes intelligent decisions
- **Execution**: Script executes AI decisions (staging, committing, pushing)
- **Documentation**: AI updates project documentation based on changes

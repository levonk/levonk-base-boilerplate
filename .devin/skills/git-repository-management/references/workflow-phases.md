# Detailed Workflow Phases

### Phase 0: Script Discovery (Fail Fast)
Before executing any git operations, locate the deterministic scripts in the `scripts/` directory that is parallel to this `SKILL.md` file. Verify the required scripts exist and are executable. If scripts are missing or not executable, fail immediately with a clear error message:
```bash
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"  # Directory containing this SKILL.md
SCRIPTS_DIR="$SKILL_DIR/scripts"

# Verify required scripts exist and are executable
required_scripts=(
    "git-collect.sh"
    "git-commit-batch.sh"
    "git-push.sh"
    "git-tag.sh"
)

for script in "${required_scripts[@]}"; do
    script_path="$SCRIPTS_DIR/$script"
    if [ ! -x "$script_path" ]; then
        echo "ERROR: Required script not found or not executable: $script_path"
        exit 1
    fi
done
```

### Phase 1: Repository Initialization (Conditional)

Only runs when `git-collect.sh` detects the target is not inside a git
repository. The script emits a structured `NOT_A_GIT_REPO` signal (text or JSON)
and exits with code 2. The AI agent then decides whether to initialize the
directory via the bundled `scripts/git-repo-init.bash` before re-running
collection. For existing repositories, this phase is a no-op and the workflow
proceeds directly to Phase 2.

- **Step 1**: Call `git-collect.sh` on the target path.
  - If the target is a git repo → proceeds to Phase 2 (Data Collection).
  - If the target is NOT a git repo → emits `NOT_A_GIT_REPO` signal, exits 2.
- **Step 2** (only if the signal fired): Decide whether to init.
  - Consider the user's intent, the directory contents, and whether a dependent
    skill needs a repo to checkpoint against. When in doubt, ask the user.
  - Pick the init scope: full CREATE mode (default) or init-only. Run
    `git-repo-init.bash --dry-run -v` first for non-empty dirs.
- **Step 3** (only if init ran): Re-run `git-collect.sh` on the now-initialized
  target. The directory is now a git repo, so Phase 1 passes through to Phase 2.

See [Repository Initialization](repository-initialization.md) for the full
signal format, the three AI decision points (whether to init, which scope,
re-collection), the bundled script's configuration, and security notes.

### Phase 2: Data Collection (Single Script Call)
- **Step 1**: Call `git-collect.sh` - ONE handoff to get ALL data
  - Repository metadata (branch, upstream, root)
  - All change data (staged, unstaged, untracked files)
  - Diff stats and context — `FULL_DIFF` includes staged + unstaged + untracked
    file contents, bounded by `FULL_DIFF_MAX_BYTES` (default 200KB) with a
    truncation notice when exceeded. For per-file diffs beyond the bound, run
    `git diff HEAD -- <path>` yourself (token-efficiency tradeoff).
  - Quality check results (lint, test, format, `just` targets)
  - Pass `--json` for a single JSON object with a stable schema
    (`repo_root`, `branch`, `upstream`, `available_tools`, `recent_log[]`,
    `staged[]`, `unstaged[]`, `untracked[]`, `diff_stats`, `full_diff`,
    `quality_checks{eslint, prettier, tests, just[]}`). Useful when delegating
    analysis to parallel subagents — each subagent gets a slice of the JSON.
- **Step 2**: Script returns structured data for AI analysis

### Phase 3: AI Analysis & Planning (AI Agent)
- **Step 3**: Analyze collected data to understand change context.
- **Step 4**: Group changes into coherent commits by functionality (VERTICAL grouping)
  - **CRITICAL**: NEVER DELETE UNTRACKED FILES UNLESS YOU CREATED THEM AS TEMPORARY FILES! YOU MUST COMMIT USEFUL FILES!
  - **CRITICAL**: Group by functional area, NOT by file type
  - Each commit should include ALL files related to a specific feature/area (code, tests, docs, configs)
  - Example: If adding RTK packages, commit should include: nix/rtk-*.nix + wrappers/rtk-tools/* + tests/rtk/* + docs/rtk.md
  - WRONG: Separate commits for "all nix files", "all wrapper scripts", "all tests" (horizontal grouping)
  - RIGHT: Commits like "Add RTK token optimization packages", "Add devbox-auto environment management", "Add integrated devbox-rtk governance"
- **Step 5**: Write meaningful commit messages for each group
- **Step 6**: Decide how to handle any quality check failures
- **Step 7**: Prepare batch commit specification
  - **CRITICAL — Order commits least-complicated to most-complicated.** The `git-commit-batch.sh` script executes commits in the order they appear in the STDIN spec, and each commit lands on top of the previous one. Order the batch so the simplest, smallest, most self-contained commits go first and the largest, most entangled, or riskiest commits go last. The intent is rollback safety: if a later commit needs to be reverted, only the complicated tail is lost while the simple, well-isolated commits beneath it stay in place. Reverting a complicated commit should never silently pull a simple, unrelated one with it.
  - **Complication signals (use to rank commits, lowest first):**
    - Number of files touched (fewer = simpler)
    - Number of distinct functional areas crossed (one = simplest)
    - Lines changed (smaller diff = simpler)
    - Touches shared/cross-cutting code (config, build, types, public API) = more complicated
    - Depends on another commit in this batch to make sense = more complicated (place after its dependency, but still prefer simple-independent-first when there's no dependency)
    - Behavioral/risk surface (new feature > refactor > docs/test/chore/formatting)
  - **Tie-break:** when two commits are equally complicated, put the one with no dependencies on other batch commits first.
  - **Dependency exception:** if commit B logically depends on commit A (B won't build/test without A), A must precede B regardless of complication — but within a dependency chain, keep simpler independent commits ahead of the chain when they don't depend on it.
  - **Example ordering** (least → most complicated):
    1. `docs: Update README install section` (1 file, docs-only)
    2. `chore: Bump devbox flake inputs` (2 files, mechanical)
    3. `test: Add unit tests for auth helpers` (3 files, test-only)
    4. `feat: Add JWT auth with middleware and tests` (8 files, new behavior, touches shared middleware)
    5. `refactor: Rework connection pooling across all DB callers` (15 files, cross-cutting, highest risk)

### Parallel Subagent Delegation for Batch Message Drafting

When a batch contains **N≥3 independent logical change groups**, drafting
commit messages sequentially (one group at a time in the orchestrator's
context) is slow and pollutes the orchestrator context with per-group diff
details. Instead, dispatch one background subagent per change group in
parallel, then assemble the results into a single batch file and run
`git-commit-batch.sh` once.

**When to use:**
- Batches with N≥3 independent logical change groups
- Change groups are independent (no dependency requiring sequential decisions)
- The orchestrator context is getting large and per-group diffs are noise

**When NOT to use:**
- Small batches (N<3) — the dispatch overhead exceeds the parallelism gain
- Change groups have dependencies requiring sequential decisions (e.g. group
  B's message depends on what group A decided to call a concept)
- The diffs are tiny and the orchestrator can draft all messages in one pass

**How:**
1. After Phase 2 collection and Phase 3 grouping, identify the N change groups
2. For each group, dispatch a background subagent with:
   - The specific diff for that group (`git diff HEAD -- <files>` output)
   - The commit-message format from `commit-organization.md` (subject + body,
     mandatory body, no AI signatures, significant-change titles)
   - The no-AI-signatures rule (permanent, non-negotiable)
   - The vertical-grouping context (which files belong to this group)
3. Each subagent returns a `COMMIT:<subject>\n\n<body>` + `FILES:` block
4. Assemble the returned blocks into a single batch file, ordered
   least-complicated → most-complicated (Step 7 above)
5. Optionally run `git-commit-batch.sh --dry-run` to validate the assembled
   batch before committing
6. Run `git-commit-batch.sh` once with the assembled batch

**Context front-loading:** each subagent is stateless — front-load all
context it needs (the diff, the format rules, the no-signatures rule) in the
dispatch prompt. Do not assume the subagent can see the orchestrator's
context. See the `subagent-delegation` include for the general
front-load-context / review-results / choose-serialization-vs-parallelization
guidance; this subsection is the batch-message-drafting specialization.

### CRITICAL: Git Submodule Handling

**NEVER** convert git submodules to regular directories. This destroys the intended architecture and can expose sensitive information.

**When the repository contains git submodules:**

1. **DETECT SUBMODULES**: Check for `.gitmodules` file and submodule directories
2. **NEVER DELETE SUBMODULES**: If a directory is a git submodule, NEVER delete it and replace with regular files
3. **PROPER SUBMODULE WORKFLOW**:
   - Enter submodule directory to make changes: `cd submodule-name`
   - Commit changes within the submodule: `git add . && git commit -m "message"`
   - Push submodule changes: `git push origin master`
   - Return to parent repo: `cd ..`
   - Update submodule reference: `git add submodule-name && git commit -m "Update submodule"`

4. **WARNING SIGNS** of incorrect submodule handling:
   - Submodule directory contains `.gitignore` file (shouldn't exist in submodule)
   - `git status` shows submodule as "modified" with no staged changes
   - Submodule files appear as regular files instead of submodule reference
   - `.gitmodules` file has been modified to remove submodule entry

5. **IMMEDIATE REMEDIATION** if submodule issues detected:
   - Revert the destructive commit
   - Restore proper git submodule structure
   - Commit the fix immediately
   - Review for any exposed sensitive information

**SUBMODULE-SECURITY AWARENESS**: Client submodules often contain private client-specific information. Converting them to regular directories can expose secrets and break security isolation.

### Phase 4: Execution (Single Script Call)
- **Step 8**: **Create pre-run tag** (see Automatic Run Tagging below)
  - Tag the current state BEFORE any commits are made
  - This is automatic and does NOT require user permission
- **Step 9**: Call `git-commit-batch.sh` - ONE handoff to execute ALL commits
  - Pass commit messages and file groupings via STDIN
  - Script stages and commits each group
  - Returns execution results for each commit
- **Step 10**: **Create post-run tag** (see Automatic Run Tagging below)
  - Tag the final state AFTER all commits are made
  - This is automatic and does NOT require user permission
- **Step 11**: Call `git-push.sh` to push commits and auto-tags.
  - **When to push**: Push when the user's intent includes publishing — "commit
    and push", "ship this", "clean up the repo" (cleanup implies pushing for
    most workflows). For checkpoint commits (the Checkpoint entry point), don't
    push — that entry point skips push by design. If the user only said "commit"
    without mentioning pushing, ask once whether to push. Don't ask about
    *how* to handle divergence — that's the script's job, not a user decision.
  - **Divergence is not a decision point**: If the branch has diverged from
    remote (local has commits remote doesn't, remote has commits local
    doesn't), just run `git-push.sh`. The script fetches, creates a backup
    branch, rebases with `-X auto` (auto-resolves trivial conflicts), and only
    escalates to the AI if there are real conflicts needing manual resolution.
    See [Tagging and Pushing](tagging-and-pushing.md) for the full conflict
    escalation flow.
  - **Never manually rebase or pull before pushing**: `git-push.sh` handles
    fetch-rebase-push with a backup branch for safety. Running `git rebase` or
    `git pull` manually bypasses that backup and defeats the rollback safety
    the script provides. The only correct way to push is through the script.

### Phase 5: Documentation & Summary (AI Agent)
- **Step 12**: Update project documentation (changelog, architecture, status)
- **Step 13**: Generate commit summary and statistics
- **Step 14**: Suggest follow-up skills based on what was committed:
  - **Code changes** (feat, fix, refactor) → suggest `code-quality-validation`
    to run lint/test/format checks on the committed code
  - **Documentation changes** (docs) → suggest `readme-upsert` or
    `agent-file-upsert` to keep README and AGENTS.md in sync with the changes
  - **Large batch** (5+ commits) → suggest `handoff` to capture the session's
    context, decisions, and next steps for continuation
  - **Release-related** (release, chore with version bumps) → suggest
    `code-quality-validation` for a final pre-release validation pass
  - Only suggest skills that are actually installed — check the available
    skills list before suggesting. State the suggestion as a recommendation,
    not an automatic invocation.

### Phase 6: Tagging (Optional, On User Request)
Only run when the user explicitly asks to tag HEAD (e.g. "tag this", "cut a tag", "mark this release"). Never tag autonomously.

- **Step 12**: Decide the tag path.
  - If the user gave an explicit tag path (e.g. `v1.2.3`, `release/2026-06-27`), pass it verbatim via `--path`.
  - Otherwise build the conventional path: `tags/{category}/YYYY/MM/DD/{slug}` where:
    - `{category}` is a conventional-commit type: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `revert`. Pick the one that best describes the change being tagged.
    - `YYYY` is the 4-digit year, `MM` and `DD` are 2-digit zero-prefixed month and day (today's date, UTC-local).
    - `{slug}` is a descriptive kebab-case slug (lowercase letters/digits separated by hyphens, no leading/trailing hyphen). Derive it from the change summary, not the commit SHA.
  - Examples:
    - `tags/feat/2026/06/27/add-jwt-auth`
    - `tags/fix/2026/01/05/sidebar-overflow`
    - `tags/chore/2026/03/14/bump-deps`
- **Step 13**: Call `git-tag.sh` with the resolved path and an optional `--message` (defaults to `Tag <path>`). The script refuses to overwrite an existing tag.
- **Step 14**: If the tag should be published, push it explicitly: `git push origin <tag-path>` (the `git-push.sh` script pushes the current branch, not tags).

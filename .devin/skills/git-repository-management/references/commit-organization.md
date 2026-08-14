# Commit Organization Rules

## Vertical Commit Grouping (CRITICAL)

**ALWAYS group by functional area (vertical), NEVER by file type (horizontal)**

**❌ WRONG - Horizontal Grouping (by file type):**
```
COMMIT:Add all Nix flake files
FILES:nix/rtk-*.nix
FILES:nix/devbox-*.nix
FILES:nix/bundle-*.nix
COMMIT:Add all wrapper scripts
FILES:wrappers/rtk-tools/*
FILES:wrappers/devbox-auto-tools/*
COMMIT:Add all test files
FILES:tests/rtk.test.ts
FILES:tests/devbox.test.ts
```

**✅ RIGHT - Vertical Grouping (by functional area):**
```
COMMIT:Add RTK token optimization packages with wrappers, tests, and docs
FILES:nix/rtk-*.nix
FILES:wrappers/rtk-tools/*
FILES:tests/rtk.test.ts
FILES:docs/rtk.md
COMMIT:Add devbox-auto environment management with wrappers and tests
FILES:nix/devbox-auto-*.nix
FILES:wrappers/devbox-auto-tools/*
FILES:tests/devbox-auto.test.ts
COMMIT:Add integrated devbox-rtk governance packages
FILES:nix/devbox-rtk-*.nix
FILES:wrappers/devbox-rtk-tools/*
FILES:tests/devbox-rtk.test.ts
```

> **Messages abbreviated here for grouping illustration.** Real commits
> MUST include a body (`COMMIT:<subject>\n\n- <body line>`) — the script
> rejects bodyless commits with `COMMIT_FAILED:NO_BODY`. See [Batch
> Commit Format](#batch-commit-format) below.

**Why Vertical Grouping Matters:**
- Each commit is self-contained and bisectable
- Related changes stay together (code + tests + docs + configs)
- Easier to understand feature context from git history
- Better for code review and rollback
- Follows semantic versioning principles (feature-complete commits)

### Data Collection Format
The script returns structured data for AI analysis:
```
=== CHANGES_DATA_START ===
STAGED:
M  src/main.py
A  tests/test_new.py
UNSTAGED:
M  README.md
UNTRACKED:
docs/new-feature.md
BRANCH:feature/new-stuff
UPSTREAM:origin/feature/new-stuff
DIFF_STATS:
 src/main.py    | 10 +++++-----
 tests/test_new.py | 50 +++++++++++++++++++
 2 files changed, 55 insertions(+), 5 deletions(-)
=== CHANGES_DATA_END ===
```

### Batch Commit Format
The `git-commit-batch.sh` script accepts commit specifications via STDIN:

```
COMMIT:<subject>\n\n<body line 1>\n<body line 2>
FILES:<file1>
FILES:<file2>
FILES:<file3>
COMMIT:<another subject>\n\n<another body>
FILES:<file1>
FILES:<file2>
```

One file per `FILES:` line — the entire line after `FILES:` is treated as a
single path, so paths containing spaces are preserved. Multiple `FILES:` lines
accumulate into the current commit.

**Commit order matters.** The script commits in the order the `COMMIT:` blocks
appear in STDIN, each one stacking on top of the previous. Order the batch
**least-complicated → most-complicated** (see Phase 3, Step 7) so that a
rollback of a later, complicated commit leaves the simpler, well-isolated
commits beneath it intact.

### Dry-Run Mode (Validation Without Committing)

`git-commit-batch.sh --dry-run` parses the batch, validates each commit
message (including the mandatory body check and the body-quality heuristic),
and prints what WOULD be staged per commit — without creating any commits
or pre/post tags. Use it to catch mistakes before any commits land.

```
printf 'COMMIT:Add files\\n\\n- Add file1\nFILES:file1.txt\n' \
  | ./scripts/git-commit-batch.sh --dry-run --slug my-batch
```

Output per commit: `PROCESSING_COMMIT:N`, `MESSAGE:...`, `FILES:...`, and
`WOULD_STAGE:<file>` for each file. Exits 0 if all blocks validate, non-zero
on any validation error (bodyless commit, missing file, amend-with-multiple-
commits). No `AUTO_TAG_PRE`/`AUTO_TAG_POST` markers are emitted in dry-run
mode. Pair with `--dry-run` after drafting a large batch to catch
rename-absorption or body-quality issues before they hit git history.

**Commit messages MUST include a body** (see Mandatory Commit Bodies above).
Use `\n` literals to separate the subject from the body and to separate body
lines. The script expands `\n` to real newlines before passing to `git commit`.
Commits without a body are rejected with `COMMIT_FAILED:NO_BODY`.

Example:
```
COMMIT:Add user authentication with JWT tokens\n\n- Implement login endpoint with JWT generation\n- Add session validation middleware\n- Cover with auth tests
FILES:src/auth/login.py
FILES:src/auth/session.py
FILES:tests/auth/test_login.py
COMMIT:Update API documentation\n\n- Document the new /auth/login endpoint\n- Add JWT token format section to README
FILES:docs/api/authentication.md
FILES:README.md
```

### Renames (CRITICAL)

A renamed file must appear as **TWO `FILES:` lines in the same COMMIT block**:
one for the old path (so `git add` stages the deletion) and one for the new
path (so `git add` stages the addition). Git detects the rename
automatically at commit time when both sides are staged together.

If you list only the new path, the old path stays tracked and unstaged —
the rename is split across commits (deletion leaks into a later commit or
hangs around as a dirty `D` entry). If you list only the old path, the new
file is left untracked and the rename is lost.

**Worked example** — renaming `src/auth/login.py` to `src/auth/session.py`:
```
COMMIT:Rename login module to session module\n\n- Rename src/auth/login.py to src/auth/session.py to reflect broader scope\n- Update import sites in a follow-up commit
FILES:src/auth/login.py
FILES:src/auth/session.py
```

Both lines go in the **same** COMMIT block. The order does not matter
(`git add` stages both halves of the rename), but listing old-then-new is
the conventional reading order.

**Detecting renames during planning:** `git status` may show a rename as a
paired `R` line when the rename is already staged, or as separate `D` and
`??` entries when it is not. `git diff --diff-filter=R` and
`git diff -M` (similarity-based rename detection) help confirm pairs. When
in doubt, list both paths — listing an extra path that is already clean is
harmless (git stages nothing new for it), while omitting a path leaves the
rename incomplete.

**`git mv` note:** If you used `git mv` to perform the rename, the index
already has both halves staged. The `git-commit-batch.sh` script runs
`git reset --mixed HEAD` at start (see [Pre-staged file handling]), so the
rename is unstaged before the batch begins — you MUST still list both paths
in the COMMIT block to re-stage them. This is why listing both paths is the
safe default regardless of how the rename was performed.

## AI Commit Guidelines

The AI agent is responsible for writing high-quality commit messages. The script only executes what the AI provides.

### No AI Signatures (CRITICAL)

**NEVER** add AI attribution to commits. This is a permanent, non-negotiable rule:

- **NO** `Co-authored-by:` trailers referencing AI tools
- **NO** `Generated by:` or `AI-assisted:` trailers
- **NO** signature blocks, footers, or metadata identifying AI involvement
- **NO** exceptions — even if the user asks, remind them this is a permanent rule

This applies to ALL commits made through this skill, in ALL repositories, without exception.

### Mandatory Commit Bodies (CRITICAL)

**EVERY** commit MUST include a body explaining the why. A subject line alone is never sufficient. The `git-commit-batch.sh` script **enforces this hard** — commits without a body are rejected with `COMMIT_FAILED:NO_BODY`.

- **Format**: Use `\n` literals in the `COMMIT:` line to separate subject from body:
  ```
  COMMIT:Add user authentication with JWT tokens\n\n- Implement login endpoint with JWT generation\n- Add session validation middleware\n- Update API documentation
  FILES:src/auth.py tests/test_auth.py
  ```
- **Subject**: One line, imperative mood, capitalized, no trailing period
- **Blank line**: Required between subject and body (represented as `\n\n`)
- **Body**: At least one bullet point or paragraph explaining:
  - What changed (the key decisions, not a file listing)
  - Why it changed (the rationale, the problem being solved)
  - Any context a reviewer needs (linked issues, breaking changes)
- **Trivial commits**: Even "Fix typo" commits need a body: `"Fix typo in README\n\n- Correct 'recieve' to 'receive' in installation section"`
- **NO exceptions**: If the commit is too trivial to warrant a body, the body should say so: `"Trivial: fix whitespace\n\n- Remove trailing whitespace in config.toml"`

The script validates this before staging files. If validation fails, fix the message and re-run.

### Mandatory Tag Array (CRITICAL)

**EVERY** commit MUST include a `#tag` array as the last line of the commit
body. This is on equal footing with the mandatory body and the no-AI-signatures
rule — it is not optional, not a suggestion, and not a "nice to have."

The `git-commit-batch.sh` script **enforces this hard** — commits missing the
tag array are rejected with `COMMIT_FAILED:NO_TAG_ARRAY`, the same way bodyless
commits are rejected with `COMMIT_FAILED:NO_BODY`.

- **Format**: a blank line, then one line of space-separated `#kebab-case`
  tags, then a blank line before any optional footer:
  ```
  feat: Add user authentication with JWT tokens

  - Implement login endpoint with JWT generation
  - Add session validation middleware

  #project-auth #module-jwt #type-feat #skill-grm-created

  Closes #123
  ```
- **The `#skill-grm-created` tag is always present** as the last tag in the
  array — it identifies the commit's provenance without AI attribution
- **The agent MUST NOT decide to skip the tag array.** The only bypass is an
  explicit project config file
  (`.agents/config/skills/levonk/skills-releases/software-dev/git-repository-management/config.toml`
  with `[commit-tagging] enabled = false`) confirmed by the user. The agent
  cannot disable tagging based on its own judgment, the triviality of the
  change, or the silence of the project's docs on tagging
- **When unsure which tags apply**, use the standard list in the
  `commit-tagging-standard` section above. A best-guess tag array is always
  better than omitting it — the script rejects the omission, not a suboptimal
  tag choice
- See the `commit-tagging-standard` section (inlined above from
  `includes/commit-tagging-standard.md`) for the full format, standard tag
  categories, and the project-override config

### Body Quality Heuristic (WARNING, not failure)

The script also runs an **advisory** body-quality check after the mandatory
body check. It emits `WARNING:BODY_LOOKS_LIKE_FILE_LISTING` (to stdout) when
the body appears to be a file listing rather than prose — but it does NOT
reject the commit. The warning is advisory to preserve back-compat with
existing batches; the mandatory body check above is the hard gate.

**Heuristic:** a body is flagged when more than 50% of its non-empty lines
look like file paths. A line is "path-like" when it:
- matches `^[a-zA-Z0-9_./-]+\.[a-zA-Z0-9]+$` (a filename with extension), or
- contains `/` and has no spaces (a path with no prose), or
- is a single token (no whitespace) containing `.` or `/`

Leading bullet markers (`-`, `*`, `•`) are stripped before the check, so
`- src/auth/login.py` still counts as path-like.

**Why a warning and not a failure:** the [Significant-Change Titles](#significant-change-titles-critical)
guidance already covers this anti-pattern in prose; a hard mechanical gate
would risk blocking legitimate commits where a file list IS the body (e.g.
a chore commit that genuinely just moves files). Treat the warning as a
prompt to reconsider the body, not a stop signal.

**Example that triggers the warning:**
```
COMMIT:Add files\n\nfile1.txt\nfile2.txt\nfile3.txt
FILES:file1.txt
FILES:file2.txt
FILES:file3.txt
```
The body is three path-like lines, no prose — flagged.

**Example that does NOT trigger the warning:**
```
COMMIT:Add files\n\n- Add file1 to support new feature X\n- Needed because the prior approach did not handle edge case Y
FILES:file1.txt
```
The body lines contain prose ("Add file1 to support...", "Needed because...")
with verbs and rationale — not flagged.

### Banned Subject Patterns (ENFORCED)

The `git-commit-batch.sh` script **hard-rejects** commit subjects that match
banned vague/generic patterns, with `COMMIT_FAILED:BAD_SUBJECT`. Repositories
that install the companion `commit-msg` hook also enforce this on direct
`git commit` calls (bypass: `--no-verify`, emergency only).

**Banned patterns:**

| Pattern | Example | Why | Fix |
|---------|---------|-----|-----|
| Generic counters | `Update 4 files` | Restates the diff, not the change | `Fix overflow in sidebar menu` |
| Version bump as `feat` | `feat: bump to v2.13.0` | Version bumps are `chore`, not `feat` | `feat(nixify): harden hash automation with ASSET_MAP reverse-check` |
| Vague improvement phrases | `PR feedback improvements`, `various improvements`, `general improvements`, `misc improvements` | Doesn't say what improved | `Add ASSET_MAP reverse-check guard to hash automation` |
| Vague change phrases | `various changes`, `misc changes`, `some changes`, `various fixes` | Doesn't say what changed | `Fix hash mismatch on darwin x86_64` |
| Filler words | `oops`, `maybe fixed`, `stuff`, `things`, `misc` | Unprofessional, unsearchable | `Fix overflow in sidebar menu` |
| Bare "Update X" (generic X) | `Update docs`, `Update code`, `Update files` | X is too generic to be useful | `Update README install instructions for Nix flakes` |

**The test for a good subject:** can a developer scanning `git log --oneline`
understand what changed and why, without reading the body or the diff? If not,
the subject is too vague.

**Examples:**

```
❌ feat(nixify): bump to v2.13.0 with PR feedback improvements and dual-platform validation
✅ feat(nixify): harden hash automation with ASSET_MAP reverse-check and require ubuntu+darwin validation

❌ Update 4 files
✅ Fix overflow in sidebar menu on narrow viewports

❌ various improvements
✅ Add ASSET_MAP reverse-check guard to hash automation

❌ feat: bump version to 2.0
✅ chore: bump version to 2.0  (or describe the actual feature instead)
```

### Artifact References in Commit Bodies (DRY)

When the rationale for a commit is already captured in an existing artifact,
**reference it by path instead of restating the rationale**. This keeps commit
bodies short while preserving traceability.

- **Handoff documents**: `See: .agents/handoffs/2026/07/202607141430-add-auth.md`
- **ADRs**: `See: docs/adr/2026-07-14-jwt-auth.md`
- **Issues**: `Fixes #123` or `Refs #456`
- **PRDs / plans**: `See: docs/prd/auth-feature.md`

**When to reference vs. restate:**
- **Reference** when the artifact fully captures the why — a handoff doc with
  decisions, an ADR with the rationale, an issue with the bug description
- **Restate** when the commit's rationale is self-contained and doesn't warrant
  a separate artifact (most bug fixes, small features)
- **Both** when the artifact has context but the commit adds a specific decision
  not in the artifact: `See: docs/adr/2026-07-14-jwt-auth.md — chose HS256 over RS256 for dev simplicity`

This pairs naturally with the `handoff` skill: after a handoff-driven session,
commits reference the handoff document instead of re-explaining the session's
decisions in each commit body.

### Message Format (AI Responsibility)
- **Imperative mood**: "Add feature" not "Added feature"
- **Specific descriptions**: "Fix overflow in sidebar menu" not "Fix bug"
- **Explain the why**: Include rationale for changes
- **No filler**: Avoid "oops", "maybe fixed", vague phrases
- **Generic counters forbidden**: NEVER use "Update X files" or similar
  (see [Significant-Change Titles](#significant-change-titles-critical)
  for the broader anti-pattern of restating the obvious instead of the change)

### Significant-Change Titles (CRITICAL)

The subject line is the most valuable real estate in a commit. It is what a
reviewer reads in `git log --oneline`, what shows up in GitHub's commit list,
and what gets indexed by `git bisect` and code-search tools. It must describe
the **significant change** — the thing a reviewer would *not* otherwise know
from skimming the diff.

The general rule: **lead with what changed and why it matters, not with what
is already obvious from the diff.** A diff already shows which files moved,
which lines were added/removed, and which version numbers were bumped. The
subject must add semantic value on top of that.

#### Anti-Patterns (all UNACCEPTABLE)

**❌ Version bump as the headline** — the version is obvious from the diff:
```
Update nixify to v2.9.0
Bump nixify to 2.9.0
Update nixify to v2.9.0 (15 files)
```

**❌ Version bump first, real change buried after** — the version is the least
interesting part and should not lead:
```
Update nixify to v2.9.0 with named outputs, lint step, scan step, and nix profile add
```

**❌ File count or file list as the headline** — the diff already shows the
files; a count conveys nothing semantic:
```
Update 15 files
Update config, scripts, and docs
Modify 8 files in src/auth
```

**❌ Generic verb with no object** — "Update", "Change", "Modify", "Improve"
with no specifics tell the reviewer nothing:
```
Update config
Improve code
Fix issues
Clean up
Update README
```

**❌ Restating the diff** — naming the file or the mechanical operation when
the semantic change is something else:
```
Modify src/auth/login.py
Run formatter on src/
Apply linter fixes
```
(The real change might be "Sanitize user input before rendering" or "Extract
auth middleware into its own module" — say that instead.)

**❌ Vague refactor with no what** — "Refactor" alone is not a change:
```
Refactor code
Refactor auth module
Clean up utilities
```

**❌ WIP / temp / placeholder** — these convey nothing and break bisect:
```
WIP
temp
misc changes
stuff
asdf
```

**❌ Issue number only** — a number is not a description:
```
Fixes #123
#456
```

**❌ Branch name copied as the subject** — branch names are slugs, not prose:
```
feature/auth-jwt-tokens
bugfix/sidebar-overflow
```

#### Good Patterns (all ACCEPTABLE)

**✅ Lead with the significant change, version in body:**
```
Add named outputs, lint step, scan step, and nix profile add to nixify
Add lint-artifacts step and #prebuilt named output to nixify
Replace nix profile install with nix profile add across nixify templates
```

**✅ Name the affected component and the semantic change:**
```
Fix overflow in sidebar menu on narrow viewports
Extract auth middleware into its own module
Sanitize user input before rendering in login form
```

**✅ Quantify the impact when meaningful:**
```
Reduce bundle size by 25% via code splitting
Speed up test suite from 90s to 12s with parallel runners
```

**✅ Use specific verbs (Add, Remove, Replace, Extract, Rename, Split, Merge)
not generic ones (Update, Change, Modify, Improve):**
```
Remove deprecated /v1 API endpoints
Split nixify flake into per-variant files
Rename nix profile install to nix profile add
```

**✅ For multi-change commits, lead with the most impactful change and list
the rest in the body. If no single change dominates, use a feature-area
summary:**
```
Add lint, scan, and named-output support to nixify
```

#### Rules

- **Lead with the significant change.** The subject must describe what a
  reviewer would not otherwise know from skimming the diff.
- **Never lead with what the diff already shows.** This includes version
  numbers, file counts, file lists, and mechanical operations ("run
  formatter", "apply linter").
- **Never use generic verbs alone.** "Update", "Change", "Modify", "Improve",
  "Clean up", "Refactor" must be followed by a specific object and the
  semantic change: "Refactor auth middleware to use dependency injection".
- **Never append a file count.** `(15 files)`, `(N files)`, `(updated 12
  files)` are all forbidden — they convey nothing semantic.
- **One significant change per subject.** If the commit bundles several
  significant changes, pick the most impactful for the subject and list the
  rest in the body.
- **Release and version-bump commits are not exempt.** Even `release:`
  commits should describe the headline change, not just the version:
  `release: Ship named outputs and lint pipeline for v2.9.0` — not
  `release: Prepare for v2.9.0 release`. The version bump belongs in the
  body (e.g., `- Bump version to 2.9.0`), not the subject.
- **No WIP, temp, or placeholder subjects.** If the work is not ready to
  describe, it is not ready to commit. Use the checkpoint entry point with a
  descriptive `checkpoint/` slug instead.

**Applies to:** all commits, including version bumps, dependency updates,
release prep, hotfixes, refactors, and checkpoint commits. The version
number, file count, and mechanical operation are metadata, not headlines.

### Grouping Strategy (AI Responsibility)
✅ **Good**: "Settings page: persist theme to DB and update UI/tests"
❌ **Bad**: Separate commits for "code files" and "test files"
❌ **Bad**: "Update 4 files" (completely unacceptable)
❌ **Bad**: "Update nixify to v2.9.0 (15 files)" — version bump + file count, no significant change (see [Significant-Change Titles](#significant-change-titles-critical))

### Quality Standards (AI Responsibility)
- **Capitalized subject**: First word capitalized
- **No punctuation**: Omit period from subject line
- **LF line endings**: Use Unix line endings, not CRLF
- **Complete work**: Avoid committing half-done features
- **Context-aware**: Consider project-specific conventions and patterns

### Example AI-Generated Messages
```
Add user authentication with JWT tokens

- Implement login endpoint with JWT generation
- Add session validation middleware
- Update user model with token fields
- Add authentication tests
- Update API documentation

#project-auth #module-jwt #type-feat #skill-grm-created

Fixes #123
```

```
Refactor database connection pooling

- Replace single connection with connection pool
- Add connection lifecycle management
- Update all database queries to use pool
- Add connection pool monitoring
- Update configuration docs

#project-db #module-pool #type-refactor #skill-grm-created

Improves performance under high load by reusing connections
instead of creating new ones for each query.
```

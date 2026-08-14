# Repository Initialization (Phase 1)

Phase 1 of the workflow handles the case where `git-collect.sh` is invoked on a
directory that is **not** inside a git repository. Rather than failing, the
script emits a structured `NOT_A_GIT_REPO` signal and exits with code 2. The AI
agent then decides whether to initialize the directory via the bundled
`scripts/git-repo-init.bash` before re-running collection.

This phase is **conditional** — it only runs when the target is not a git repo.
For existing repositories, Phase 1 is a no-op and the workflow proceeds
directly to Phase 2 (Data Collection).

## Signal Format

### Text mode (default)

```
=== NOT_A_GIT_REPO ===
PATH:/absolute/path/to/target
INIT_SCRIPT:/path/to/scripts/git-repo-init.bash
INIT_COMMAND:bash "/path/to/scripts/git-repo-init.bash" "/absolute/path/to/target"
ADVICE:Run the init command above to create a git repository here, then re-run git-collect.sh. See references/repository-initialization.md for scope choices (full CREATE mode vs init-only).
=== END NOT_A_GIT_REPO ===
```

### JSON mode (`--json`)

```json
{"not_a_git_repo":true,"path":"/absolute/path/to/target","init_command":"bash \"/path/to/scripts/git-repo-init.bash\" \"/absolute/path/to/target\"","init_script":"/path/to/scripts/git-repo-init.bash"}
```

### Exit code

`2` — distinguishable from generic errors at `1`. The AI agent should check the
exit code (or the `NOT_A_GIT_REPO` marker / `not_a_git_repo` JSON field) before
proceeding.

## AI Decision Points

When the signal fires, the AI agent must decide **whether** to init and **what
scope** to use. Do not auto-run init without considering the context.

### Decision 1: Should this directory become a git repo?

**Init when:**

- The user explicitly asked to "set up", "initialize", or "create" a repo here.
- The directory contains project files (source, configs, docs) that should be
  versioned.
- A dependent skill (`ai-development-loop`, `execute-upsert`) needs a git repo
  to checkpoint before dispatching a subagent.

**Do NOT init when:**

- The directory is a scratch/temp location the user does not want versioned.
- The user intended to run the workflow in a different directory (ask which
  directory they meant).
- The directory is a build output, cache, or other derived artifact location.

When in doubt, ask the user. Initialization creates branches, tags, and
potentially a remote — it is not free to undo.

### Decision 2: Which init scope?

`git-repo-init.bash` auto-detects mode based on the target directory's state.
The AI agent can also pass explicit flags to control scope. Pick the scope that
matches the situation:

#### Full CREATE mode (default for non-git dirs)

Creates a complete project repository scaffold:

- `git init` with the configured default branch
- Initial README commit
- Archive tags (`root`, `pre-init-branches`)
- Environment branches: `env/prod`, `env/stage`, `env/dev`
- Personal user branch: `u/{user}/env/dev`
- Orphan `gh_pages` branch with starter `index.html`
- Origin remote and push of branches + tags (when a remote URL is supplied)

**Use when:** the target is a new project directory that should follow the
standard branch topology. Pass a remote URL to also configure origin and push:

```bash
bash scripts/git-repo-init.bash git@github.com:user/repo.git /path/to/target
```

#### Init-only (minimal: just `git init` + initial commit)

For scratch dirs, quick checkpoints, or when the standard branch topology does
not apply. The bundled `git-repo-init.bash` does not have a clean "init-only"
mode — its `--no-init-structure` flag skips `git init` entirely (leaving no
repo), and `--init-only` forces the full structural init (env branches,
gh_pages, tags). For a minimal init, use plain git commands directly:

```bash
cd /path/to/target
git init -b main
git config user.name "Name"
git config user.email "name@example.com"
git add -A
git commit -m "feat: initial repository setup"
```

**Use when:**

- The directory is a scratch/experiment dir
- A dependent skill just needs *a* git repo to checkpoint against, not the full
  topology
- The user wants a plain repo without the env-branch convention

If you later want the full structural topology on a repo created this way, run
`git-repo-init.bash --init-structure --force` from inside the repo.

#### CONFIG mode (existing repo, identity + remotes)

When the target is *already* a git repo but lacks identity/remote config,
`git-repo-init.bash` auto-detects CONFIG mode and sets `user.name` /
`user.email` plus origin-GH / origin-GL failover remotes. This is idempotent and
safe. The AI agent typically does not need to invoke this directly — it is
reached by running the script on an existing repo.

```bash
bash scripts/git-repo-init.bash --user "Name" --email "name@example.com" /path/to/existing/repo
```

### Decision 3: Re-run collection after init

After `git-repo-init.bash` completes successfully, re-run `git-collect.sh` on
the same target. The directory is now a git repo (with an initial commit), so
Phase 1 passes through to Phase 2 (Data Collection). The freshly-created initial
commit and any structural branches will appear in the collected data.

## Bundled Script

`scripts/git-repo-init.bash` is bundled verbatim from
`levonk/dotfiles` (`home/current/dot_local/bin/executable_git-repo-init.bash`).
It sources `scripts/git-vcs-config.bash` (also bundled) from the same directory.
The bundled copies have chezmoi template expressions stripped to empty-string
defaults; identity (user.name / user.email) is resolved via the standard
fallback chain: CLI args → `git config user.name-default` / `user.email-default`
→ `$USER` / `$USERNAME` env vars.

### Configuration files (optional)

`git-repo-init.bash` reads TOML configuration from:

- `${XDG_CONFIG_HOME:-$HOME/.config}/git/public-vcs.toml`
- `${XDG_DATA_HOME:-$HOME/.local/share}/git/public-vcs.toml`

These are optional — the script uses sensible defaults when the files are
absent. Consumers who want custom default branches, protocols, or account
settings should create these files; see the dotfiles repo for the schema.

### Dry-run

Preview what init would do without touching the filesystem:

```bash
bash scripts/git-repo-init.bash --dry-run -v /path/to/target
```

Always run a dry-run first when the target directory is non-empty and contains
files the user cares about.

### Post-init guidance

After successful initialization, `git-repo-init.bash` prints next-steps
guidance:

1. Start coding on a feature branch
2. Run `git-archive.sh --identify` to find stale branches
3. Add a local remote for offline testing (see below)
4. Install dev environment tooling (`devbox init && just bootstrap`)

### Local-as-Remote Pattern

For testing git operations (push, fetch, branch archiving) without a network
round-trip, add the repo itself as a "local" remote:

```bash
git remote add local "$PWD"
```

This creates a remote pointing at the repo's own `.git` directory. Pushing to
`local` updates local refs directly — no server needed. Use cases:

- Test `git-archive.sh --prune` workflows before running them against `origin`
- Simulate multi-user git operations on a single machine
- Run cleanup scripts that expect a remote to exist
- CI environments where no real remote is available

The `git-vcs-config.bash` library provides an `add_local_remote` helper that
handles the setup idempotently (skips if the remote already exists).

The `git-sweep` project inspired this pattern: it clones the local repo to a
temp directory and uses the clone as a "remote" to detect stale branches
without touching the real upstream.

## Entry Point: Repository Initialization

This phase is reachable as a standalone entry point in addition to being the
first phase of the Full Repository Cleanup workflow. Use the standalone entry
point when the user explicitly asks to "initialize a repo here" or "set up git
in this directory" without requesting the full collect-analyze-commit cycle.

**Handoffs**: 1-2 (collect to detect → optional init → re-collect)

```bash
# 1. Detect whether init is needed (emits NOT_A_GIT_REPO signal if so)
./scripts/git-collect.sh /path/to/target

# 2. If the signal fires, run init with the chosen scope, then re-collect
bash ./scripts/git-repo-init.bash /path/to/target           # full CREATE mode
# or
bash ./scripts/git-repo-init.bash --no-init-structure /path/to/target  # init-only
./scripts/git-collect.sh /path/to/target                    # re-collect after init
```

## Security Considerations

- `git-repo-init.bash` does not handle secrets. It only sets identity, remotes,
  and branch/tag structure.
- The bundled copy has chezmoi template expressions stripped — no user-specific
  data is baked into the skill.
- When passing a remote URL, prefer SSH (`git@github.com:...`) over HTTPS to
  avoid embedding tokens. The script's protocol selection honors
  `public-vcs.toml` when present.
- Never commit the contents of `${XDG_DATA_HOME:-$HOME/.local/share}/git/` —
  it may contain account-specific configuration the user does not want
  published.

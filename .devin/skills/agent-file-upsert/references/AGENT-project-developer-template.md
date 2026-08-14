
# Developer Guide: {project name}

This guide is for developers working on the codebase. For user-facing project overview and install/deploy instructions, see the root [`AGENTS.md`](../../AGENTS.md).

## JIT Index
- Out of Scope: [`internal-docs/oos/`](../../internal-docs/oos/) - What this repo explicitly does NOT do (check before adding features)
- Improvements: [`internal-docs/improvements/INDEX.md`](../../internal-docs/improvements/INDEX.md) - Potential improvements to consider (check before proposing changes to avoid re-proposing already-evaluated improvements)
- Anti-Patterns: [`internal-docs/anti-patterns/INDEX.md`](../../internal-docs/anti-patterns/INDEX.md) - Things explicitly NOT to do (check before implementing changes to avoid re-introducing known-bad approaches)
- Knowledge Bundles: [`.agents/knowledge/bundles/`](../../.agents/knowledge/bundles/) - Offline practice bundles (universal + stack-matched); see root AGENTS.md for the full table including URL-referenced domain bundles

## Setup (Development Environment)

How a contributor stands up a dev environment. This is NOT user-facing install — for that, see `## Install` in the root AGENTS.md.

**Environment Activation (Fresh Shell)**
```bash
# 1. Enter project directory
cd /path/to/project

# 2. Bootstrap environment (auto-detects devbox)
just bootstrap

# 3. Verify environment
just doctor
```

**Build Commands (via just — auto-detecting devbox)**
- Build: `just build`
- Test: `just test`
- Lint: `just lint`
- Typecheck: `just typecheck`
- Dev: `just dev`
- Bootstrap: `just bootstrap`
- Prime: `just prime`
- Doctor: `just doctor`

**Note**: All `just` targets auto-detect the devbox environment via the `_devbox`
helper. If `DEVBOX_SHELL_ENABLED=1` (inside devbox), implementation runs directly.
If not, the target re-execs via `devbox run -- just <target>_impl`. If devbox is
missing, `just doctor` runs automatically to diagnose the issue. AI agents get
fresh shells — `just build` handles everything, no need for `devbox run --` prefix.

## Tech Stack
- devbox:latest - Reproducible development environment
- direnv:latest - Automatic environment activation
- just:latest - Command runner for development tasks
- nx:latest - Monorepo build orchestration and caching
- pnpm:latest - JavaScript/TypeScript package manager
- nodejs:22 - JavaScript runtime 
- typescript:5 - TypeScript compiler 
- [other languages with versions]
</tech-stack>

## <commands>
**Devbox Commands (Environment)**
- `devbox run -- <command>` - Run single command in devbox environment (rarely needed — `just` handles this)
- `devbox add <package>` - Add package to devbox environment
- `devbox shell` - Enter interactive devbox shell

---
description: Shared devbox missing-package remediation guidance — when a required tool/package is missing, add it to devbox.json and run via `devbox run --` instead of installing on the host. Wired into agent-file-upsert's developer.md template so new repositories inherit the logic
---

### Missing Package Remediation

When a command fails with "command not found" or a required tool/package is
missing on the system, do NOT install it on the host. Add it to `devbox.json`
and run the command through devbox:

1. Check whether the tool is already declared in `devbox.json`. If not, add it:
   ```bash
   devbox add <package>      # preferred: updates devbox.json + devbox.lock
   # or edit devbox.json directly for version-pinned packages
   ```
2. Re-run the command via devbox:
   ```bash
   devbox run -- <command>
   ```
3. Prefer `devbox run --` over installing packages on the host system. This
   keeps the environment reproducible and avoids polluting the host.

**Do NOT** install missing tools via `npm`, `brew`, `apt`, `pip install --user`,
`pipx`, `cargo install`, `go install`, or other host-level package managers
unless the tool is explicitly a host-level prerequisite (e.g. devbox/nix
itself, or a system-level binary that cannot live inside devbox). Add it to
`devbox.json` instead and run via `devbox run --`.

**Detection pattern (bash):** before invoking a tool, check availability and
fall back to `devbox run --`:
```bash
if ! command -v <tool> >/dev/null 2>&1 && command -v devbox >/dev/null 2>&1 && [[ -f devbox.json ]]; then
    devbox add <package>   # only if not already in devbox.json
    devbox run -- <tool> "$@"
else
    <tool> "$@"
fi
```

</commands>

## <workflow>
**AI Agent Workflow (Fresh Shell)**
1. Enter project directory: `cd /path/to/project`
2. Activate direnv: `direnv allow && source .envrc`
3. Bootstrap environment: `just bootstrap`
4. Create `feature/{feature-name}`, `fix/{issue-name}`, or `chore/{task-name}` branch from `main`
5. Write failing test first (TDD)
6. Implement feature
7. Run quality gates: `just test && just lint`
8. Fix any failing tests or lint issues
9. Commit changes with conventional commit message
10. Rebase on `main` if diverged
11. Open PR with description

**Testing in /tmp (for boilerplate/features)**
1. Materialize project to `/tmp`: `cd /tmp && copier copy <boilerplate-path> test-project`
2. `cd test-project && direnv allow && source .envrc`
3. `just bootstrap`
4. `just test`
5. Clean up: `rm -rf /tmp/test-project`
</workflow>

## <key-directories>
- `apps/active/` - Working applications
- `apps/icebox/` - Prototype applications
- `packages/active/` - Working packages
- `packages/icebox/` - Prototype packages
- `boilerplates/` - Project templates for copier
- `internal-docs/` - ADRs, architecture documentation
- `scripts/` - Deterministic scripts and workflows
- `.devbox/` - Devbox environment configuration
- `justfile` - Command runner recipes (root and per-project)
- This is a monorepo using NX for build orchestration
- [Add DDD or architectural pattern if applicable]
</key-directories>

## <key-files>
**Core Configuration**
- `justfile` - Command runner recipes (auto-detecting targets + `_impl` implementation targets)
- `devbox.json` - Devbox environment configuration
- `.envrc` - direnv configuration for auto-activation
- `nx.json` - NX workspace configuration
- `package.json` - pnpm workspace configuration
- `pnpm-workspace.yaml` - pnpm workspace definition

**Documentation**
- `AGENTS.md` - Comprehensive agent documentation (PRIMARY)
- `README.md` - Project overview and quick start
- `internal-docs/adr/` - Architecture Decision Records

**Fallback Rules**
- `${XDG_CONFIG_HOME:-$HOME/.config}/ai/rules/rules.md` - Fallback rules if not specified here
</key-files>

## <patterns>
describe your code style and patterns (✅ DO / ❌ DON'T examples)
</patterns>

## <boundaries>
### <always>
- Run tests before committing
- Use TypeScript strict mode for TS projects
- Use `just <command>` for all build/test/lint operations — auto-detects devbox
- Never use `npm` directly, use `pnpm`
- Follow TDD: write failing tests first, then implement
- All features must include comprehensive tests
- All bug fixes must include regression tests
- Activate direnv on first entry: `direnv allow && source .envrc`
</always>
### <ask-first>
- Changes to `/migrations`
- Modifying public APIs
- Reducing functionality without explicit request
- Changing architecture
- Adding new host-level packages outside `devbox.json` (check existing packages first)
- Creating new boilerplates (check existing patterns)
</ask-first>
### <never>
- Commit secrets or credentials
- Delete tests
- Modify vendor directory
- Use `npm` directly
- Skip testing for any change
- Make bandaids - fix root causes
- Use direct nx commands (use just instead)
</never>
</boundaries>

## <known-gotchas>
- **Fresh shell**: AI agents get fresh shells — `just build` auto-detects devbox
  via the `_devbox` helper, so no need for `devbox run --` prefix
- **Justfile pattern**: Normal targets delegate to `_devbox` helper which
  auto-detects `DEVBOX_SHELL_ENABLED`; implementation lives in `*_impl` targets
  (underscore-prefixed, hidden from `just --list`)
- **Doctor is special**: `just doctor` runs directly without `_devbox` — it's
  the fallback when devbox is missing, so it must work without a devbox environment
- **Use just to run nx**: Avoid use of nx directly, always use `just build`,
  `just test`, etc.
- **pnpm only**: Never use `npm` or `yarn` - `pnpm` is only choice for node package management
- **Testing is mandatory**: All changes require tests before completion - no exceptions
- **Missing tools go in devbox.json, not on the host**: When a required tool
  is missing, add it to `devbox.json` and run via `devbox run --`. See
  [Missing Package Remediation](#missing-package-remediation) above for the
  full flow and the list of host-level package managers to avoid (`npm`,
  `brew`, `apt`, `pip install --user`, `pipx`, `cargo install`, `go install`).
</known-gotchas>

## Definition of Done
- [ ] Tests pass: `just test`
- [ ] Lint passes: `just lint`
- [ ] Typecheck passes: `just typecheck`
- [ ] No secrets or credentials committed
- [ ] Conventional commit message used
- [ ] PR describes the "why" not just the "what"
- [ ] Rebased on `main` if diverged
- [ ] Affected AGENTS.md files updated per Maintenance Protocol

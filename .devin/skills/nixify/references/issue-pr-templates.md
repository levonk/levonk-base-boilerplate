# Issue and PR Templates

## Table of Contents

- [Orientation Issue Template](#orientation-issue-template)
- [Pull Request Template](#pull-request-template)
- [Changelog Entry](#changelog-entry)

---

## CRITICAL — How to post these bodies to GitHub (read before any `gh` call)

The templates below contain markdown backticks (`` ` `` and triple-fence ``` ``` ```), shell-style `$VARS` (`$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`), and real newlines. If you pass them to `gh` the wrong way, GitHub stores garbage. Two failure modes have shipped broken PRs/issues in the wild:

1. **Literal `\n` in the body** — happens when you reconstruct the body as a single-line string with `\n` escape sequences (e.g. an LLM-emitted string literal) and pass it to `gh --body "..."`. The `\n` is stored verbatim as two characters, not a newline. The whole post becomes one unreadable line.
2. **Stripped code spans + empty variables** — happens when you feed the body through an unquoted shell heredoc (`cat <<EOF` instead of `cat <<'EOF'`) or `echo "..."`. Backticks get command-substituted (`` `flake.nix` `` runs as a command → empty), and `$UPSTREAM_OWNER` is expanded by the shell to empty.

**Always do this, no exceptions:**

1. Substitute the four placeholders by **text replacement** (not shell expansion): `$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`, and `<issue-number>` / `<platform>` / `<project-name>`. Use `sed -i`/`perl -pi -e` or edit the file in your editor tool — never let bash expand `$UPSTREAM_OWNER`.
2. Write the final body to a **file** (e.g. `/tmp/pr-body.md`).
3. Post with `--body-file`, never `--body`:
   ```bash
   gh pr create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/pr-body.md
   gh issue create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/issue-body.md
   ```
4. Before posting, sanity-check the file: `grep -c '\\n' /tmp/pr-body.md` must return `0` (no literal backslash-n), and `grep -n '`'` must show the backtick code spans intact.

**Never** use `gh ... --body "$BODY"` with an inline string. **Never** use an unquoted heredoc to build the body. The `--body-file` path is the only one that survives multi-line markdown with backticks and `$` intact.

---

## Orientation Issue Template

**CRITICAL**: All content MUST reference the UPSTREAM repository (`$UPSTREAM_OWNER/$UPSTREAM_REPO`), NOT the fork.

```markdown
---
title: feat: add Nix flake support for one-command installation
---

## Summary

This issue tracks adding Nix flake support to the upstream project so users can install and run it without cloning or compiling manually.

## What Nix provides

- **Pure / Hermetic builds**: every input — compiler, libraries, system dependencies — is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible**: the exact same derivation always produces the exact same output bit-for-bit (modulo timestamps). No "works on my machine."
- **Idempotent installs**: running `nix profile install` twice is a no-op. The system reaches the declared state and stays there.
- **Rollback-able**: `nix profile rollback` restores the previous profile generation instantly. Broken update? One command back.
- **Declarative**: the entire build is a single expression (`flake.nix`). No imperative `apt install`, `brew install`, `make` dance.
- **Cross-platform**: same `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` works on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific dependencies.
- **Zero-install runs**: `nix run` fetches from binary cache when available. No clone, no compile, no `cargo build`.
- **No system pollution**: `nix profile install` adds to a user-specific profile. Uninstall cleanly with `nix profile remove`. No orphaned global packages.
- **Atomic upgrades / downgrades**: profiles are switched atomically. No half-upgraded state.

## Current gap

The project currently only documents source builds (`cargo install --path .`, `npm install -g`, etc.). There is no one-command install path for users who already have Nix.

## Proposed change

- Add `flake.nix` with `packages.default` and `apps.default`, plus optional named outputs (`#latest`, `#source`) for version selection. Note: `#vX.Y.Z` (tag-pinning) only works for Source Build Flakes, not Prebuilt Tarball Flakes with a post-release bump workflow.
- Add `devbox.json` for reproducible development environments (if not present)
- Update README install section to include Nix (flakes) and Devbox instructions
- Mirror changes to translated READMEs (e.g., `README.ko.md`)
- Update `docs/getting-started/installation.md` with `### Nix (Flakes)` subsection (if present)
- Update `docs/index.mdx` landing page install splash with Nix option (if present)
- Update `docs/contributing/releasing.md` with Nix flake version/hash update step (if present)

## Branch

`feat-nix-package-manager-install` on the fork.

## Implementation

I have prepared the implementation in my fork at:
https://github.com/$CURRENT_USER/$UPSTREAM_REPO/tree/feat-nix-package-manager-install

The changes include:
- `flake.nix`: Nix flake with `packages.default`, `apps.default`, plus optional named outputs
- `devbox.json`: Devbox configuration for reproducible development environments (if not present)
- `README.md`: added "With Nix (flakes)" and "With Devbox" install subsections
- `README.ko.md`: mirrored the Nix and Devbox install sections (if applicable)
- `docs/getting-started/installation.md`: added `### Nix (Flakes)` subsection (if present)
- `docs/index.mdx`: added Nix code block to install splash (if present)
- `docs/contributing/releasing.md`: added Nix flake update step (if present)

Tested locally with `nix run . -- --help` and `devbox run build`.
```

---

## Pull Request Template

**CRITICAL**: All content MUST reference the UPSTREAM repository (`$UPSTREAM_OWNER/$UPSTREAM_REPO`), NOT the fork.

**Branch on `flake_type` (from Step 11):** The "What" and "Notes" sections differ between Source Build and Prebuilt Tarball flakes. Use the correct variant below. Do NOT include tag-pinning (`github:.../vX.Y.Z`) or `#source` output in a Prebuilt Tarball PR — these do not work for that flake type.

### Source Build Flake (`flake_type = source_build`)

```markdown
---
title: feat: add Nix flake and Devbox support
---

## What

Adds a `flake.nix` so the project can be installed and run directly from GitHub:

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/v1.2.3   # pin a specific release
```

Adds a `devbox.json` for reproducible development environments (if not present):

```bash
devbox shell
devbox run build
```

## Why

The project currently requires users to clone the repository and build from source. For users who already have Nix installed, a flake provides:

- **Pure / Hermetic builds** — every input (compiler, libraries, system dependencies) is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible** — the exact same derivation always produces the exact same output bit-for-bit. No "works on my machine."
- **Idempotent installs** — running `nix profile install` twice is a no-op. The system reaches the declared state and stays there.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly. Broken update? One command back.
- **Declarative** — the entire build is a single expression (`flake.nix`). No imperative `apt install`, `brew install`, `make` dance.
- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Binary cache eligibility** — Nix can pull pre-built artifacts from cache.nixos.org or flakehub when the project is packaged.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific dependencies.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue. No orphaned global packages.

## Changes

- `flake.nix`: Nix flake with `packages.default`, `apps.default`, `overlays.default`, and `checks`
- `devbox.json`: Devbox configuration for reproducible development environments (if not present)
- `.gitignore`: Added Nix build result symlinks
- `.github/workflows/nix.yml`: GitHub Actions CI for Nix validation
- `README.md`: Added Nix installation subsection
- `README.ko.md`: Mirrored Nix installation subsection (if applicable)
- `CHANGELOG.md`: Added changelog entry (if applicable)
- Optional: `nix/modules/` directory with modular structure
- Optional: `nix/modules/hm-module.nix` for home-manager integration
- Optional: `default.nix` and `shell.nix` for legacy Nix support
- Optional: `nix/modules/treefmt.nix` for automated formatting
- Optional: `.github/workflows/cachix.yml` for binary caching

## Testing

Verified locally:

```bash
nix run . -- --help
devbox run build
devbox run test
```

Builds and runs successfully on `<platform>`.

## Notes

- The flake uses `nixpkgs-unstable` and `flake-utils` for broad platform support.
- Darwin builds include `libiconv`; modern `rustPlatform` handles Security framework linking without the deprecated `apple_sdk` compatibility stub.
- No breaking changes to existing build paths.

## Scope

The PR scope is well-contained — additive only, no existing functionality affected.

## Related

Resolves #<issue-number>
```

### Prebuilt Tarball Flake (`flake_type = prebuilt_tarball`)

```markdown
---
title: feat: add Nix flake and Devbox support
---

## What

Adds a `flake.nix` so the project can be installed and run directly from GitHub at the latest release:

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO
```

The flake tracks the default branch and is auto-bumped to the latest release by a daily workflow, so `github:$UPSTREAM_OWNER/$UPSTREAM_REPO` always serves the current release.

Adds a `devbox.json` for reproducible development environments (if not present):

```bash
devbox shell
devbox run build
```

## Why

For users who already have Nix installed, a flake provides:

- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Pure / Hermetic builds** — every input (the prebuilt binary, glibc/libiconv) is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible** — the exact same derivation always produces the exact same output bit-for-bit. No "works on my machine."
- **Idempotent installs** — running `nix profile install` twice is a no-op.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific linking.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue.

## Changes

- `flake.nix`: Nix flake wrapping the prebuilt release tarball as `packages.<system>.default` and `apps.<system>.default`.
- `flake.lock`: pinned `nixpkgs-unstable` input.
- `.github/workflows/nix-release.yml`: scheduled lag-check automation that auto-bumps `version` + per-platform `sha256` hashes and opens a PR when `flake.nix` falls behind the latest release.
- `devbox.json`: Devbox configuration for reproducible development environments (if not present)
- `.gitignore`: Added Nix build result symlinks
- `README.md`: Added Nix installation subsection
- `README.ko.md`: Mirrored Nix installation subsection (if applicable)
- `CHANGELOG.md`: Added changelog entry (if applicable)

## Testing

Verified locally:

```bash
nix flake check --no-build
nix build .
nix run . -- --help
```

Builds and runs successfully on `<platform>`.

## Notes

- The flake wraps the **prebuilt release tarball** rather than building from source, so it stays in sync with releases and avoids a full toolchain in the closure.
- Tag-pinning (`github:.../vX.Y.Z`) is not supported — release tags are cut before the bump workflow updates `flake.nix`. Use `github:.../` (tracks default branch) or pin to a commit SHA.
- No breaking changes to existing build paths.

## Scope

The PR scope is well-contained — additive only, no existing functionality affected.

## Related

Resolves #<issue-number>
```

---

## Changelog Entry

If the project maintains a CHANGELOG.md, add an entry under `## Unreleased` -> `### Added`:

```markdown
### Added
- Added optional Nix flake support for building, running, installing, and developing <project-name> with Nix. (#<issue-number>)
```

**Format guidelines:**
- Use present tense ("Added" not "Adds")
- Reference the issue number if available
- Keep it concise and factual
- Follow the existing changelog style in the project

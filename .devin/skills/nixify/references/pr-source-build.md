---
description: Reusable guard for posting GitHub issue and PR bodies via gh CLI — prevents the two corruption modes (literal \n and stripped backticks) that have shipped broken posts in the wild
---

## CRITICAL — How to post these bodies to GitHub (read before any `gh` call)

The template below contains markdown backticks (`` ` `` and triple-fence ``` ``` ```), shell-style `$VARS` (`$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`), and real newlines. If you pass it to `gh` the wrong way, GitHub stores garbage. Two failure modes have shipped broken PRs/issues in the wild:

1. **Literal `\n` in the body** — happens when you reconstruct the body as a single-line string with `\n` escape sequences (e.g. an LLM-emitted string literal) and pass it to `gh --body "..."`. The `\n` is stored verbatim as two characters, not a newline. The whole post becomes one unreadable line.
2. **Stripped code spans + empty variables** — happens when you feed the body through an unquoted shell heredoc (`cat <<EOF` instead of `cat <<'EOF'`) or `echo "..."`. Backticks get command-substituted (`` `flake.nix` `` runs as a command → empty), and `$UPSTREAM_OWNER` is expanded by the shell to empty.

**Always do this, no exceptions:**

1. Substitute the placeholders by **text replacement** (not shell expansion): `$UPSTREAM_OWNER`, `$UPSTREAM_REPO`, `$CURRENT_USER`, and any `<issue-number>` / `<platform>` / `<project-name>` / `<feature-name>` placeholders. Use `sed -i`/`perl -pi -e` or edit the file in your editor tool — never let bash expand `$UPSTREAM_OWNER`.
2. Write the final body to a **file** (e.g. `/tmp/pr-body.md` or `/tmp/issue-body.md`).
3. Post with `--body-file`, never `--body`:
   ```bash
   gh pr create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/pr-body.md
   gh issue create --repo "$UPSTREAM_OWNER/$UPSTREAM_REPO" --title "..." --body-file /tmp/issue-body.md
   ```
4. Before posting, sanity-check the file: `grep -c '\\n' /tmp/pr-body.md` must return `0` (no literal backslash-n), and `grep -n '`'` must show the backtick code spans intact.

**Never** use `gh ... --body "$BODY"` with an inline string. **Never** use an unquoted heredoc to build the body. The `--body-file` path is the only one that survives multi-line markdown with backticks and `$` intact.


---

<!-- Variant: Source Build Flake (flake_type=source_build, devbox included) -->
<!-- CRITICAL: All content MUST reference the UPSTREAM repository ($UPSTREAM_OWNER/$UPSTREAM_REPO), NOT the fork. -->

<!-- Template body follows. Copy everything below this comment as the PR body. -->

---
title: feat: add Nix flake and Devbox support
---

## What

Adds a `flake.nix` so the project can be installed and run directly from GitHub:

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO
nix profile add github:$UPSTREAM_OWNER/$UPSTREAM_REPO
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
- **Idempotent installs** — running `nix profile add` twice is a no-op. The system reaches the declared state and stays there.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly. Broken update? One command back.
- **Declarative** — the entire build is a single expression (`flake.nix`). No imperative `apt install`, `brew install`, `make` dance.
- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Binary cache eligibility** — Nix can pull pre-built artifacts from cache.nixos.org or flakehub when the project is packaged.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific dependencies.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue. No orphaned global packages.
- **NixOS / home-manager compatible** — `npm install -g` doesn't work on NixOS's read-only store; a flake with `packages.default` lets NixOS users install declaratively via `home.packages` in home-manager.

<!-- BEGIN conditional: Relationship to nixpkgs -->
<!-- INCLUDE this section ONLY when check-nixpkgs.sh (Step 10) reported project_in_nixpkgs: true. -->
<!-- If project_in_nixpkgs: false, DELETE everything from "BEGIN conditional" to "END conditional". -->
<!-- Fill $PROJECT, $NIXPKGS_VERSION, $LATEST_RELEASE, $NIXPKGS_DARWIN_STABLE_VERSION from Step 10 -->
<!-- output and the latest GitHub release (check-releases.sh, Step 4). -->
<!-- Pick the correct x86_64-darwin clause based on x86_64_darwin_in_meta and delete the other. -->

## Relationship to nixpkgs

This project is already in nixpkgs as `nixpkgs#$PROJECT` (currently `$NIXPKGS_VERSION` on unstable; latest release is `$LATEST_RELEASE`). This flake is complementary, not redundant:

- **Faster release cadence** — the flake tracks the project's own releases directly; nixpkgs follows its own staging schedule (days to weeks behind).
- **Tag-pinning that works** — source-build flakes exist at every git tag, so `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/vX.Y.Z` serves that exact version. nixpkgs only exposes the version its channel currently ships — older versions are gone once the channel moves.
- **Reproducible dev environment** — `devbox.json` + `devShells.default` pin the project's own toolchain; nixpkgs does not provide a per-project dev shell.
- **`x86_64-darwin` at the latest version** — nixpkgs's `meta.platforms` does not declare `x86_64-darwin`<!-- ALTERNATIVE if x86_64_darwin_in_meta=true: declares `x86_64-darwin` but the stable darwin channel ships an older version -->; the flake's `nixpkgs-darwin-legacy` pin builds it at the latest release, where the nixpkgs darwin stable channel ships `$NIXPKGS_DARWIN_STABLE_VERSION`.
- **Shorter supply chain** — builds directly from `$UPSTREAM_OWNER/$UPSTREAM_REPO`'s source, one fewer packaging layer to audit.

`nix profile add nixpkgs#$PROJECT` still works and this flake does not replace it.

<!-- END conditional: Relationship to nixpkgs -->

<!-- BEGIN conditional: nixpkgs Output -->
<!-- INCLUDE this section ONLY when add_nixpkgs_output=true (Step 11b). -->
<!-- If add_nixpkgs_output=false, DELETE everything from "BEGIN conditional" to "END conditional". -->
<!-- Fill $PROJECT from check-nixpkgs.sh (Step 10). -->

## nixpkgs output

The flake also exposes a `#nixpkgs` output that wraps the nixpkgs-packaged version of this project:

```bash
nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO#nixpkgs
nix profile install github:$UPSTREAM_OWNER/$UPSTREAM_REPO#nixpkgs
```

The nixpkgs packaging includes distribution patches, postInstall hooks, and runtime dependency setup that a naive from-source flake would miss. The `#nixpkgs` output gives users access to this more complete packaging alongside the from-source `#source` output. Users who want the latest version from source use `#source` or `#default`; users who want the nixpkgs-packaged version with its patches and hooks use `#nixpkgs`.

<!-- END conditional: nixpkgs Output -->

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
<!-- BEGIN conditional: Garnix CI -->
<!-- INCLUDE this line ONLY when include_garnix=true (Step 16c). -->
<!-- If include_garnix=false, DELETE this comment block and the line below it. -->
- `garnix.yaml`: Configuration for [Garnix](https://garnix.io) hosted CI (optional — activates when the maintainer installs the Garnix GitHub App; builds all flake outputs across platforms with FOD hash-rot detection)
<!-- END conditional: Garnix CI -->

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

<!-- BEGIN conditional: Platform Scope (Inherent Platform Specificity) -->
<!-- INCLUDE this section ONLY when platform_scope is "darwin_only" or "linux_only" (Step 4a). -->
<!-- If platform_scope=all, DELETE everything from "BEGIN conditional" to "END conditional". -->
<!-- Fill $SCOPE_FAMILY ("macOS" or "Linux") and $EXCLUDED_FAMILY ("Linux" or "macOS") -->
<!-- from detect-platform-scope.sh (Step 4a) output. -->

## Platform scope

This project is inherently `$SCOPE_FAMILY`-only — it depends on platform-specific APIs (`$SCOPE_RATIONALE`) that are not available on `$EXCLUDED_FAMILY`. The flake targets only `$SCOPE_FAMILY` Nix systems (`$TARGET_PLATFORMS`); users on `$EXCLUDED_FAMILY` will see "package not available for this system" when attempting `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO`, which is correct — the software cannot run on `$EXCLUDED_FAMILY` by design, not due to a flake limitation. Cross-compilation is not attempted because the required platform APIs do not exist on the target.

<!-- END conditional: Platform Scope (Inherent Platform Specificity) -->

## Scope

The PR scope is well-contained — additive only, no existing functionality affected.

## Related

Resolves #<issue-number>

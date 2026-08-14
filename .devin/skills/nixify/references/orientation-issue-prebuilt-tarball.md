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

<!-- Variant: Prebuilt Tarball (flake_type=prebuilt_tarball, no devbox) -->
<!-- CRITICAL: All content MUST reference the UPSTREAM repository ($UPSTREAM_OWNER/$UPSTREAM_REPO), NOT the fork. -->

<!-- Template body follows. Copy everything below this comment as the issue body. -->

---
title: feat: add Nix flake support for one-command installation
---

## Summary

This issue tracks adding Nix flake support to the upstream project so users can install and run it without cloning or compiling manually.

## What Nix provides

- **One-command install / run** — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` with no clone or manual build steps.
- **Pure / Hermetic builds** — every input (the prebuilt binary, glibc/libiconv) is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible** — the exact same derivation always produces the exact same output bit-for-bit. No "works on my machine."
- **Idempotent installs** — running `nix profile add` twice is a no-op.
- **Rollback-able** — `nix profile rollback` restores the previous profile generation instantly.
- **Cross-platform** — same invocation on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific linking.
- **Atomic upgrades / downgrades** — profiles are switched atomically. No half-upgraded state.
- **Clean uninstall** — `nix profile remove` leaves no residue.
- **NixOS / home-manager compatible** — `npm install -g` doesn't work on NixOS's read-only store; a flake with `packages.default` lets NixOS users install declaratively via `home.packages` in home-manager.

## Current gap

The project currently only documents source builds (`cargo install --path .`, `npm install -g`, etc.). There is no one-command install path for users who already have Nix.

<!-- BEGIN conditional: Relationship to nixpkgs -->
<!-- INCLUDE this section ONLY when check-nixpkgs.sh (Step 10) reported project_in_nixpkgs: true. -->
<!-- If project_in_nixpkgs: false, DELETE everything from "BEGIN conditional" to "END conditional". -->
<!-- Fill $PROJECT, $NIXPKGS_VERSION, $LATEST_RELEASE, $NIXPKGS_DARWIN_STABLE_VERSION from Step 10 -->
<!-- output and the latest GitHub release (check-releases.sh, Step 4). -->
<!-- Pick the correct x86_64-darwin clause based on x86_64_darwin_in_meta and delete the other. -->

## Relationship to nixpkgs

This project is already packaged in nixpkgs (`nixpkgs#$PROJECT`), so a reasonable question is why a repo-owned flake is worth adding on top of it. The flake is complementary, not redundant:

- **Faster release cadence.** nixpkgs ships `$NIXPKGS_VERSION` on the unstable channel; the latest upstream release is `$LATEST_RELEASE`. nixpkgs updates on its own staging schedule (days to weeks behind upstream, longer on the stable channel). The flake's hash-automation workflow bumps to the latest release within ~24 hours of publication, so `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` always serves the current release.
- **Release install option (`#prebuilt`).** The flake serves the official prebuilt release tarball directly from GitHub Releases — no compilation, no nixpkgs build toolchain in the path. Users who want the exact artifact the project ships get it via `nix run .#prebuilt`.
- **Source install option (`#source`).** The flake also builds from source for users who want reproducibility or auditability without depending on nixpkgs's packaging decisions.
- **Broader platform support.** nixpkgs's `meta.platforms` for `$PROJECT` does not declare `x86_64-darwin`<!-- ALTERNATIVE if x86_64_darwin_in_meta=true: declares `x86_64-darwin` but the stable darwin channel ships an older version -->; the flake's `nixpkgs-darwin-legacy` pin builds on `x86_64-darwin` at the latest version, where the nixpkgs darwin stable channel ships `$NIXPKGS_DARWIN_STABLE_VERSION` (older).
- **Shorter supply chain.** The flake fetches directly from `$UPSTREAM_OWNER/$UPSTREAM_REPO`'s GitHub Releases — one fewer packaging layer to audit and trust.

`nix profile add nixpkgs#$PROJECT` remains a valid install path and this flake does not replace it. The two coexist: users who prefer nixpkgs's curation keep using it; users who want the latest release, the prebuilt path, or `x86_64-darwin` at current versions use the flake.

<!-- END conditional: Relationship to nixpkgs -->

<!-- BEGIN conditional: nixpkgs Output -->
<!-- INCLUDE this clause ONLY when add_nixpkgs_output=true (Step 11b). -->
<!-- If add_nixpkgs_output=false, DELETE this comment block and the line below it. -->
- Add a `#nixpkgs` output that wraps the nixpkgs-packaged version — the nixpkgs packaging includes distribution patches, postInstall hooks, and runtime dependency setup that a naive from-source flake would miss. Users can choose between `#prebuilt` (official release binary), `#source` (from-source build), `#nixpkgs` (nixpkgs-packaged version with patches), and `#default` (alias for `#prebuilt`).
<!-- END conditional: nixpkgs Output -->

## Proposed change

- Add `flake.nix` with `packages.prebuilt` and `packages.source` (plus `packages.default` aliasing `prebuilt`), so users can choose between the fast prebuilt path (`nix run .#prebuilt`) and the reproducible-from-source path (`nix run .#source`).
<!-- BEGIN conditional: Hybrid Fallback (Partial Platform Coverage) -->
<!-- INCLUDE this clause ONLY when hybrid_fallback=true (Step 12). -->
<!-- If hybrid_fallback=false, DELETE this comment block and the line below it. -->
<!-- Fill $PREBUILT_PLATFORMS and $FALLBACK_PLATFORMS from check-releases.sh (Step 4b) platform_coverage. -->
- The project ships prebuilt binaries for `$PREBUILT_PLATFORMS` but not `$FALLBACK_PLATFORMS`. The flake uses a hybrid fallback: `#default` uses the prebuilt binary where available and builds from source on `$FALLBACK_PLATFORMS`, so `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` works on every buildable platform. `#prebuilt` is only exposed on platforms with a release asset; `#source` is available on all buildable platforms.
<!-- END conditional: Hybrid Fallback (Partial Platform Coverage) -->
<!-- BEGIN conditional: Platform Scope (Inherent Platform Specificity) -->
<!-- INCLUDE this clause ONLY when platform_scope is "darwin_only" or "linux_only" (Step 4a). -->
<!-- If platform_scope=all, DELETE this comment block and the line below it. -->
<!-- Fill $SCOPE_FAMILY ("macOS" or "Linux") and $EXCLUDED_FAMILY from detect-platform-scope.sh (Step 4a). -->
- The project is inherently `$SCOPE_FAMILY`-only (`$SCOPE_RATIONALE`). The flake targets only `$SCOPE_FAMILY` Nix systems; users on `$EXCLUDED_FAMILY` will see "package not available" — this is correct, as the software cannot run on `$EXCLUDED_FAMILY` by design. Cross-compilation is not attempted.
<!-- END conditional: Platform Scope (Inherent Platform Specificity) -->
- Add a scheduled GitHub Action that auto-bumps `version` and refreshes per-platform `sha256` hashes when a new release is cut.
- Update README install section to include Nix (flakes) instructions
- Mirror changes to translated READMEs (e.g., `README.ko.md`)
- Update `docs/getting-started/installation.md` with `### Nix (Flakes)` subsection (if present)
- Update `docs/index.mdx` landing page install splash with Nix option (if present)
- Update `docs/contributing/releasing.md` with Nix flake version/hash update step (if present)
<!-- BEGIN conditional: Garnix CI -->
<!-- INCLUDE this clause ONLY when include_garnix=true (Step 16c). -->
<!-- If include_garnix=false, DELETE this comment block and the line below it. -->
- Add `garnix.yaml` for optional [Garnix](https://garnix.io) hosted CI — builds all flake outputs across platforms with FOD hash-rot detection. Inert until the maintainer installs the Garnix GitHub App; the required `.github/workflows/nix.yml` remains the contributor-controlled CI.
<!-- END conditional: Garnix CI -->

## Branch

`feat-nix-package-manager-install` on the fork.

## Implementation

I have prepared the implementation in my fork at:
https://github.com/$CURRENT_USER/$UPSTREAM_REPO/tree/feat-nix-package-manager-install

The changes include:
- `flake.nix`: Nix flake exposing `packages.<system>.prebuilt` (prebuilt binary), `packages.<system>.source` (from-source build), and `packages.<system>.default` (alias for `prebuilt`), with matching `apps` outputs
- `flake.lock`: pinned `nixpkgs-unstable` input
- `.github/workflows/nix-release.yml`: scheduled lag-check automation that auto-bumps `version` + per-platform `sha256` hashes
- `.github/workflows/nix.yml`: GitHub Actions CI for Nix validation
- `README.md`: added "With Nix (flakes)" install subsection
- `README.ko.md`: mirrored the Nix install section (if applicable)
- `docs/getting-started/installation.md`: added `### Nix (Flakes)` subsection (if present)
- `docs/index.mdx`: added Nix code block to install splash (if present)
- `docs/contributing/releasing.md`: added Nix flake update step (if present)
<!-- BEGIN conditional: Garnix CI -->
<!-- INCLUDE this line ONLY when include_garnix=true (Step 16c). -->
<!-- If include_garnix=false, DELETE this comment block and the line below it. -->
- `garnix.yaml`: configuration for optional Garnix hosted CI
<!-- END conditional: Garnix CI -->

Tested locally with `nix run . -- --help`.

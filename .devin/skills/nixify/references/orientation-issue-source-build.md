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

<!-- Variant: Source Build (flake_type=source_build, devbox always included) -->
<!-- CRITICAL: All content MUST reference the UPSTREAM repository ($UPSTREAM_OWNER/$UPSTREAM_REPO), NOT the fork. -->

<!-- Template body follows. Copy everything below this comment as the issue body. -->

---
title: feat: add Nix flake and Devbox support
---

## Summary

This issue tracks adding Nix flake support to the upstream project so users can install and run it without cloning or compiling manually.

## What Nix provides

- **Pure / Hermetic builds**: every input — compiler, libraries, system dependencies — is pinned in `flake.lock`. If it builds today, it builds in ten years.
- **Reproducible**: the exact same derivation always produces the exact same output bit-for-bit (modulo timestamps). No "works on my machine."
- **Idempotent installs**: running `nix profile add` twice is a no-op. The system reaches the declared state and stays there.
- **Rollback-able**: `nix profile rollback` restores the previous profile generation instantly. Broken update? One command back.
- **Declarative**: the entire build is a single expression (`flake.nix`). No imperative `apt install`, `brew install`, `make` dance.
- **Cross-platform**: same `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` works on macOS (Apple Silicon & Intel) and Linux. The flake handles platform-specific dependencies.
- **Zero-install runs**: `nix run` fetches from binary cache when available. No clone, no compile, no `cargo build`.
- **No system pollution**: `nix profile add` adds to a user-specific profile. Uninstall cleanly with `nix profile remove`. No orphaned global packages.
- **Atomic upgrades / downgrades**: profiles are switched atomically. No half-upgraded state.
- **NixOS / home-manager compatible**: `npm install -g` doesn't work on NixOS's read-only store; a flake with `packages.default` lets NixOS users install declaratively via `home.packages` in home-manager.

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

- **Faster release cadence.** nixpkgs ships `$NIXPKGS_VERSION` on the unstable channel; the latest upstream release is `$LATEST_RELEASE`. nixpkgs updates on its own staging schedule (days to weeks behind upstream, longer on the stable channel). A repo-owned flake tracks the project's own releases directly — `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO` at a tag serves that exact release, with no nixpkgs staging lag.
- **Tag-pinning that works.** Source-build flakes exist at every git tag, so `nix run github:$UPSTREAM_OWNER/$UPSTREAM_REPO/vX.Y.Z` serves the exact version a user asks for. nixpkgs only exposes the version its unstable or stable channel currently ships — older tags are gone once the channel moves.
- **Reproducible dev environment.** The flake ships a `devShells.default` (and a `devbox.json`) so contributors get the exact toolchain the project builds with, pinned in `flake.lock`. nixpkgs does not provide a per-project dev shell.
- **Broader platform support.** nixpkgs's `meta.platforms` for `$PROJECT` does not declare `x86_64-darwin`<!-- ALTERNATIVE if x86_64_darwin_in_meta=true: declares `x86_64-darwin` but the stable darwin channel ships an older version -->; the flake's `nixpkgs-darwin-legacy` pin builds on `x86_64-darwin` at the latest version, where the nixpkgs darwin stable channel ships `$NIXPKGS_DARWIN_STABLE_VERSION` (older).
- **Shorter supply chain.** The flake builds directly from `$UPSTREAM_OWNER/$UPSTREAM_REPO`'s source — one fewer packaging layer to audit and trust.

`nix profile add nixpkgs#$PROJECT` remains a valid install path and this flake does not replace it. The two coexist: users who prefer nixpkgs's curation keep using it; users who want tag-pinning, the project's own dev shell, or `x86_64-darwin` at current versions use the flake.

<!-- END conditional: Relationship to nixpkgs -->

<!-- BEGIN conditional: nixpkgs Output -->
<!-- INCLUDE this clause ONLY when add_nixpkgs_output=true (Step 11b). -->
<!-- If add_nixpkgs_output=false, DELETE this comment block and the line below it. -->
- Add a `#nixpkgs` output that wraps the nixpkgs-packaged version — the nixpkgs packaging includes distribution patches, postInstall hooks, and runtime dependency setup that a naive from-source flake would miss. Users can choose between `#source` (from-source build), `#nixpkgs` (nixpkgs-packaged version with patches), and `#default` (alias for `#source`).
<!-- END conditional: nixpkgs Output -->

## Proposed change

- Add `flake.nix` with `packages.default` and `apps.default`, plus optional named outputs (`#latest`, `#source`) for version selection. Note: `#vX.Y.Z` (tag-pinning) only works for Source Build Flakes, not Prebuilt Tarball Flakes with a post-release bump workflow.
- Add `devbox.json` for reproducible development environments (if not present)
<!-- BEGIN conditional: Platform Scope (Inherent Platform Specificity) -->
<!-- INCLUDE this clause ONLY when platform_scope is "darwin_only" or "linux_only" (Step 4a). -->
<!-- If platform_scope=all, DELETE this comment block and the line below it. -->
<!-- Fill $SCOPE_FAMILY ("macOS" or "Linux") and $EXCLUDED_FAMILY from detect-platform-scope.sh (Step 4a). -->
- The project is inherently `$SCOPE_FAMILY`-only (`$SCOPE_RATIONALE`). The flake targets only `$SCOPE_FAMILY` Nix systems; users on `$EXCLUDED_FAMILY` will see "package not available" — this is correct, as the software cannot run on `$EXCLUDED_FAMILY` by design. Cross-compilation is not attempted.
<!-- END conditional: Platform Scope (Inherent Platform Specificity) -->
- Update README install section to include Nix (flakes) and Devbox instructions
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
- `flake.nix`: Nix flake with `packages.default`, `apps.default`, plus optional named outputs
- `devbox.json`: Devbox configuration for reproducible development environments
- `README.md`: added "With Nix (flakes)" and "With Devbox" install subsections
- `README.ko.md`: mirrored the Nix and Devbox install sections (if applicable)
- `docs/getting-started/installation.md`: added `### Nix (Flakes)` subsection (if present)
- `docs/index.mdx`: added Nix code block to install splash (if present)
- `docs/contributing/releasing.md`: added Nix flake update step (if present)
<!-- BEGIN conditional: Garnix CI -->
<!-- INCLUDE this line ONLY when include_garnix=true (Step 16c). -->
<!-- If include_garnix=false, DELETE this comment block and the line below it. -->
- `garnix.yaml`: configuration for optional Garnix hosted CI
<!-- END conditional: Garnix CI -->

Tested locally with `nix run . -- --help` and `devbox run build`.

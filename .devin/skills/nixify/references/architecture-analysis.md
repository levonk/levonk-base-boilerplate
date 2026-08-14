# Architecture Analysis

## Table of Contents

- [Inherent Platform Scope](#inherent-platform-scope)
- [Check for Prebuilt Release Tarballs](#check-for-prebuilt-release-tarballs)
- [Partial Platform Coverage](#partial-platform-coverage)
- [Complex Distribution Requirements](#complex-distribution-requirements)
- [Success and Failure Patterns](#success-and-failure-patterns)
- [Make Build Scripts Nix-Aware](#make-build-scripts-nix-aware)
- [Ensure Lockfiles in npm Tarballs](#ensure-lockfiles-in-npm-tarballs)
- [Inspecting Existing nixpkgs Derivations](#inspecting-existing-nixpkgs-derivations)
- [nixpkgs Superset Comparison](#nixpkgs-superset-comparison)
- [Build-Time Network Fetches](#build-time-network-fetches)
- [Gitignored Lockfiles](#gitignored-lockfiles)
- [Postinstall Home-Directory Writes](#postinstall-home-directory-writes)

---

## Inherent Platform Scope

> **Knowledge base**: The canonical concept page for this practice is
> [`inherent-platform-scope`](../included/knowledge/nix-build-practices/inherent-platform-scope.md)
> in the `nix-build-practices` bundle. This section is the skill-specific
> operational guidance; the bundle page is the compounding reference.

**CRITICAL**: Before checking for prebuilt tarballs or computing platform
coverage, determine whether the project is inherently platform-specific. Some
software only runs on one OS family by design — a macOS menu-bar app cannot
run on Linux (no AppKit/Cocoa), and a GRUB/systemd tool cannot run on Darwin
(no Linux kernel ABI). For such projects, the flake should target only the
platforms the software actually supports, rather than the default 4-system
set. Narrowing scope is NOT a coverage gap — it is the project's correct
release policy.

**How to detect**: Run `scripts/detect-platform-scope.sh <project-dir>`. The
script inspects CI matrix (`.github/workflows/*.yml` `runs-on:` / `matrix.os:`),
Rust manifests (`Cargo.toml`/`Cargo.lock` for `cocoa`, `objc`, `systemd`,
etc.), Swift source files (`import SwiftUI/AppKit/UIKit`), Go build tags
(`//go:build linux` / `//go:build darwin`), Node.js native deps, and
README/docs for platform-defining signals. It reports:

- `target_platforms`: JSON array subset of the 4 Nix systems
- `platform_scope`: `all`, `darwin_only`, or `linux_only`
- `confidence`: `high`, `medium`, or `low`
- `signals`: array of `{ signal, scope, source, confidence }`
- `rationale`: human-readable summary

**Decision tree:**

- **`platform_scope=all`** (the common case): The project is cross-platform
  or has no platform-narrowing signals. Proceed with the default 4-system
  target set. No special handling needed downstream.
- **`platform_scope=darwin_only` or `linux_only` with `confidence=high`**: A
  high-confidence signal (e.g. CI matrix only runs on macOS, or Swift source
  imports AppKit) with no signals for the other OS family. The flake targets
  only the detected family. Do NOT attempt cross-compilation to the excluded
  family — a from-source build of a Cocoa app on Linux is impossible (no
  AppKit), and a systemd service on Darwin is impossible (no Linux ABI).
- **`platform_scope=darwin_only` or `linux_only` with `confidence=medium`**:
  Multiple medium-confidence signals (e.g. `cocoa` crate + README says "macOS
  only") but no single definitive one. Present the detection result to the
  user with the `rationale` and `signals` list, and confirm before narrowing
  scope. The user may know the project is cross-platform despite the signals.
- **`confidence=low`** (conflicting signals): Keep `platform_scope=all` and
  proceed with the 4-system default. Do not narrow scope on conflicting
  evidence.

**Manual override**: If the user explicitly states the project is
platform-specific (or cross-platform despite detection), honor their input
over the script. Set `target_platforms` and `platform_scope` accordingly and
note the override in the PR body.

**What NOT to do:**

- Do NOT attempt cross-compilation to fill the "missing" platform. A Mac
  toolbar app doesn't need a Linux build — the Linux build would fail or
  produce a broken binary. The "missing" platform is correct by design.
- Do NOT use the hybrid fallback variant to fill inherent-scope gaps. The
  hybrid fallback is for projects that *could* build on the missing platform
  but just don't ship a prebuilt binary for it. An inherently darwin-only
  project cannot build on Linux at all.
- Do NOT ignore the detection and target all 4 systems anyway. A flake that
  advertises Linux support for a macOS-only app will fail to build on Linux,
  which is worse than honestly declaring darwin-only support.

**Downstream consumption:**

- `target_platforms` is passed to `check-releases.sh` (Step 4b) as the third
  argument, so `partial_platform_coverage` is computed relative to the
  project's scope, not the hardcoded 4-system set.
- At Step 12, the flake's `allSystems`, `assets`, and `meta.platforms` are
  scoped to `target_platforms`.
- At Steps 24 and 27, the PR/issue templates include a "Platform scope"
  clause when `platform_scope` is not `all`, pre-empting the "why no
  Linux/macOS?" review comment.

**Examples:**

- **macOS menu-bar app** (Swift, imports AppKit): `platform_scope=darwin_only`,
  `target_platforms=["x86_64-darwin","aarch64-darwin"]`. The flake targets
  darwin only. A Linux user who tries `nix run github:...` gets "package not
  available for this system" — correct, because the app cannot run on Linux.
- **systemd service manager** (Rust, depends on `systemd` crate): `platform_scope=linux_only`,
  `target_platforms=["x86_64-linux","aarch64-linux"]`. The flake targets Linux
  only. A macOS user gets "package not available" — correct, because the tool
  needs the Linux kernel ABI.
- **CLI tool written in Rust** (no platform-specific deps, CI runs on both
  ubuntu and macos): `platform_scope=all`, `target_platforms` = all 4
  systems. The flake targets all 4 platforms as before — no narrowing.

---

## Check for Prebuilt Release Tarballs

**CRITICAL**: Before proceeding with a source build, check if the project publishes prebuilt release tarballs. This is the preferred approach as it preserves exact layout and avoids complex builds.

```bash
curl -s "https://api.github.com/repos/<owner>/<repo>/releases/latest" | jq -r '.assets[].name'
curl -s "https://api.github.com/repos/<owner>/<repo>/releases" | jq -r '.[].assets[].name' | grep -E "(linux|darwin|windows|musl)"
```

**If prebuilt release tarballs exist:**
- Use fetchurl approach (see `references/flake-templates/prebuilt-tarball.md`)
- Extract and preserve exact layout (bin/ + runtime/ as siblings)
- Add explicit SHA256 hashes for each platform's tarball

**If no prebuilt tarballs exist:**
- Fall back to build from source or defer as tracked follow-up

**CRITICAL — prebuilt is MANDATORY, not just "preferred", when the binary resolves runtime assets beside itself.** Even if the project *also* builds cleanly from source, a from-source flake is broken (not merely suboptimal) when any of these hold:
- The binary walks up from `current_exe()` to find a sibling `runtime/`, `assets/`, or `resources/` directory (e.g. nub resolves `runtime/preload.mjs` beside its binary).
- The release tarball carries a vendored `node_modules/`, a N-API addon (`.node`), or other native artifacts produced by a separate build step the flake does not reproduce.
- A bare `cargo build` / `go build` / `npm run build` produces a binary that passes `--version` but fails real workloads because the runtime tree is absent.

A from-source `buildRustPackage` for such a project produces a binary that passes `nix run . -- --version` in CI but is non-functional for real use. Prefer the prebuilt tarball even when source builds are possible. (Reference: nubjs/nub#169 — prebuilt chosen precisely because from-source omits the vendored `runtime/` tree.)

---

## Partial Platform Coverage

> **Knowledge base**: The canonical concept page for this practice is
> [`partial-platform-coverage`](../included/knowledge/nix-build-practices/partial-platform-coverage.md)
> in the `nix-build-practices` bundle. This section is the skill-specific
> operational guidance; the bundle page is the compounding reference.

**CRITICAL**: After confirming prebuilt tarballs exist, check whether the project
ships prebuilt binaries for **all** of its `target_platforms` (from Step 4a's
`detect-platform-scope.sh`) or only **some** of them. `check-releases.sh`
reports this via `platform_coverage` (per-system true/false) and
`partial_platform_coverage` (true when some but not all of the `target_platforms`
have a prebuilt asset). The coverage is computed relative to `target_platforms`,
not the hardcoded 4-system set — so a darwin-only project that ships both
darwin binaries has `partial_platform_coverage=false` (full coverage of its
scope), even though it doesn't ship Linux binaries.

**Why this matters**: The standard prebuilt-tarball template derives its target
systems from `builtins.attrNames assets` — only platforms with a prebuilt asset
get *any* output. If a project ships binaries for `x86_64-linux`,
`aarch64-linux`, and `aarch64-darwin` but NOT `x86_64-darwin`, then `nix run
github:...` on an Intel Mac fails with "package not available for this system"
— even though the project could be built from source on that platform.

**The hybrid fallback variant** (see `references/flake-templates/prebuilt-tarball.md`
— Hybrid Fallback Variant) solves this by making `#default` fall back to a
from-source build on platforms that lack a prebuilt binary:

- `#prebuilt` = prebuilt binary, only on platforms that have a release asset
- `#source` = source build on **all** buildable platforms (the union)
- `#default` = prebuilt where available, source fallback where not
- `#<project-name>` = alias for `#default`

This means `nix run github:...` works on every buildable platform — users on
platforms with a prebuilt binary get the fast path, users on platforms the
project didn't ship a binary for get a from-source build instead of an error.

**Decision tree for partial coverage:**

- **If `partial_platform_coverage=false`** (all 4 systems have prebuilt assets,
  OR no prebuilt assets at all): Use the standard prebuilt-tarball template.
  No hybrid fallback needed.
- **If `partial_platform_coverage=true` AND source build is feasible** for the
  missing platform(s): Use the hybrid fallback variant. Set
  `hybrid_fallback=true` — it is consumed at Steps 15, 24, and 27 to select
  the correct documentation and PR/issue template clauses.
- **If `partial_platform_coverage=true` AND source build is NOT feasible** for
  the missing platform(s) (e.g. complex native addons with no nixpkgs support
  on the missing platform): Use the standard prebuilt-only template and
  document the platform gap in the PR body. The flake correctly only supports
  platforms the project ships binaries for; that is the project's release
  policy, not a flake bug. Do NOT attempt the hybrid fallback if `sourceFor`
  cannot be implemented for the missing platform(s).
- **If `force_source_build=true`**: Use a pure source-build flake. The hybrid
  fallback is for prebuilt-first flakes; a forced source build is pure source.

**How to determine source-build feasibility for the missing platform:**
Check whether the language has a source-build template
(`references/flake-templates/source-build-*.md`) and whether the project's
build process works on the missing platform. For example, a Rust project that
builds on `x86_64-darwin` in CI can use `buildRustPackage` in the hybrid
fallback's `sourceFor` for that platform. A project with a N-API addon that
only ships prebuilt `.node` files for `x86_64-linux` cannot build from source
on `x86_64-darwin` — use the standard prebuilt-only template and document the
gap.

**Hash automation interaction**: The hybrid flake's `assets` attrset only
includes platforms with prebuilt binaries. The hash automation workflow
(Step 16) only bumps hashes for platforms in `ASSET_MAP` (the prebuilt
platforms). The `#source` output on fallback platforms tracks the git tag,
not release assets — it is NOT hash-automated. This is correct: the source
build is reproducible from the git tag, so it doesn't need hash automation.
See `references/advanced-features.md` — Release-Triggered Hash Automation.

---

## Complex Distribution Requirements

Only if no prebuilt tarballs exist (AND the project does not ship runtime assets beside the binary — see the CRITICAL rule above), analyze the project's architecture to determine if a simple flake.nix is sufficient or if complex packaging is required.

**Check for multi-component distribution:**

```bash
find . -type d -name "runtime" -o -name "assets" -o -name "resources" 2>/dev/null | head -10
find . -name "*.node" -o -name "*.so" -o -name "*.dylib" -o -name "*.dll" 2>/dev/null | head -10
grep -r "exclude" Cargo.toml package.json 2>/dev/null | head -10
find . -name "Makefile" -o -name "*.sh" -o -name "build.js" -o -name "packaging*" 2>/dev/null | head -10
grep -r "postinstall" package.json 2>/dev/null | head -5
```

**Key architectural patterns that require complex packaging:**

1. **Runtime asset dependencies**: Binary expects sibling directories (e.g., `runtime/`, `assets/`) to function
2. **Native addons**: Separate compiled libraries (N-API addons, .node files) built independently
3. **Workspace exclusions**: Components deliberately excluded from main build but required for functionality
4. **Multi-stage builds**: Separate build processes for different components
5. **Asset copying scripts**: Build processes that copy files to specific locations
6. **Postinstall hooks**: Installation scripts that set up runtime environment

**Decision tree:**

- **If `force_source_build=true`** (maintainer or reviewer explicitly requested source-build): Skip prebuilt entirely. Proceed to source-build analysis. This overrides the "preferred" prebuilt path even when tarballs exist and the binary is self-contained. Common trigger: rejection feedback on a prebuilt-binary flake citing "maintenance liability" or "hardcoded hashes".
- **If prebuilt tarballs exist AND the binary resolves runtime assets beside itself** (vendored `runtime/`, `node_modules`, N-API `.node`, etc.): Use fetchurl approach — MANDATORY. A from-source flake is broken for this class of project, not merely suboptimal.
- **If prebuilt tarballs exist AND the binary is self-contained**: Use fetchurl approach (PREFERRED).
- **If no prebuilt tarballs AND simple single-binary project**: Continue with standard flake.nix approach.
- **If complex multi-component distribution with no prebuilt tarballs**:
  - STOP and document the architectural requirements
  - Do NOT create a minimal flake that produces non-functional software
  - Either implement full multi-component packaging OR defer as tracked follow-up
  - If deferring, still create issue but mark as requiring complex packaging work

**Why this matters:**
- A flake that builds only the binary but omits required assets produces non-functional software
- `nix flake check` validates derivation structure, not runtime behavior
- Users will install a broken tool if the README advertises a non-functional installation method

---

## Success and Failure Patterns

**Example success pattern (from nubjs/nub#169):**
- Project publishes prebuilt per-platform tarballs on GitHub releases
- Flake uses fetchurl to download tarball with explicit SHA256 hash
- Extracts bin/ + runtime/ preserving exact layout
- Linux binaries use autoPatchelfHook to fix glibc linking
- No wrapper scripts — binary is real file with runtime/ as sibling
- Result: Fully functional tool with all runtime assets

**Example failure pattern (from nubjs/nub#168):**
- Project has `runtime/` directory with preload scripts
- Native addon (`nub-native.node`) built separately from main workspace
- Binary walks up from its location looking for sibling `runtime/` directory
- Simple flake builds only binary -> installed tool cannot transpile TypeScript
- Core functionality silently disabled due to missing assets

---

## Make Build Scripts Nix-Aware

For projects with custom build scripts (e.g., `build.rs` in Rust, custom Makefiles), make them support environment variable overrides for toolchain paths.

**Check for custom build scripts:**
- Rust: `build.rs` in project root
- Python: `setup.py`, `pyproject.toml` with custom build backend
- Go: `Makefile` or build scripts
- Node: Custom build scripts in `scripts/` or root

**Example for Rust build.rs:**

```rust
let zig = env::var("ZIG").unwrap_or_else(|_| "zig".into());
let mut command = Command::new(zig);

if let Ok(system_dir) = env::var("LIBGHOSTTY_VT_ZIG_SYSTEM_DIR") {
    command.arg("--system").arg(system_dir);
}

println!("cargo:rerun-if-changed=vendor/libghostty-vt/include");
println!("cargo:rerun-if-changed=vendor/libghostty-vt/pkg");
println!("cargo:rerun-if-changed=vendor/libghostty-vt/src");
```

**Key patterns:**
- Use `env::var()` to allow environment variable overrides for tool paths
- Add directory-level `cargo:rerun-if-changed` for vendored dependencies
- Support system directory paths for cross-compilation

**Skip this step if:**
- The project uses standard build tools without custom build scripts
- The build system already supports environment variable overrides

---

## Ensure Lockfiles in npm Tarballs

If the project is a Node.js package published to npm and you intend to package it with Nix's `buildNpmPackage`, ensure a lockfile is present in the published tarball.

**The problem:**
- `package-lock.json` is excluded from npm tarballs by default
- Nix's `buildNpmPackage` requires a lockfile to compute `npmDepsHash`

**The fix:**

Add `npm shrinkwrap` to the `prepublishOnly` hook in `package.json`:

```diff
- "prepublishOnly": "npm run clean && npm run build"
+ "prepublishOnly": "npm run clean && npm run build && npm shrinkwrap"
```

Unlike `package-lock.json`, `npm-shrinkwrap.json` is included in npm tarballs by default.

**Verification:**

```bash
npm pack --dry-run 2>&1 | grep shrinkwrap
```

**Workspace caveat:**
If the project uses npm workspaces, `npm shrinkwrap` cannot be run from within a workspace package. It must be run from the workspace root. For workspace packages published individually, consider building from git (`src = ./.`) where `package-lock.json` is already present.

**Skip this step if:**
- The project is not a Node.js package published to npm
- You are building from a git checkout (where `package-lock.json` exists)

---

## Inspecting Existing nixpkgs Derivations

Before writing `flake.nix` from scratch, check whether the project (or a close analog) is already packaged in nixpkgs. The existing derivation is a battle-tested reference for what it takes to deploy the project — dependencies, patches, postInstall setup, wrapper scripts, and runtime fixes that aren't obvious from the project's own build instructions. Skipping this is the most common cause of "builds but doesn't work" flakes.

**How to inspect**: Run `scripts/inspect-nixpkgs-derivation.sh <package-name>`. The script uses `nix eval nixpkgs#<pkg>.meta.position` to locate the derivation source file, fetches it from GitHub, and also resolves the dependency lists (`buildInputs`, `nativeBuildInputs`, `propagatedBuildInputs`, `runtimeDependencies`). Read the full derivation source — the dependency lists are a convenience summary, but the source file is where patches, hooks, and wrapper logic live.

**Checklist — catalog every one of these from the nixpkgs derivation and cross-check against your planned flake.nix:**

1. **`buildInputs`** — libraries and runtime dependencies the binary links against. Missing one produces a binary that crashes on startup or at first use.
2. **`nativeBuildInputs`** — build-time tools (pkg-config, cmake, autoPatchelfHook, makeWrapper). Missing one causes the build to fail or produce an unpatched binary.
3. **`propagatedBuildInputs`** — dependencies that consumers of this package also need. If your flake exposes a library or SDK, these must be propagated.
4. **`runtimeDependencies`** — packages that must be on `PATH` at runtime but aren't linked libraries (e.g. a CLI that shells out to `git` or `curl`). Missing these produces "command not found" errors during real use.
5. **`patches`** — source patches nixpkgs applies. These fix Nix-specific issues (hardcoded `/usr` paths, FHS assumptions) or upstream bugs. If nixpkgs patches the source, your from-source flake likely needs the same patches.
6. **`postInstall` / `preInstall` hooks** — install-time setup: wrapping binaries with `makeWrapper`, setting `GSETTINGS_SCHEMAS_DIR`, installing desktop entries, icons, man pages, or completion scripts. These are the most commonly missed items.
7. **`makeWrapper` args** — `--prefix PATH : ${pkgs.something}/bin`, `--set GSETTINGS_SCHEMA_DIR ...`, `--set-default ...`. These set up the runtime environment the binary expects. A bare `installPhase` that copies the binary without wrapping will produce a tool that can't find its helpers.
8. **`configureFlags` / `cmakeFlags` / `cargoBuildFlags` / `buildFlags`** — build-time feature toggles. nixpkgs may disable default features or enable ones the project's defaults don't.
9. **`dontConfigure` / `dontBuild` / `dontUnpack`** — flags that skip standard phases. If nixpkgs sets these, there's a reason (usually the build system conflicts with stdenv's defaults).
10. **`meta.platforms`** — which platforms nixpkgs builds for. If nixpkgs only supports `x86_64-linux`, trying to build on `aarch64-darwin` may fail for reasons nixpkgs already discovered.
11. **`passthru`** — optional outputs, update scripts, or tests. `passthru.updateScript` shows how nixpkgs auto-updates the version (useful for designing your own hash-bump workflow).
12. **Overlay / `callPackage` patterns** — if the derivation uses `callPackage` with overridden dependencies, those overrides may be required for the build to succeed (e.g. a pinned Rust toolchain, a patched LLVM).

**When the project isn't in nixpkgs but a similar project is:**

Run the script with the analog's name. For example, if packaging a new Chromium-based browser, inspect `brave`'s derivation — it shows the Chromium sandbox setup, the wrapper script for the sandbox helper, the `--no-sandbox` flag handling, and the icon/desktop-entry installation that all Chromium-based browsers need. Extract the patterns that apply to your project.

**Example — `brave` (nixpkgs#brave):**

The `brave` derivation in nixpkgs wraps the binary with `makeWrapper` to set up `LD_LIBRARY_DIR` for the sandbox, installs desktop entries and icons via `postInstall`, and depends on `nss`, `nspr`, `atk`, `at-spi2-atk`, `cups`, `dbus`, `expat`, `libdrm`, `mesa`, `xorg` libraries — none of which are obvious from brave-browser's own build instructions. A from-source flake that omits these produces a browser that launches but can't render pages or access the network. This is exactly the class of failure Step 11 prevents.

**Decision after inspection:**

- If the nixpkgs derivation is simple (few inputs, no patches, no postInstall) — your flake can follow the same pattern with confidence.
- If the nixpkgs derivation has patches, wrapper scripts, or many runtime deps — either replicate them in your flake, or prefer the `nixpkgs_wrapper` approach (Step 12 — `flake_type=nixpkgs_wrapper`) and let nixpkgs handle the complexity.
- If the nixpkgs derivation uses `fetchurl` on a prebuilt binary — confirms the Prebuilt Tarball Flake path (Step 12 — `flake_type=prebuilt_tarball`) and shows you the exact `buildInputs` and `installPhase` layout to replicate.

## nixpkgs Superset Comparison

> **Knowledge base**: The canonical concept page for this practice is
> [`nixpkgs-contribution`](../included/knowledge/nix-build-practices/nixpkgs-contribution.md)
> in the `nix-build-practices` bundle. This section is the skill-specific
> operational guidance; the bundle page is the compounding reference.

After inspecting the nixpkgs derivation (Step 11), determine whether the
nixpkgs packaging is a **superset** of what a from-source in-repo flake would
provide. A superset means nixpkgs includes all the features our from-source
build would have, PLUS additional patches, postInstall hooks, wrapper scripts,
or runtime dependencies that a naive from-source flake would miss.

When nixpkgs is a superset, the in-repo flake should expose a `#nixpkgs` output
(see `references/flake-templates/nixpkgs-output.md`) so users can access the
more complete packaging alongside the existing `#prebuilt` / `#source` outputs.
This gives users the choice: official release binary (`#prebuilt`), from-source
build (`#source`), or nixpkgs-packaged version with distribution patches
(`#nixpkgs`).

**How to check**: Run `scripts/check-nixpkgs-superset.sh <project-name>
<latest-release> <nixpkgs-version> [derivation-json]`. The script provides
deterministic signals — version currency, presence of patches/hooks/wrappers/
runtime deps. The agent does the full qualitative comparison by reading the
nixpkgs derivation source from Step 11.

**Superset checklist — compare the nixpkgs derivation against your planned
from-source flake:**

1. **Patches** — does nixpkgs apply source patches (Nix-specific fixes,
   upstream bug fixes, hardcoded path corrections)? If yes, a from-source
   flake without those patches may produce a broken or suboptimal binary.
2. **postInstall / preInstall hooks** — does nixpkgs run install-time setup
   (desktop entries, icons, man pages, completion scripts, schema
   compilation)? A from-source flake that skips these produces a tool that
   works but integrates poorly (no shell completion, no desktop entry).
3. **makeWrapper args** — does nixpkgs wrap the binary with `makeWrapper` to
   set PATH, GSETTINGS_SCHEMA_DIR, or other runtime environment variables?
   A from-source flake without the wrapper produces a binary that can't find
   its helpers at runtime.
4. **Runtime dependencies** — does nixpkgs declare `runtimeDependencies`
   (tools the binary shells out to at runtime — `git`, `curl`, `ffmpeg`)?
   A from-source flake that omits these produces "command not found" errors
   during real use.
5. **Extra buildInputs** — does nixpkgs link against libraries that aren't
   obvious from the project's own build instructions (platform-specific
   frameworks, optional feature dependencies)? A from-source flake that
   misses these may fail to build or crash at startup.
6. **meta.platforms** — does nixpkgs declare a narrower platform set than
   your flake targets? If nixpkgs only builds for `x86_64-linux`, the
   `#nixpkgs` output should only be exposed on that platform.

**Decision tree:**

- **nixpkgs is NOT a superset** (no patches, no hooks, no wrappers, no runtime
  deps): Do NOT add `#nixpkgs` output. A from-source flake provides equivalent
  functionality. Adding `#nixpkgs` would just duplicate `#source` with a
  different version pin.
- **nixpkgs IS a superset AND version is current** (within one minor release
  of latest upstream): Add `#nixpkgs` output. Users get the best of both
  worlds — the from-source build for auditability, and the nixpkgs version
  for the more complete packaging.
- **nixpkgs IS a superset BUT version is outdated** (multiple minor releases
  behind): Present the finding to the user. The superset packaging (patches,
  hooks, runtime deps) may outweigh the version lag for some users. Document
  the version lag in the PR body. The `#nixpkgs` output is still useful as an
  option — users who need the latest version use `#prebuilt` or `#source`,
  users who need the complete packaging use `#nixpkgs`.
- **nixpkgs IS a superset BUT version is severely outdated** (multiple major
  versions behind): Do NOT add `#nixpkgs` output unless the user explicitly
  requests it. The version lag is too large — users would get an ancient
  version with no way to tell without reading the flake. Document the finding
  in the PR body as a note for maintainers.

**Version comparison**: The script compares `nixpkgs_version` (from Step 10's
`check-nixpkgs.sh`) against `latest_release` (from Step 4b's
`check-releases.sh`). "Current" means within one minor release (e.g.,
nixpkgs has 1.2.1 and latest is 1.2.3 — same major.minor). "Outdated" means
one or more minor releases behind. "Severely outdated" means a different
major version.

**Downstream consumption:**

- `add_nixpkgs_output` (from the script) is consumed at Step 12 to add the
  `#nixpkgs` output to the flake (see `references/flake-templates/nixpkgs-output.md`).
- `version_current` and `is_superset` are consumed at Steps 24 and 27 to fill
  the conditional "nixpkgs output" section in the issue/PR templates.
- The `extra_build_inputs` array is informational — it lists buildInputs the
  agent should cross-check against the planned from-source flake to ensure
  the `#source` output also includes them (if feasible).

---

## Darwin Framework and Runtime Dependency Detection

Even when nixpkgs has no matching derivation, you can catch the two most common
Nix-Rust packaging gaps from the project source:

1. **`native-tls` / `reqwest` on Darwin**: Search `Cargo.toml` and `Cargo.lock`
   for `reqwest`, `native-tls`, `hyper-tls`, or `openssl`. If any appear, the
   Darwin build must include `Security` and `SystemConfiguration` frameworks in
   `buildInputs` (see `references/flake-templates/darwin-framework-note.md`).
   Without them, linking fails with `framework not found Security`.

2. **Runtime service dependencies**: Run
   `scripts/detect-runtime-deps.sh <project-dir>` from the nixify skill
   directory. It scans `Cargo.toml` (root + workspace members), `package.json`,
   `pyproject.toml`, `requirements.txt`, and `go.mod` for crates/packages that
   imply a runtime service — `surrealdb` → `surrealdb`, `sqlx`/`diesel`/
   `tokio-postgres` → `postgresql`, `redis`/`deadpool-redis` → `redis`,
   `lapin`/`amqp` → `rabbitmq`, `mongodb` → `mongodb`, etc. Add every detected
   nix package to both `devbox.json` `packages` and the flake
   `devShells.default.buildInputs` so `devbox shell` / `nix develop` provide a
   reproducible environment. Also check `docs/`, `README.md`, and install
   scripts for services the binary talks to that may not have a crate-level
   signal (e.g. a project that shells out to `ffmpeg` or `imagemagick`).

---

## Build-Time Network Fetches

**CRITICAL**: Nix builds run in a sandbox with **no network access**. Any
build step that fetches resources from the network at build time will fail
inside the Nix sandbox. This is distinct from runtime network access (which
is fine) — it is specifically about fetches that happen during `npm run
build`, `cargo build`, `next build`, or equivalent.

**Common offenders:**

1. **`next/font/google`** (Next.js) — fetches Google Fonts (Inter, Roboto,
   etc.) at build time. The Nix build fails with a network error during
   `next build`. This is the most common build-time network fetch in
   Next.js projects. (Reference: 9router PR #1405 — the prototype had to
   neutralize `next/font/google`'s build-time fetch of Inter, scoped to
   the Nix derivation only.)

2. **Remote asset downloads** — build scripts that `curl`/`wget` assets
   (images, fonts, binaries) during the build.

3. **API calls during build** — telemetry, analytics, or feature-flag
   calls that fire during the build step.

4. **`postinstall` scripts with network calls** — some packages fetch
   prebuilt binaries during `npm install` (e.g. `esbuild`, `sharp`,
   `@swc/core`). Nix's `fetchNpmDeps` prefetches these offline, but
   packages that bypass the npm lifecycle hooks can still fail.

**How to detect:**

```bash
# Next.js font fetches
grep -r "next/font/google" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" .
grep -r "next/font" --include="*.ts" --include="*.tsx" . | grep -i "google\|inter\|roboto"

# Remote downloads in build scripts
grep -rE "curl |wget |fetch\(" scripts/ build/ Makefile 2>/dev/null
grep -rE "https?://" next.config.* webpack.config.* 2>/dev/null

# Postinstall network calls
grep -r "postinstall" package.json
```

**How to handle:**

- **Scope the fix to the Nix derivation only** — do NOT touch the
  Docker/npm build path. The project's own CI and Docker builds need
  network access; only the Nix sandbox doesn't.
- **`next/font/google`**: Use `postPatch` to replace the font import with
  a no-op stub. The Nix build falls back to the system sans-serif stack
  already in the Tailwind/base CSS; Docker/npm builds keep the real
  self-hosted Google font. Concrete pattern (from 9router PR #1405):

  ```nix
  postPatch = ''
    node -e '
      const fs = require("fs");
      const p = "src/app/layout.js";
      let s = fs.readFileSync(p, "utf8");
      s = s.replace(/import \{ Inter \} from "next\/font\/google";\n/, "");
      s = s.replace(/const inter = Inter\(\{[^}]*\}\);/, "const inter = { variable: \"\" };");
      fs.writeFileSync(p, s);
    '
  '';
  ```

  Alternatively, vendor the font files into the repo and use
  `next/font/local`.
- **Next.js telemetry**: Set `env.NEXT_TELEMETRY_DISABLED = "1";` in the
  derivation. Next.js telemetry makes a network call during `next build`
  that fails in the sandbox. This is a build-time network fetch even for
  projects that don't use `next/font/google`.
- **Remote asset downloads**: Vendor the assets into the repo, or use
  Nix's `fetchurl`/`fetchzip` to prefetch them and pass the paths via
  environment variables.
- **API calls during build**: Guard with an environment variable
  (`BUILD_OFFLINE=1`) that skips the call when set. Set it in the Nix
  derivation's `preBuild`.

**Why this matters**: A project that builds fine in Docker or CI can fail
silently in Nix because the sandbox blocks network. The failure message is
often cryptic (a hung connection or DNS error) and doesn't obviously point
to a build-time fetch. Detecting these before writing the flake saves hours
of debugging.

---

## Gitignored Lockfiles

**CRITICAL**: Nix's `fetchNpmDeps` (used by `buildNpmPackage`) requires a
`package-lock.json` to prefetch dependencies deterministically offline. If
the project gitignores `package-lock.json` — either because it uses
`pnpm-lock.yaml`/`yarn.lock` instead, or because it has no lockfile at all
— the Nix build cannot compute the dependency hash.

This is distinct from the "Lockfiles in npm Tarballs" section above, which
covers `package-lock.json` excluded from npm-published tarballs. This
section covers the case where the lockfile is absent from the git
repository entirely.

**How to detect:**

```bash
# Check if package-lock.json is gitignored
git check-ignore package-lock.json

# Check if any lockfile exists
ls package-lock.json pnpm-lock.yaml yarn.lock bun.lock 2>/dev/null

# Check .gitignore for lockfile patterns
grep -E "package-lock|yarn.lock|pnpm-lock|bun.lock" .gitignore
```

**How to handle:**

- **Generate the lockfile as a pre-build step in the Nix derivation**:
  Run `npm install --package-lock-only` (or `npm install --lock-only`) in
  the `preConfigure` phase to generate `package-lock.json` before
  `fetchNpmDeps` runs. This keeps the lockfile out of the repo but
  makes it available for the Nix build.
- **Generate and commit the lockfile**: If the maintainer is open to it,
  generate `package-lock.json` and commit it. This is the simplest fix
  but may conflict with the project's policy of not committing lockfiles
  (e.g. when using pnpm as the primary package manager).
- **Keep the lockfile Nix-only**: Generate the lockfile in a separate
  directory or as a build artifact that is not committed to the repo.
  Document this in the PR body so reviewers understand why the lockfile
  appears in the Nix build but not in the repo.
- **For monorepos with multiple lockfiles**: Some projects have separate
  `package.json` files in subdirectories (e.g. a root app and a `cli/`
  wrapper), each needing its own lockfile. Generate lockfiles for each
  subdirectory that `fetchNpmDeps` needs to prefetch. (Reference: 9router
  PR #1405 — the prototype had to generate `package-lock.json` for both
  the root app and `cli/`.)

**Tradeoff**: Committing lockfiles makes the Nix build simpler but may
conflict with the project's package manager policy. Generating them in
the Nix build keeps the repo clean but adds complexity to the flake.
Discuss with the maintainer in the PR body.

---

## Postinstall Home-Directory Writes

**CRITICAL**: Some packages have `postinstall` scripts that write to the
user's home directory at install time (e.g. `~/.<project>/runtime/`).
These scripts fail in the Nix sandbox because:

1. The Nix store is read-only — you cannot write to `~/.<project>/`
   during the build.
2. The build runs as a non-root user with no home directory access.
3. Even if the write succeeded, it would be in the builder's
   ephemeral home, not the end user's home.

This is related to but distinct from the "Runtime Asset Dependencies"
pattern in Complex Distribution Requirements above. That section covers
binaries that expect sibling directories at runtime. This section covers
install-time scripts that write outside the build tree.

**Common offenders:**

1. **`better-sqlite3`** — compiles a native SQLite addon during
   `postinstall` and may write to a runtime directory.
2. **Systray libraries** — may install tray icons or helpers to a
   runtime directory.
3. **CLIs with self-update mechanisms** — some CLIs download runtime
   assets to `~/.<project>/runtime/` during `postinstall`.

**How to detect:**

```bash
# Check package.json for postinstall scripts
grep -r "postinstall" package.json

# Check for home-directory writes in install scripts
grep -rE "HOME|~/\." scripts/ install.* postinstall.* 2>/dev/null

# Check for runtime directory patterns
grep -rE "\.9router|\.<project>|runtime/" package.json scripts/ 2>/dev/null
```

**How to handle:**

- **Set `HOME=$TMPDIR` in `buildPhase`**: This redirects any home-directory
  writes to the sandbox's temp directory. Some packages check `$HOME`
  before running postinstall logic, so this prevents the write attempt
  even if the script runs. Use this alongside `--ignore-scripts` for
  defense in depth:

  ```nix
  buildPhase = ''
    runHook preBuild
    # Prevent postinstall scripts from writing to ~/.<project>/
    export HOME=$TMPDIR
    npm ci --ignore-scripts
    # ...
  '';
  ```

- **Skip the postinstall script in the Nix build**: Use
  `npm ci --ignore-scripts` (in a `stdenv.mkDerivation`) or
  `npmFlags = [ "--ignore-scripts" ]` (in `buildNpmPackage`) to skip
  all lifecycle scripts. This prevents the postinstall from running
  during the build.
- **Fall back to bundled alternatives at runtime**: Many projects have
  fallback behavior when the postinstall assets are absent. For example,
  9router falls back from `better-sqlite3` (native addon) to `sql.js`
  (pure JS) and from systray to no-tray behavior when the runtime
  directory is missing. Document this fallback in the PR body.
- **Provide the assets via Nix**: If the project requires the
  postinstall assets and has no fallback, use a Nix derivation to
  build/place them in the correct location relative to the binary,
  then wrap the binary with `makeWrapper` to set the path.

**Why this matters**: A project that installs fine via `npm install` can
fail in Nix because the postinstall script tries to write to a
home directory that doesn't exist in the sandbox. The error is often a
permission denied or ENOENT that doesn't obviously point to the
postinstall script. (Reference: 9router PR #1405 — `better-sqlite3` /
systray postinstall was skipped during the Nix build and fell back to
bundled `sql.js` + no-tray behavior at runtime.)

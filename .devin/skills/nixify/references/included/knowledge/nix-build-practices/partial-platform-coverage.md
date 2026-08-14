---
type: Practice
title: Partial Platform Coverage
description: When a project ships prebuilt binaries for some but not all target Nix systems, use a hybrid fallback flake — #default uses the prebuilt binary where available and builds from source on the missing platforms. The target system set is the union of prebuilt-asset platforms and source-build-capable platforms, not the intersection.
tags: [nix, flakes, prebuilt, tarball, hybrid-fallback, platform-coverage, source-build]
date:
  created: "2026-07-31"
  knowledge-basis: "2026-07-31"
  last-used: "2026-07-31"
sources:
  - id: nixify-skill-v2.14.0
    resource: ../../skills/software-dev/nixify/SKILL.md.tmpl
    title: nixify skill v2.14.0 — hybrid fallback variant
  - id: nixify-prebuilt-tarball-template
    resource: ../../skills/software-dev/nixify/references/flake-templates/prebuilt-tarball.md
    title: nixify prebuilt-tarball flake template (Hybrid Fallback Variant section)
  - id: nubjs-nub-169
    resource: https://github.com/nubjs/nub/issues/169
    title: nubjs/nub#169 — prebuilt chosen over from-source (vendored runtime tree)
  - id: nixify-architecture-analysis
    resource: ../../skills/software-dev/nixify/references/architecture-analysis.md
    title: nixify architecture analysis — Partial Platform Coverage section
---

# Partial Platform Coverage

## Failure Mode

The standard prebuilt-tarball flake template derives its target systems from
`builtins.attrNames assets` — only platforms with a prebuilt release asset get
*any* output. When a project ships binaries for `x86_64-linux`,
`aarch64-linux`, and `aarch64-darwin` but NOT `x86_64-darwin`, then `nix run
github:...` on an Intel Mac fails with "package not available for this system"
— even though the project could be built from source on that platform.

The failure is silent in CI (which typically runs on the platforms with
prebuilt assets) and surfaces only when a user on the missing platform tries
to install the tool.

## Practice

When `check-releases.sh` reports `partial_platform_coverage: true` (some but
not all of the project's `target_platforms` have a prebuilt asset) AND source
build is feasible for the missing platforms, use the **hybrid fallback
variant** of the prebuilt-tarball flake.

### The Hybrid Fallback Variant

The flake exposes three outputs:

- `#prebuilt` = prebuilt binary, only on platforms that have a release asset.
  Omitted on platforms without a prebuilt asset, so `nix run .#prebuilt`
  correctly errors "package not available" on unsupported platforms instead of
  silently building from source.
- `#source` = source build on **all** buildable platforms (the union).
- `#default` = `if assets ? ${system} then prebuilt else source` — prebuilt
  where available, source fallback where not.
- `#<project-name>` = alias for `#default` (not `#prebuilt`).

The target system set is the **union** of prebuilt-asset platforms and
source-build-capable platforms, not the intersection. Users on platforms with
a prebuilt binary get the fast path; users on platforms the project didn't
ship a binary for get a from-source build instead of an error.

### Decision Tree

- **`partial_platform_coverage=false`** (all target systems have prebuilt
  assets, OR no prebuilt assets at all): Use the standard prebuilt-tarball
  template. No hybrid fallback needed.
- **`partial_platform_coverage=true` AND source build is feasible** for the
  missing platform(s): Use the hybrid fallback variant. Set
  `hybrid_fallback=true`.
- **`partial_platform_coverage=true` AND source build is NOT feasible** for
  the missing platform(s) (e.g. complex native addons with no nixpkgs support
  on the missing platform): Use the standard prebuilt-only template and
  document the platform gap in the PR body. The flake correctly only supports
  platforms the project ships binaries for; that is the project's release
  policy, not a flake bug.
- **`force_source_build=true`**: Use a pure source-build flake. The hybrid
  fallback is for prebuilt-first flakes; a forced source build is pure source.

### Determining Source-Build Feasibility

Check whether the language has a source-build template
(`source-build-rust.md`, `source-build-go.md`, `source-build-node.md`, etc.)
and whether the project's build process works on the missing platform. A Rust
project that builds on `x86_64-darwin` in CI can use `buildRustPackage` in the
hybrid fallback's `sourceFor` for that platform. A project with a N-API addon
that only ships prebuilt `.node` files for `x86_64-linux` cannot build from
source on `x86_64-darwin` — use the standard prebuilt-only template and
document the gap.

### Hash Automation Interaction

The hybrid flake's `assets` attrset only includes platforms with prebuilt
binaries. The hash automation workflow only bumps hashes for platforms in
`ASSET_MAP` (the prebuilt platforms). The `#source` output on fallback
platforms tracks the git tag, not release assets — it is NOT hash-automated.
This is correct: the source build is reproducible from the git tag, so it
doesn't need hash automation.

### Coverage Is Relative to Scope

`partial_platform_coverage` is computed relative to the project's
`target_platforms` (from platform scope detection), not the hardcoded 4-system
set. A darwin-only project that ships both darwin binaries has
`partial_platform_coverage=false` (full coverage of its scope), even though it
doesn't ship Linux binaries. See
[Inherent Platform Scope](inherent-platform-scope.md) for scope detection.

## What NOT to Do

- Do NOT use the hybrid fallback to fill **inherent-scope** gaps. The hybrid
  fallback is for projects that *could* build on the missing platform but just
  don't ship a prebuilt binary for it. An inherently darwin-only project
  cannot build on Linux at all — use platform scope detection to narrow the
  target set instead.
- Do NOT include the missing platform in `assets` with a fake or placeholder
  hash. The `assets` attrset must only contain platforms with real release
  assets.
- Do NOT omit the `#source` output on platforms that have a prebuilt asset.
  `#source` is exposed on **all** buildable platforms so users can explicitly
  choose a reproducible-from-source path on any platform.

## Example

A project ships prebuilt binaries for `x86_64-linux`, `aarch64-linux`, and
`aarch64-darwin` but NOT `x86_64-darwin`. The project is a Rust CLI that
builds cleanly on all 4 systems.

- `assets` includes 3 entries (the platforms with prebuilt binaries).
- `allSystems` includes all 4 systems (the union — prebuilt platforms plus
  the source-build-capable missing platform).
- `#prebuilt` is defined for 3 systems; `nix run .#prebuilt` on
  `x86_64-darwin` errors "package not available".
- `#source` is defined for all 4 systems via `buildRustPackage`.
- `#default` on `x86_64-darwin` falls back to `#source`; on the other 3
  systems it uses `#prebuilt`.
- `nix run github:...` works on every buildable platform.

## Related Concepts

- [Inherent Platform Scope](inherent-platform-scope.md) — Detect
  platform-specific software before computing coverage; coverage is relative
  to scope
- [Nix Flake Structure](nix-flake-structure.md) — The flake.nix structure the
  hybrid variant builds on
- [Reproducible Builds](reproducible-builds.md) — The `#source` output is
  reproducible from the git tag; the `#prebuilt` output is reproducible from
  the pinned sha256

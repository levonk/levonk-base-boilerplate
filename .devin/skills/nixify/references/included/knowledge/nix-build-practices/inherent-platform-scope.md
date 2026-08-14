---
type: Practice
title: Inherent Platform Scope
description: Some software is inherently platform-specific by design (macOS menu-bar apps, Linux-only systemd tools). Detect platform scope via CI matrix, manifest imports, build tags, and README signals, then narrow the flake's target systems to only the platforms the software actually supports. Do NOT attempt cross-compilation to fill inherent-scope gaps.
tags: [nix, flakes, platform-scope, darwin, linux, cross-compilation, detection]
date:
  created: "2026-07-31"
  knowledge-basis: "2026-07-31"
  last-used: "2026-07-31"
sources:
  - id: nixify-skill-v2.15.0
    resource: ../../skills/software-dev/nixify/SKILL.md.tmpl
    title: nixify skill v2.15.0 — inherent platform scope detection
  - id: nixify-detect-platform-scope
    resource: ../../skills/software-dev/nixify/scripts/detect-platform-scope.sh
    title: nixify detect-platform-scope.sh — platform scope detector
  - id: nixify-architecture-analysis
    resource: ../../skills/software-dev/nixify/references/architecture-analysis.md
    title: nixify architecture analysis — Inherent Platform Scope section
---

# Inherent Platform Scope

## Failure Mode

A flake that targets all 4 Nix systems for software that only runs on one OS
family produces broken builds on the unsupported platforms. A macOS menu-bar
app advertised as Linux-compatible fails to build on Linux (no AppKit/Cocoa).
A GRUB/systemd tool advertised as Darwin-compatible fails to build on Darwin
(no Linux kernel ABI). The failure surfaces late — during `nix build` on the
unsupported platform — after the PR is already merged.

The reverse failure is also real: a flake that targets only one OS family for
software that is actually cross-platform unnecessarily excludes users on the
other OS family.

## Practice

Before checking for prebuilt tarballs or computing platform coverage,
determine whether the project is **inherently platform-specific**. Some
software only runs on one OS family by design. For such projects, the flake
should target only the platforms the software actually supports, rather than
the default 4-system set. Narrowing scope is NOT a coverage gap — it is the
project's correct release policy.

### How to Detect

Run `detect-platform-scope.sh <project-dir>`. The script inspects:

- **CI matrix** (`.github/workflows/*.yml` `runs-on:` / `matrix.os:`)
- **Rust manifests** (`Cargo.toml`/`Cargo.lock` for `cocoa`, `objc`,
  `systemd`, etc.)
- **Swift source files** (`import SwiftUI/AppKit/UIKit`)
- **Go build tags** (`//go:build linux` / `//go:build darwin`)
- **Node.js native deps**
- **README/docs** for platform-defining signals

It reports:

- `target_platforms`: JSON array subset of the 4 Nix systems
- `platform_scope`: `all`, `darwin_only`, or `linux_only`
- `confidence`: `high`, `medium`, or `low`
- `signals`: array of `{ signal, scope, source, confidence }`
- `rationale`: human-readable summary

### Decision Tree

- **`platform_scope=all`** (the common case): The project is cross-platform
  or has no platform-narrowing signals. Proceed with the default 4-system
  target set. No special handling needed downstream.
- **`platform_scope=darwin_only` or `linux_only` with `confidence=high`**: A
  high-confidence signal (e.g. CI matrix only runs on macOS, or Swift source
  imports AppKit) with no signals for the other OS family. The flake targets
  only the detected family.
- **`platform_scope=darwin_only` or `linux_only` with `confidence=medium`**:
  Multiple medium-confidence signals (e.g. `cocoa` crate + README says "macOS
  only") but no single definitive one. Present the detection result to the
  user with the `rationale` and `signals` list, and confirm before narrowing
  scope. The user may know the project is cross-platform despite the signals.
- **`confidence=low`** (conflicting signals): Keep `platform_scope=all` and
  proceed with the 4-system default. Do not narrow scope on conflicting
  evidence.

### Manual Override

If the user explicitly states the project is platform-specific (or
cross-platform despite detection), honor their input over the script. Set
`target_platforms` and `platform_scope` accordingly and note the override in
the PR body. The script is conservative — it prefers false negatives over
false positives.

## What NOT to Do

- Do NOT attempt cross-compilation to fill the "missing" platform. A Mac
  toolbar app doesn't need a Linux build — the Linux build would fail or
  produce a broken binary. The "missing" platform is correct by design.
- Do NOT use the hybrid fallback variant to fill inherent-scope gaps. The
  hybrid fallback is for projects that *could* build on the missing platform
  but just don't ship a prebuilt binary for it. An inherently darwin-only
  project cannot build on Linux at all. See
  [Partial Platform Coverage](partial-platform-coverage.md) for the
  distinction.
- Do NOT ignore the detection and target all 4 systems anyway. A flake that
  advertises Linux support for a macOS-only app will fail to build on Linux,
  which is worse than honestly declaring darwin-only support.

## Downstream Consumption

- `target_platforms` is passed to `check-releases.sh` as the third argument,
  so `partial_platform_coverage` is computed relative to the project's scope,
  not the hardcoded 4-system set.
- The flake's `allSystems`, `assets`, and `meta.platforms` are scoped to
  `target_platforms`.
- The PR/issue templates include a "Platform scope" clause when
  `platform_scope` is not `all`, pre-empting the "why no Linux/macOS?" review
  comment.

## Examples

- **macOS menu-bar app** (Swift, imports AppKit): `platform_scope=darwin_only`,
  `target_platforms=["x86_64-darwin","aarch64-darwin"]`. The flake targets
  darwin only. A Linux user who tries `nix run github:...` gets "package not
  available for this system" — correct, because the app cannot run on Linux.
- **systemd service manager** (Rust, depends on `systemd` crate):
  `platform_scope=linux_only`,
  `target_platforms=["x86_64-linux","aarch64-linux"]`. The flake targets
  Linux only. A macOS user gets "package not available" — correct, because
  the tool needs the Linux kernel ABI.
- **CLI tool written in Rust** (no platform-specific deps, CI runs on both
  ubuntu and macos): `platform_scope=all`, `target_platforms` = all 4
  systems. The flake targets all 4 platforms as before — no narrowing.

## Related Concepts

- [Partial Platform Coverage](partial-platform-coverage.md) — Coverage is
  computed relative to scope; do not use the hybrid fallback to fill
  inherent-scope gaps
- [Nix Flake Structure](nix-flake-structure.md) — The flake.nix structure
  that consumes `target_platforms` in `allSystems` and `meta.platforms`
- [Package Verification](package-verification.md) — Verify platform-specific
  packages exist for the narrowed target set before adding them

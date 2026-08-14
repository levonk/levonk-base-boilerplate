---
type: Practice
title: nixpkgs Contribution
description: When a project is not yet in nixpkgs, contribute it upstream using the pkgs/by-name convention so all Nix users can install it via nix profile add nixpkgs#<project>. The nixpkgs PR body does not explain Nix — it is written for nixpkgs maintainers who already know Nix.
tags: [nix, nixpkgs, contribution, pkgs-by-name, package-nix, upstream, callPackage]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"
sources:
  - id: nixpkgs-quick-start
    resource: "https://nixos.org/manual/nixpkgs/stable/#chap-quick-start"
    title: "nixpkgs Reference Manual — Quick Start to Adding a Package"
  - id: nixpkgs-by-name-readme
    resource: "https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md"
    title: "pkgs/by-name README — name-based package directories"
  - id: nixify-skill-v2.19.0
    resource: ../../skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify skill v2.19.0 — nixpkgs superset check and upstream contribution"
---

# nixpkgs Contribution

## Failure Mode

When a project has an in-repo flake but is not in nixpkgs, only users who know
about the flake can install it. The vast majority of Nix users search
`nix profile add nixpkgs#<project>` first — if the package is not in nixpkgs,
they conclude "Nix doesn't support this project" and move on. The in-repo
flake is invisible to them.

## Practice

**When a project is not yet in nixpkgs, contribute it upstream.**

The nixify skill automates this at Step 28b: after the in-repo flake is
validated and the main PR is created, the skill prepares a nixpkgs
contribution using the `pkgs/by-name` convention and opens a PR to
`NixOS/nixpkgs`.

### pkgs/by-name Convention

New packages use the `pkgs/by-name` directory structure, which auto-registers
the package without editing `all-packages.nix`:

```
pkgs/by-name/<prefix>/<package-name>/package.nix
```

Where `<prefix>` is the first 2 characters of the package name, lowercased.
For example, `my-tool` goes to `pkgs/by-name/my/my-tool/package.nix`.

### package.nix Structure

The `package.nix` is a function that takes dependencies as arguments and
returns a derivation. `callPackage` auto-fills the arguments from the
top-level package set.

### Key Departure from Project-Owner PRs

The nixpkgs PR body does **NOT** explain Nix concepts. The audience is
nixpkgs maintainers who already know Nix — they need the package definition,
dependencies, meta attributes, and test results, not a tutorial on what Nix
is or why flakes are useful. This is a departure from project-owner PR/issue
templates which educate project owners about Nix benefits.

### Using the In-Repo Flake as Reference

The in-repo flake.nix already has a working build. Use it as the reference
for the nixpkgs `package.nix`:

1. Copy `buildInputs`, `nativeBuildInputs`, and build phases from the
   flake's `#source` output
2. Replace `src = ./.` with `fetchFromGitHub { ... }` pointing at the
   upstream release tag
3. Replace local toolchain pins with nixpkgs defaults
4. Add `meta` attributes (license, platforms, mainProgram, maintainers)

### Maintainer Entry

Before the nixpkgs PR can be merged, the contributor must add themselves to
`maintainers/maintainer-list.nix` in a separate commit.

### Hash Discovery

Use the fake-hash method: set a fake hash, build, copy the correct hash from
the error output, replace, rebuild.

### Limitations

Not all packages can use `pkgs/by-name`. Packages needing custom `callPackage`
arguments must still be declared in `all-packages.nix`. Packages in special
scopes (`haskellPackages`, `python3Packages`) stay in their scope's directory.

## Related Concepts

- [Nix Flake Structure](nix-flake-structure.md) — The in-repo flake that
  serves as the reference for the nixpkgs `package.nix`
- [Package Verification](package-verification.md) — Verify the package name
  and version in nixpkgs before contributing
- [Reproducible Builds](reproducible-builds.md) — The nixpkgs `package.nix`
  must produce reproducible builds via `fetchFromGitHub` hash pinning

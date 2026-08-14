# Directory Update Log

## 2026-08-09

* **Add**: New concept page for nixpkgs upstream contribution practice.
  - [nixpkgs-contribution.md](nixpkgs-contribution.md) — When a project is
    not yet in nixpkgs, contribute it upstream using the `pkgs/by-name`
    convention so all Nix users can install it via
    `nix profile add nixpkgs#<project>`. The nixpkgs PR body does NOT explain
    Nix — it is written for nixpkgs maintainers who already know Nix.
* **Update**: Bumped `date.knowledge-basis` and `date.last-used` to
  2026-08-09. Added nixpkgs Quick Start manual and nixify skill v2.19.0 to
  overview sources. Added nixpkgs-contribution to the overview table
  (Pipeline → Distribution layer).

## 2026-07-31

* **Backport**: Added 2 new concept pages backported from the nixify skill
  v2.14.0 (hybrid fallback) and v2.15.0 (platform scope detection). The
  bundle now covers platform strategy in addition to the build pipeline.
  - [inherent-platform-scope.md](inherent-platform-scope.md) — Detect
    platform-specific software by design; narrow the flake's target systems
    via CI matrix, manifest imports, build tags, and README signals. Do NOT
    attempt cross-compilation to fill inherent-scope gaps.
  - [partial-platform-coverage.md](partial-platform-coverage.md) — When a
    project ships prebuilt binaries for some but not all target systems, use
    a hybrid fallback flake (`#default` = prebuilt where available, source
    where not). The target system set is the union, not the intersection.
* **Update**: Restructured [overview.md](overview.md) synthesis from a linear
  4-phase stack to a two-layer model (build pipeline + platform strategy).
  The platform strategy layer is orthogonal to the pipeline — consulted at
  the structure phase to scope `allSystems` and at the verification phase to
  compute coverage. Added a "How the Layers Interact" section.
* **Update**: Bumped `date.knowledge-basis` and `date.last-used` to
  2026-07-31. Added nixify skill v2.15.0 and nubjs/nub#169 to overview
  sources.
* **Coupling**: Wired the nixify skill to consume this bundle via
  `includeTree` — the bundle is now materialized into the nixify skill's
  `references/included/knowledge/nix-build-practices/` at build time so it
  is available offline when the skill is installed standalone.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-17

* **Initialization**: Created the `nix-build-practices` knowledge bundle to consolidate Nix build and development practices from two ADRs in levonk-base-boilerplate and project conventions.
* **Creation**: Authored 4 concept pages covering the Nix build stack.
  - [nix-flake-structure.md](nix-flake-structure.md) — flake.nix with inputs, outputs, devShells, packages
  - [devbox-as-nix-abstraction.md](devbox-as-nix-abstraction.md) — devbox.json as simpler JSON alternative to raw Nix
  - [package-verification.md](package-verification.md) — Always verify via search.nixos.org before adding packages
  - [reproducible-builds.md](reproducible-builds.md) — flake.lock and devbox.lock for deterministic builds
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20251219001 (Nix flake, 66 lines) and ADR-20251226001 (devbox, 65 lines) in levonk-base-boilerplate, plus project conventions for package verification.

---
okf_version: "0.2"
---

# Nix Build Practices

A compounding knowledge base documenting practices for Nix-based build and
development environments — flake structure, devbox as Nix abstraction, package
verification, reproducible builds, inherent platform scope, and partial
platform coverage. Each concept captures specific practices sourced from ADRs,
the nixify skill, and project conventions.

## Concepts

* [Overview](overview.md) - Synthesis of the full Nix build practice set
* [nix-flake-structure](nix-flake-structure.md) - flake.nix with inputs, outputs, devShells, packages; flake.lock for reproducibility
* [devbox-as-nix-abstraction](devbox-as-nix-abstraction.md) - devbox.json as simpler alternative to raw Nix flakes, Nix-compatible packages
* [package-verification](package-verification.md) - Always verify Nix packages exist, check versions, confirm attribute names via search.nixos.org
* [reproducible-builds](reproducible-builds.md) - flake.lock pinning, devbox.lock, deterministic builds across machines
* [inherent-platform-scope](inherent-platform-scope.md) - Detect platform-specific software by design; narrow the flake's target systems to only the platforms the software actually supports
* [partial-platform-coverage](partial-platform-coverage.md) - When a project ships prebuilt binaries for some but not all target systems, use a hybrid fallback flake (#default = prebuilt where available, source where not)
* [nixpkgs-contribution](nixpkgs-contribution.md) - When a project is not yet in nixpkgs, contribute it upstream using the pkgs/by-name convention so all Nix users can install it

---
type: Practice
title: Package Verification
description: Always verify Nix packages exist, check available versions, and confirm correct attribute names via search.nixos.org before adding to devbox.json or flake.nix. Prevents non-existent, renamed, or version-mismatched packages.
tags: [nix, packages, verification, search-nixos-org, devbox, attributes]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: project-convention
    resource: "Project convention"
    title: "package verification via search.nixos.org"
---

# Package Verification

## Failure Mode

Recommending Nix packages without verification leads to non-existent package
names, renamed attributes, or version mismatches. Builds fail with cryptic
errors when a package doesn't exist in the specified nixpkgs channel.

## Practice

**Always verify packages before adding to devbox.json or flake.nix.**

### Verification Process

1. Search for the package at:
   `https://search.nixos.org/packages?channel=25.11&query=<package>`
2. Confirm the package exists in the target channel
3. Check available versions match what's needed
4. Confirm the correct attribute name (may differ from common name)

### Common Pitfalls

- **Renamed packages**: Package names change between nixpkgs versions
- **Attribute paths**: Some packages have nested attribute paths
  (e.g., `python3Packages.requests` not just `requests`)
- **Channel mismatch**: Package exists in unstable but not in the pinned channel
- **Version differences**: Available version may be older/newer than expected

### Example Verification

```bash
# Before adding 'ripgrep' to devbox.json:
# 1. Visit https://search.nixos.org/packages?channel=25.11&query=ripgrep
# 2. Confirm: package name is 'ripgrep', version 14.x available
# 3. Add to devbox.json: "ripgrep@14"
```

### For Devbox

Devbox uses Nix packages, so the same verification applies. The devbox search
command can also be used:

```bash
devbox search <package>
```

## Related Concepts

- [Devbox as Nix Abstraction](devbox-as-nix-abstraction.md) — Where verified
  packages are added
- [Nix Flake Structure](nix-flake-structure.md) — Where verified packages are
  referenced

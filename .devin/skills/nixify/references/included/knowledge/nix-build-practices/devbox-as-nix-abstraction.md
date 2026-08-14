---
type: Practice
title: Devbox as Nix Abstraction
description: devbox.json as simpler alternative to raw Nix flakes. JSON config, Nix-compatible packages, devbox.lock for reproducibility. Lower learning curve than raw Nix.
tags: [devbox, nix, abstraction, json, devbox-json, devbox-lock]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-20251226001-devbox-direnv-dev-environment
    resource: internal-docs/adr/adr-20251226001-devbox-direnv-dev-environment.md
    title: levonk-base-boilerplate
---

# Devbox as Nix Abstraction

## Failure Mode

Raw Nix flakes require learning the Nix language and flake schema. Complex
syntax and steep learning curve discourage adoption. Simple package additions
require understanding Nix expressions.

## Practice

Use **devbox.json** as a simpler abstraction over Nix.

### devbox.json Structure

```json
{
  "packages": [
    "go@1.23",
    "just@1.36",
    "jq@1.7",
    "git@2.43"
  ],
  "shell": {
    "init_hook": [
      "echo 'Welcome to devbox shell'"
    ]
  },
  "nixpkgs": {
    "commit": "abc123..."
  }
}
```

### Benefits Over Raw Nix

1. **JSON config** — no Nix language to learn
2. **Simple package syntax** — `"package@version"` format
3. **devbox.lock** — reproducibility without manual flake.lock management
4. **Nix-compatible** — uses Nix packages under the hood
5. **Shell scripts** — `devbox.json` scripts call `just *_impl` targets

### When to Use Raw Nix Instead

- Complex package builds requiring custom Nix expressions
- Cross-compilation targets
- NixOS module definitions
- When devbox doesn't support a needed Nix feature

### Migration Path

Projects can start with devbox.json and migrate to raw Nix flakes if more
control is needed. The underlying Nix infrastructure remains the same.

## Related Concepts

- [Nix Flake Structure](nix-flake-structure.md) — What devbox abstracts over
- [Package Verification](package-verification.md) — Verify packages before
  adding to devbox.json
- [Reproducible Builds](reproducible-builds.md) — devbox.lock provides this

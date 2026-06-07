---
modeline: "vim: set ft=markdown:"
title: "ADR: Package Path Modifier for Active/Icebox Packages"
adr-id: "adr-20251016001"
slug: "20251016001-package-path-modifier"
url: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20251016001-package-path-modifier.md"
synopsis: "Adds active/icebox modifier to package paths for work-in-progress packages"
author: "https://github.com/levonk"
date-created: "2025-10-16"
date-updated: "2025-12-01"
version: "1.0.1"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr"]
supersedes: ["adr-20251014001-refined-package-organization"]
superseded-by: []
related-to: ["adr-20251014001-refined-package-organization", "adr-20250926001-package-organization"]
---

# Architecture Decision Record: Package Path Modifier for Active/Icebox Packages

## Context

Following ADR 002's platform-first package structure, we need a way to distinguish between:
- Production-ready packages (in standard paths)
- Work-in-progress packages being actively fixed/improved
- Iceboxed packages not currently being worked on

## Decision

We will modify the package path structure to include an `{active|icebox}` modifier level:

`packages/{active|icebox}/{category}/{platform}/{domain}/{package-name}/{language}`

This modifier is now the **canonical** packages layout and is reflected in
`internal-docs/ARCHITECTURE.md`.

## Rationale

- **Active**: Packages currently being worked on/fixed can be moved to `active/` paths
- **Icebox**: Packages not being actively maintained go in `icebox/`
- Maintains all benefits of ADR 002's structure while adding workflow flexibility
- Clear visual distinction in file paths between active and inactive packages

## Consequences

### Pros
- Clear workflow state visible in file paths
- Easy to find packages needing attention
- No disruption to production-ready packages

### Cons
- Temporary additional path complexity
- Requires moving packages between paths as status changes

## Rollout Plan
1. Create new `active/` and `icebox/` directories under `packages/`
2. Move WIP packages to `active/` paths
3. Move inactive packages to `icebox/` paths
4. Update build configurations to handle new paths

## References
- ADR 002: Refined Package Organization

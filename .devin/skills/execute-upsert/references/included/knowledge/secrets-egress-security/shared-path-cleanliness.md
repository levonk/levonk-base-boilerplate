---
type: Practice
title: Shared Path Cleanliness
description: The shared/ directory must never contain sensitive information. No vault files, no hardcoded secrets, all secrets use vault variable references. Pre-commit hook validation.
tags: [shared-path, secrets, cleanliness, validation, pre-commit, security]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-20260624001-hybrid-sensitive-information-storage
    resource: shared/active/08-docs/adr/adr-20260624001-hybrid-sensitive-information-storage.md
    title: 'infrahub'
---

# Shared Path Cleanliness

## Failure Mode

Including client-specific secrets in `shared/` directory breaks reusability
across clients, creates security risk of accidental cross-client exposure, and
violates separation of concerns between generic and client-specific
configurations.

## Practice

The `shared/` directory must **never** contain sensitive information.

### Rules

1. No vault files in `shared/` directory
2. No hardcoded secrets in `shared/` service definitions
3. All secrets must use vault variable references
4. Client-specific configurations only in client paths (`levonk/`, future clients)

### Validation

```bash
# Pre-commit hook to check for secrets in shared/
grep -r "password\|secret\|token\|api_key" shared/ --include="*.yml" --include="*.yaml"
```

### Why It Matters

The `shared/` directory contains reusable service definitions, roles, and
configurations that work across any client deployment. Including secrets would:

1. **Break reusability** — shared services couldn't be used by other clients
2. **Create security risk** — accidental exposure of one client's secrets to another
3. **Violate separation of concerns** — mix client-specific with generic configs
4. **Compromise multi-tenancy** — prevent clean client isolation

## Related Concepts

- [Hybrid Vault Storage](hybrid-vault-storage.md) — Where secrets actually live
- [Ansible Vault Distribution](ansible-vault-distribution.md) — How services
  reference vault variables



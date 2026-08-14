---
type: Practice
title: Ansible Vault Distribution
description: Use Ansible vault variables for secure distribution at runtime. Reference pattern: vault variables in client-specific inventory, services reference vault variables, Ansible handles secure distribution.
tags: [ansible, vault, variables, distribution, runtime, security]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-20260624001-hybrid-sensitive-information-storage
    resource: shared/active/08-docs/adr/adr-20260624001-hybrid-sensitive-information-storage.md
    title: 'infrahub'
  - id: vault-password-and-agent-workflow-sections
    resource: Infrahub AGENTS.md
    title: 'vault password and agent workflow sections'
---

# Ansible Vault Distribution

## Failure Mode

Hardcoding secrets in service configurations prevents secure distribution.
Without vault variable references, secret rotation requires editing multiple
files. Missing vault password management breaks deployment.

## Practice

Use **Ansible vault variables** for secure distribution at runtime.

### Reference Pattern

```yaml
# In client-specific host_vars or inventory
proxy_authelia_postgres_password: "{{ vault_authelia_postgres_password }}"
proxy_authelia_redis_password: "{{ vault_authelia_redis_password }}"
proxy_authelia_jwt_secret: "{{ vault_authelia_jwt_secret }}"
```

### Benefits

- Single definition in vault
- Multiple references across services
- Ansible handles secure distribution
- Easy rotation (update vault, redeploy)

### Vault Password Management

- Vault password file at `~/.ansible/vault_password`
- Used for all vault operations:
  ```bash
  ansible-playbook -i inventory.yml playbook.yml \
    --vault-password-file ~/.ansible/vault_password
  ```

### Agent Workflow for New Secrets

When a new secret is needed:
1. Generate the secret value (e.g., `openssl rand -hex 32`)
2. Provide the user with the exact YAML line(s) to add
3. Provide a `docker run` command for interactive `ansible-vault edit`
4. Wait for user confirmation before proceeding

**Never** run `ansible-vault edit` directly (no interactive TTY in agent shell).
**Never** decrypt → edit → re-encrypt manually (corruption risk).

## Related Concepts

- [Hybrid Vault Storage](hybrid-vault-storage.md) — Where vault files live
- [Vault Troubleshooting](vault-troubleshooting.md) — Recovery from vault issues



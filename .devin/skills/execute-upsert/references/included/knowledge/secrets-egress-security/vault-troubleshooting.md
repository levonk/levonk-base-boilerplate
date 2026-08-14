---
type: Practice
title: Vault Troubleshooting
description: Common vault corruption issues (odd-length hex strings, mixed format, wrong password), git history recovery, Docker-based vault editing with directory mount for atomic replace.
tags: [ansible-vault, troubleshooting, corruption, recovery, docker, git-history]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: vault-troubleshooting-and-agent-workflow-sections
    resource: Infrahub AGENTS.md
    title: 'vault troubleshooting and agent workflow sections'
---

# Vault Troubleshooting

## Failure Mode

Vault files become corrupted during creation/editing, producing "Odd-length
string" hex errors. Mixed format files (both encrypted content and inline
encrypted values) cause decryption failures. Wrong vault passwords or version
mismatches prevent access.

## Practice

### Common Issues

1. **Odd-length hex strings**: File corrupted during creation/editing
2. **Mixed format**: File contains both encrypted content and inline encrypted values
3. **Wrong password**: Vault password file doesn't match encryption key
4. **Version mismatch**: Ansible version incompatibility with vault format

### Recovery from Git History

```bash
# Check git history for working versions
cd levonk
git log --oneline --all -- active/02-config/ansible/inventories/group_vars/infrahub-levonk-all.vault.yml

# Restore from known good commit
git show <commit-hash>:active/02-config/ansible/inventories/group_vars/infrahub-levonk-all.vault.yml > /tmp/working-vault.yml
cp /tmp/working-vault.yml active/02-config/ansible/inventories/group_vars/infrahub-levonk-all.vault.yml

# Verify
ansible-vault view <vault-file> --vault-password-file ~/.ansible/vault_password
```

### Docker-Based Vault Editing

When the agent needs a secret added/changed, provide the user with a `docker run`
command for interactive `ansible-vault edit`:

```bash
docker run --rm -it \
  -v "$HOME/.ansible/vault_password:/vault_password:ro" \
  -v "$HOME/p/gh/levonk/infrahub/levonk/active/02-config/ansible/inventories/group_vars:/vault-dir" \
  -e EDITOR=vi \
  alpine/ansible:latest \
  ansible-vault edit /vault-dir/infrahub-levonk-all.vault.yml \
    --vault-password-file /vault_password
```

**Why mount the directory, not the file?** `ansible-vault edit` writes to a temp
file then atomically replaces the original via `os.remove()` + rename. Docker
file bind mounts can't be removed from inside the container (`Errno 16: Resource
busy`). Mounting the directory lets the atomic replace work normally.

### Never Do These

- **Never** run `ansible-vault edit` yourself (no interactive TTY in agent shell)
- **Never** decrypt → edit → re-encrypt manually (corruption risk)
- **Never** store secrets in plaintext files while waiting for the user
- **Never** print the secret value after the user adds it

## Related Concepts

- [Ansible Vault Distribution](ansible-vault-distribution.md) — Normal vault
  usage patterns
- [Hybrid Vault Storage](hybrid-vault-storage.md) — Where vault files live



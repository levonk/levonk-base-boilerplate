---
okf_version: "0.2"
---

# Secrets Egress Security

A compounding knowledge base documenting practices for secret management and
egress security — hybrid vault storage, shared path cleanliness, iron-proxy
egress firewalls, and vault troubleshooting. Each concept captures specific
architectural decisions sourced from real infrahub ADRs and boilerplate
practices.

## Concepts

* [Overview](overview.md) - Synthesis of the full secrets egress security practice set
* [hybrid-vault-storage](hybrid-vault-storage.md) - Per-client central vault for shared secrets, in-service for transient secrets
* [shared-path-cleanliness](shared-path-cleanliness.md) - shared/ directory must never contain sensitive information
* [ansible-vault-distribution](ansible-vault-distribution.md) - Vault variable references for secure distribution at runtime
* [iron-proxy-egress-firewall](iron-proxy-egress-firewall.md) - CI pipeline egress firewall with allowlist, warn mode, domain validation
* [vault-troubleshooting](vault-troubleshooting.md) - Common vault corruption issues, git history recovery, docker-based vault editing
* [regex-dos-prevention](regex-dos-prevention.md) - Catastrophic backtracking in user-supplied regex, Rust regex crate safety, complexity limits
* [path-traversal-in-scanners](path-traversal-in-scanners.md) - Path traversal in file scanning, canonicalization, symlink validation, sandbox patterns
* [toml-config-injection](toml-config-injection.md) - TOML injection vectors, safe serde parsing, config file permissions, env var expansion
* [tree-sitter-grammar-supply-chain](tree-sitter-grammar-supply-chain.md) - Supply-chain risks in tree-sitter grammars, grammar validation, pinning, source review

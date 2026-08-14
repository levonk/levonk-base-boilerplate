# Directory Update Log

## 2026-08-05

* **Ingest**: Authored 4 new security concept pages sourced from the
  project-lint audit (linter/security tool gaps). All pages grounded against
  project-lint/Cargo.toml versions on 2026-08-05.
  - [regex-dos-prevention.md](regex-dos-prevention.md) — catastrophic
    backtracking, Rust regex crate safety, complexity limits (regex 1.10)
  - [path-traversal-in-scanners.md](path-traversal-in-scanners.md) — path
    traversal in file scanning, canonicalization, symlink validation
  - [toml-config-injection.md](toml-config-injection.md) — TOML injection
    vectors, safe serde parsing, config permissions (toml 0.8, serde 1.0)
  - [tree-sitter-grammar-supply-chain.md](tree-sitter-grammar-supply-chain.md)
    — supply-chain risks in tree-sitter grammars, validation, pinning
    (tree-sitter 0.23)
* **Update**: Updated [index.md](index.md) with 4 new concept entries.

## 2026-07-26
* **Migration**: Migrated `## Citations` body sections to `sources` frontmatter with stable `id` attributes per OKF v0.2 §13.1.
* **Migration**: Migrated bundle from OKF v0.1 to OKF v0.2 — bumped `okf_version` in index.md. No `# Citations` sections or `timestamp` fields to migrate.

## 2026-07-17

* **Initialization**: Created the `secrets-egress-security` knowledge bundle to consolidate secret management and egress security practices from infrahub ADRs and boilerplate documentation.
* **Creation**: Authored 5 concept pages covering the security stack.
  - [hybrid-vault-storage.md](hybrid-vault-storage.md) — per-client central vault + in-service transient secrets
  - [shared-path-cleanliness.md](shared-path-cleanliness.md) — shared/ must never contain secrets, pre-commit validation
  - [ansible-vault-distribution.md](ansible-vault-distribution.md) — vault variable references, runtime distribution, agent workflow
  - [iron-proxy-egress-firewall.md](iron-proxy-egress-firewall.md) — CI egress firewall with allowlist, warn/enforce modes
  - [vault-troubleshooting.md](vault-troubleshooting.md) — corruption recovery, git history restore, Docker-based editing
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from ADR-20260624001 (hybrid sensitive information storage, 402 lines) in infrahub, boilerplate AGENTS.md (iron-proxy section), and infrahub AGENTS.md (vault troubleshooting section).

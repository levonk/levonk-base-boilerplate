---
type: Synthesis
title: Secrets Egress Security Overview
description: Synthesis of secret management and egress security practices — hybrid vault storage, shared path cleanliness, Ansible vault distribution, iron-proxy egress firewall, and vault troubleshooting.
tags: [secrets, vault, ansible, egress, security, iron-proxy, overview, synthesis]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: adr-20260624001-hybrid-sensitive-information-storage
    resource: shared/active/08-docs/adr/adr-20260624001-hybrid-sensitive-information-storage.md
    title: 'infrahub'
  - id: iron-proxy-egress-firewall-section
    resource: Boilerplate AGENTS.md
    title: 'iron-proxy egress firewall section'
  - id: vault-troubleshooting-section
    resource: Infrahub AGENTS.md
    title: 'vault troubleshooting section'
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Secrets Egress Security Overview

This bundle documents practices for secret management and egress security in
infrastructure projects. Each concept was extracted from real infrahub ADRs and
boilerplate practices — the decisions that ensure secrets are stored,
distributed, and protected from leakage.

## The Security Stack

```
hybrid-vault → shared-path-clean → ansible-distribution → egress-firewall → troubleshooting
```

| Phase | Practice | Prevents |
|-------|----------|----------|
| Storage | [Hybrid Vault Storage](hybrid-vault-storage.md) | Secret duplication, inconsistent rotation, scattered credentials |
| Cleanliness | [Shared Path Cleanliness](shared-path-cleanliness.md) | Cross-client secret exposure, broken reusability |
| Distribution | [Ansible Vault Distribution](ansible-vault-distribution.md) | Hardcoded secrets, insecure distribution |
| Egress | [Iron-Proxy Egress Firewall](iron-proxy-egress-firewall.md) | Unauthorized outbound traffic, supply chain attacks |
| Recovery | [Vault Troubleshooting](vault-troubleshooting.md) | Vault corruption, lost passwords, broken decryption |
| Regex DoS | [Regex DoS Prevention](regex-dos-prevention.md) | Catastrophic backtracking in user-supplied regex, DFA memory blowup |
| Traversal | [Path Traversal in Scanners](path-traversal-in-scanners.md) | Path traversal in file scanning, symlink following, cross-platform risks |
| Config Injection | [TOML Config Injection](toml-config-injection.md) | TOML injection via crafted values, world-writable config files, unsafe env expansion |
| Grammar Supply | [Tree-Sitter Grammar Supply Chain](tree-sitter-grammar-supply-chain.md) | Unvetted C code in tree-sitter grammars, unpinned grammar versions |

## Scope

This bundle covers **secret management and egress security** — vault storage,
path cleanliness, distribution patterns, CI egress firewalls, and vault
recovery. It does **not** cover:

- Application-level token encryption — see
  [api-auth-payment-practices](../api-auth-payment-practices/overview.md).
- Network VPN security — see
  [infrastructure-networking-practices](../infrastructure-networking-practices/overview.md).
- Code-level security audits — see
  [devsecops-codeguard](../devsecops-codeguard/overview.md).

## Sources

- `shared/active/08-docs/adr/adr-20260624001-hybrid-sensitive-information-storage.md` — infrahub (402 lines)
- Boilerplate AGENTS.md — iron-proxy egress firewall documentation
- Infrahub AGENTS.md — vault troubleshooting and Docker-based vault editing

## Related Knowledge Bundles

- [api-auth-payment-practices](../api-auth-payment-practices/overview.md) —
  Application-level token security
- [infrastructure-networking-practices](../infrastructure-networking-practices/overview.md)
  — Network-level security
- [devsecops-codeguard](../devsecops-codeguard/overview.md) — Code-level
  security practices



---
type: Practice
title: Iron-Proxy Egress Firewall
description: CI pipeline egress firewall using iron-proxy-action. Intercepts all outbound network traffic, validates against allowlist, warn mode for testing, enforce mode for blocking. Domain summary in CI output.
tags: [iron-proxy, egress, firewall, ci-cd, security, allowlist, supply-chain]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: iron-proxy-egress-security-section
    resource: Boilerplate AGENTS.md
    title: 'iron-proxy egress security section'
---

# Iron-Proxy Egress Firewall

## Failure Mode

CI pipelines make unrestricted outbound network requests. Supply chain attacks,
data exfiltration, and unauthorized dependency downloads go undetected. No
audit trail of which domains CI jobs contact.

## Practice

Wrap CI build processes with **iron-proxy-action** — an egress firewall for CI
pipelines that intercepts and validates all outbound network traffic against an
allowlist.

### How It Works

1. Workflow file (`.github/workflows/iron-proxy.yml`) generated from shared partial
2. `egress-rules.yaml` defines allowed domains (npm registry, Node.js, GitHub)
3. Job gated by `if: vars.IRON_PROXY_ENABLED == 'true'` — disabled by default
4. Action installs iron-proxy, redirects DNS through it, locks down outbound with iptables
5. Summary step prints every domain contacted and whether allowed or denied

### Enabling

1. Review `egress-rules.yaml` and add additional domains your build requires
2. Set repository variable: **Settings → Secrets and variables → Actions → Variables** → `IRON_PROXY_ENABLED = true`
3. Run the workflow (triggers on push, PR, manual dispatch)
4. Start with `warn: true` (default) to see all traffic without blocking
5. Once allowlist is dialed in, set `warn: false` to enforce blocking

### Templates with Iron-Proxy Support

- `repo/pnpm-monorepo/` — pnpm monorepo with Nx build orchestration

### Adding to New Templates

1. Create `.github/workflows/iron-proxy.yml.jinja` with partial include
2. Create `egress-rules.yaml.jinja` with partial include
3. Adjust build steps if template uses a different build tool

## Related Concepts

- [Shared Path Cleanliness](shared-path-cleanliness.md) — Part of overall
  security posture
- [Hybrid Vault Storage](hybrid-vault-storage.md) — Secrets that egress firewall
  protects



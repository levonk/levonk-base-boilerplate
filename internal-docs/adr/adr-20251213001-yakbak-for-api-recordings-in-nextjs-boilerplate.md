---
modeline: "vim: set ft=markdown:"
title: "ADR: yakbak for Testing APIs via recordings in RPC calls"
adr-id: "20251213001"
slug: "20251213001-yakbak-for-api-recordings-in-nextjs-boilerplate"
url: "/internal-docs/adr/adr-20251213001-yakbak-for-api-recordings-in-nextjs-boilerplate.md"
synopsis: "Standardizes API testing around recording and replaying HTTP interactions, with yakbak as the current solution."
author: "https://github.com/levonk"
date-created: "2025-12-13"
date-updated: "2025-12-13"
version: "1.0.0"
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "adr", "testing", "tooling", "api", "record-replay", "rpc"]
supersedes: []
superseded-by: []
related-to: ["adr-20251106002-vitest-for-testing", "adr-20251106004-orpc-and-zod-for-apis"]
scope:
  impact-scope: ["all applications", "all packages"]
  excluded-scope: []
---

# Decision Record: yakbak for testing APIs via recordings in RPC calls

- belongs in `internal-docs/adr/adr-20251213001-yakbak-for-api-recordings-in-nextjs-boilerplate.md`

---

## Context

Many applications and packages depend on HTTP APIs, whether those APIs are internal services exposed via RPC adapters or third-party endpoints.
Testing API integrations by calling live upstream services creates problems:

- Tests become flaky due to network and upstream instability.
- CI can fail due to transient outages or rate limiting.
- Local development requires network access and can be slow.

We need a repeatable approach that makes API tests deterministic.

Recording and replaying HTTP interactions is a critical part of that approach:

- Record real upstream responses once.
- Replay the exact same responses in tests.
- Refresh recordings intentionally when API behavior changes.

## Decision

The repository will standardize API integration testing around **recording and replaying HTTP interactions**, with `yakbak` as the current solution.

- `yakbak` is the current tool for recording and replay.
- Recordings ("tapes") are stored under `__test__/api/yakbak/`.
- Test and development code MUST be able to switch between:
  - a live upstream host (record mode)
  - a local yakbak proxy (replay mode)

## Rationale

- `yakbak` provides a simple proxy-based workflow that works with any HTTP client.
- Storing recordings under `__test__/` keeps them close to tests and makes intent obvious.
- The record/replay model reduces network dependency while keeping tests grounded in real responses.

## Technical Approach

### Package scripts

Projects SHOULD provide commands equivalent to:

- `pnpm yakbak:record`
  - Starts a proxy that will record new requests if a tape is missing.

- `pnpm yakbak:replay`
  - Starts the same proxy but forces replay-only behavior.
  - If a tape does not exist, the request returns `404`.

### Default ports and environment variables

Implementations SHOULD support environment variables equivalent to:

- `YAKBAK_UPSTREAM` (example: `https://ipinfo.io`)
- `YAKBAK_PORT` (default: `3030`)
- `YAKBAK_NO_RECORD=1` (replay-only)

## Consequences

### Positive

- Teams can run API integration tests with reduced network dependency.
- Recorded interactions make failures reproducible.
- Replay mode enables offline and CI-friendly test runs.

### Negative

- Adds an extra dependency and workflow to maintain.
- Recorded tapes can drift from real upstream behavior and must be refreshed intentionally.

## Alternatives Considered

- **Nock**: good for unit-level mocking, but less convenient for end-to-end capture of real HTTP interactions.
- **MSW**: excellent for browser/service-worker style mocking, but requires more setup and is not always ideal for server-side only clients.
- **Hand-rolled fixtures**: simple for tiny cases, but does not scale well and tends to diverge across projects.

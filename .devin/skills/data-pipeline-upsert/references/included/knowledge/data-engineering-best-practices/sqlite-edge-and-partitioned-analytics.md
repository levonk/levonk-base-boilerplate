---
type: Practice
title: SQLite-Family Edge Databases and Partitioned Analytics — Turso, libSQL, and One File Per Partition
description: Use SQLite-family embedded databases (Turso — the Rust rewrite of SQLite, and libSQL — the open-contribution fork) for edge and local-first workloads, and partition analytics into one SQLite file per partition (tenant, agent, region, session) so each partition's data is filesystem-isolated and cross-partition queries use ATTACH plus UNION ALL scatter-gather.
tags: [data-engineering, sqlite, turso, libsql, edge-database, embedded-database, partitioning, multi-tenancy, local-first, rust]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: turso-libsql-docs
    resource: "https://docs.turso.tech/libsql"
    title: "Turso libSQL documentation — fork vs rewrite"
  - id: turso-database-github
    resource: "https://github.com/tursodatabase/turso"
    title: "Turso Database — SQLite-compatible database rewritten from scratch in Rust"
  - id: turso-rewrite-blog
    resource: "https://turso.tech/blog/we-will-rewrite-sqlite-and-we-are-going-all-in"
    title: "Turso blog — We will rewrite SQLite. And we are going all-in"
  - id: turso-sync-benchmark
    resource: "https://turso.tech/blog/sync-benchmark"
    title: "Turso Sync benchmark — CDC-based sync vs page-level embedded replicas"
  - id: turso-embedded-replicas-docs
    resource: "https://docs.turso.tech/features/embedded-replicas/introduction"
    title: "Turso Embedded Replicas documentation"
  - id: turso-multi-tenancy
    resource: "https://turso.tech/multi-tenancy"
    title: "Turso — Database Per Tenant multi-tenancy"
  - id: turso-agent-databases
    resource: "https://docs.turso.tech/guides/agent-databases"
    title: "Turso — Agent databases (isolated vs synced patterns)"
  - id: sqlite-sharding-one-laptop
    resource: "https://ehabhussein.com/p/sharding-a-database-demonstrated-on-one-laptop-with-sqlite"
    title: "Sharding a database, demonstrated on one laptop with SQLite — ATTACH scatter-gather"
  - id: sqlite-per-tenant-vs-row-level
    resource: "https://dev.to/helperx/multi-tenant-data-isolation-in-sqlite-per-user-database-files-vs-row-level-5glm"
    title: "Multi-Tenant Data Isolation in SQLite — per-user database files vs row-level"
  - id: sqlite-sharding-strategies
    resource: "https://docs.hagicode.com/en/blog/2026-04-17-sqlite-sharding-strategies-comparison/"
    title: "SQLite Sharding in Practice — three sharding strategies comparison"
---

# SQLite-Family Edge Databases and Partitioned Analytics

## Failure Mode

Application data lives in a central server database (Postgres, MySQL), so every
read pays a network round-trip, offline operation is impossible, and multi-tenant
analytics either share one schema with `WHERE tenant_id` filters (a missed
filter leaks data across tenants) or require heavy row-level-security policy
that is easy to get wrong. Edge and per-partition workloads get the wrong
database shape: a server database where an embedded file would do.

## Symptoms

- A read at the edge takes 50–200 ms of network latency for data that fits in a
  single file on the device.
- The application is unusable offline; a flaky connection drops every query.
- A cross-tenant data leak is traced to one `SELECT` that omitted
  `WHERE tenant_id = ?` — the isolation was enforced by application discipline,
  not by the storage layer.
- Row-level security policies in Postgres grow complex enough that engineers
  are afraid to touch them, and a policy bug exposes every tenant's data.
- Per-partition analytics (per tenant, per agent, per region, per session) are
  run against one giant table, so a heavy query for one partition contends with
  writes for every other partition.

## Practice

### Turso — the Rust rewrite of SQLite

Turso is a ground-up rewrite of SQLite in Rust, maintained by the same team as
libSQL. It is **not** a fork — it is a new implementation that reimplements
SQLite's semantics with a modern, async-first architecture.

- **Async-first** — built for modern runtimes (Linux io_uring, async Rust);
  no global write lock inherited from SQLite's single-writer model.
- **`BEGIN CONCURRENT`** — MVCC-style concurrent writes that SQLite's
  single-writer model cannot offer.
- **Change Data Capture (CDC)** — tracks logical row-level changes, enabling
  sync that sends only what changed instead of whole database pages.
- **SQLite compatibility** — same SQL dialect, file format, and C API (see the
  project's `COMPAT.md` for the gap list, which is closing quickly).
- **Postgres frontend (experimental)** — the engine is a bytecode VM (the
  VDBE, like SQLite); SQLite and Postgres are both frontends that compile to
  it. The project's goal is to be "the LLVM of databases."
- **Deterministic Simulation Testing** — ships with a simulator and partners
  with Antithesis for a deterministic hypervisor to catch edge-case bugs.

Turso recommends the Rust rewrite for **new projects**, especially anything
that needs sync. It is in beta but runs in production at multiple
organizations.

### libSQL — the open-contribution SQLite fork

libSQL is a fork of SQLite, created because SQLite is open-source but not
open-contribution. It is production-ready and fully backwards compatible with
SQLite (same file format, same API).

- **Embedded replicas** — keep a local read replica of a cloud database;
  reads run from the local file in microseconds, writes go to the cloud
  primary by default and reflect back.
- **Native vector search** — built-in, for AI/semantic-search workloads.
- **Same single-writer limit as SQLite** — the fork inherits SQLite's
  fundamental concurrency model; the Rust rewrite removes it.

When to pick which:

| | libSQL (fork) | Turso Database (Rust rewrite) |
|---|---|---|
| Approach | Fork of SQLite | Full rewrite of SQLite |
| Maturity | Production-ready, battle-tested longer | Production-ready, evolving rapidly (beta) |
| Concurrency | Single-writer (inherited from SQLite) | `BEGIN CONCURRENT`, MVCC |
| Sync | Embedded replicas — page-level replication | Turso Sync — CDC-based, local-first writes |
| Best for | Mission-critical workloads today | New projects, agents, edge, high-density, sync |

### Turso Sync vs Embedded Replicas

Sync is the headline reason to choose the Rust rewrite over the fork.

- **Embedded Replicas (libSQL)** replicate at the **physical page** level. A
  small row change transfers the whole page. There is no visibility into what
  logically changed, so writes default to going to the cloud primary (local
  writes are possible but increase sync-error rates). Local replicas could
  diverge on checkpoint and require a wasteful re-bootstrap from the cloud.
- **Turso Sync (Turso Database)** replicates at the **logical row** level via
  CDC. Local-first writes work offline and push later with `push()` / `pull()`.
  Bandwidth and latency are dramatically lower (Turso's benchmark writeup
  documents the gap). Conflict detection is implemented; resolution is not yet.

For new sync workloads, use Turso Sync. For read-heavy server workloads that
want microsecond local reads and can send writes to the cloud, libSQL embedded
replicas remain a sound, battle-tested choice.

### Edge and local-first deployment

Both engines are **embedded** — they run inside the application process, read
from a file on disk, and need no server. This enables:

- **Microsecond reads** at the edge — no network hop.
- **Offline operation** — the app keeps working without connectivity; sync
  catches up when the connection returns.
- **Per-device or per-tenant databases** — each device or tenant gets its own
  file, synced to and from the cloud.

### Partitioned SQLite files for isolated analytics

SQLite's file-per-database model enables a partitioning strategy that server
databases cannot match cheaply: **one SQLite file per partition** (tenant,
agent, region, session, shard). The isolation is enforced by the filesystem,
not by query-time filters.

- **Filesystem-level isolation** — `data/tenants/<tenant_id>.db` contains only
  that tenant's data. A query cannot leak across partitions because the other
  partitions are not in the database. There is no `WHERE tenant_id` to forget.
- **Independent lifecycle** — each partition's file can be deleted, archived,
  encrypted with its own key, restored, or pinned to a region independently.
  A new file type should be created only when there is a hard lifecycle
  boundary (independent deletion, encryption-key, region-residency, or
  restore/replay boundary) that cannot live inside an existing file.
- **No write-lock contention across partitions** — a heavy analytics query for
  partition A holds no lock that blocks writes for partition B.
- **Deterministic routing** — compute the target file from the business ID
  (tenant ID, session ID, hash) without a metadata lookup table. Upper layers
  use a unified interface and stay unaware of the underlying partitions.

### Cross-partition analytics with ATTACH

SQLite's `ATTACH DATABASE` statement opens additional SQLite files inside one
connection, so cross-partition scatter-gather analytics is a single SQL query,
not application-level fan-out:

```sql
ATTACH DATABASE 'data/tenants/t001.db' AS t001;
ATTACH DATABASE 'data/tenants/t002.db' AS t002;
ATTACH DATABASE 'data/tenants/t003.db' AS t003;

SELECT 't001' AS tenant, COUNT(*) FROM t001.events
UNION ALL
SELECT 't002' AS tenant, COUNT(*) FROM t002.events
UNION ALL
SELECT 't003' AS tenant, COUNT(*) FROM t003.events;
```

Limits and trade-offs:

- `SQLITE_MAX_ATTACHED` defaults to **10** and the absolute hard maximum
  (recompile) is **125**. ATTACH scales to tens of files on one machine — a
  real and useful regime — but not to thousands, and not across machines.
- For analytics across many partitions, prefer DuckDB (see
  [DuckDB for Local Analytics](/duckdb-local-analytics.md)) which scans
  Parquet globs without an attach limit, or aggregate per-partition results in
  application code.
- Turso Cloud extends ATTACH across remote databases in the same connection
  (beta, max 10 per query, requires global attach permission and a JWT listing
  attach permissions) — so the pattern works against cloud-hosted partitions
  too, not only local files.

### Operational practices for partitioned files

- **WAL mode + `busy_timeout`** — enable `PRAGMA journal_mode=WAL` and set a
  `busy_timeout` to reduce lock contention on each partition file.
- **Lazy open, explicit close** — open partition files on demand and close
  idle files under an explicit pool policy. Do not enumerate every partition
  file at boot to build correctness-critical state; the partition registry
  lives in a control-plane file (e.g. `global.db`), not in the filesystem walk.
- **Practical per-file limit** — treat roughly **100 GB** as the operational
  ceiling per SQLite file. A partition that nears it is moved by an explicit
  operator workflow to a dedicated backend or a sharded-partition design.
- **No silent intra-partition sharding** — do not shard one partition across
  multiple SQLite files silently. Intra-partition sharding breaks transaction
  boundaries and consistency models; it requires an explicit design that
  defines cross-shard semantics, replay ordering, and recovery.

### When to use this pattern

- **Edge and local-first apps** — Turso Sync or libSQL embedded replicas for
  microsecond reads, offline writes, and cloud catch-up.
- **Multi-tenant SaaS with strict isolation** — one database file per tenant;
  filesystem isolation replaces row-level security.
- **Per-agent analytics** — each AI agent gets its own embedded database
  (Turso's isolated-agent-databases pattern); no shared state, independent
  scaling, simple cleanup on agent retirement.
- **Per-region or per-session analytics** — partition by region for
  data-residency compliance, or by session for high-frequency isolated
  conversation/event logs.

### When NOT to use this pattern

- **High-concurrency writes to one logical dataset** — SQLite's single-writer
  model (libSQL) or the rewrite's still-maturing concurrency (Turso Database)
  are not a replacement for Postgres on a hot shared write path.
- **Petabyte-scale analytics** — use a cloud warehouse (BigQuery, Snowflake);
  see [BigQuery Partitioning and Clustering](/bigquery-partitioning-clustering.md).
- **Cross-partition transactions** — if partitions must update atomically in
  one transaction, a single server database is simpler than distributed
  transaction coordination across files.

## Related Concepts

- [DuckDB for Local Analytics](/duckdb-local-analytics.md) — another in-process
  database, columnar and OLAP-optimized; use DuckDB when analytics span many
  partitions (no ATTACH limit) and SQLite-family engines when you need
  OLTP-style writes, sync, and per-partition isolation.
- [Drizzle ORM Patterns](/drizzle-orm-patterns.md) — the application data
  access layer that connects to SQLite-family databases from TypeScript.
- [CQRS and Caching](/cqrs-and-caching.md) — embedded replicas are a
  cache-first read pattern; Turso Sync's local-first writes extend the
  delayed-read model to delayed-write sync.
- [Data Warehouse Design](/data-warehouse-design.md) — the warehouse is the
  aggregation target for cross-partition analytics that exceed ATTACH's scale.

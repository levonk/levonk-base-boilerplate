---
type: Practice
title: CQRS and Caching — Separate Read and Write Models with Delayed Reads
description: Use Command Query Responsibility Segregation (CQRS) to separate write-optimized and read-optimized models, and implement delayed reads that check cache first before falling back to the source of truth.
tags: [data-engineering, cqrs, caching, read-model, write-model, delayed-read, performance]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: job-aide-ai-resume-analyzer-data-access-patterns
    resource: "https://github.com/lrepo52/job-aide/blob/main/apps/active/job/ai-resume-analyzer/web/typescript/internal-docs/features/todo/"
    title: "job-aide ai-resume-analyzer data access patterns"
  - id: microsoft-cqrs-pattern
    resource: "https://learn.microsoft.com/en-us/azure/architecture/patterns/cqrs"
    title: "Microsoft CQRS pattern"
---

# CQRS and Caching

## Failure Mode

A single data model serves both transactional writes and analytical reads,
leading to slow queries, locking contention, and cache inconsistency when reads
bypass the cache.

## Symptoms

- A `SELECT` for a dashboard triggers row locks on an OLTP table.
- Cache invalidation is complex because writes happen through multiple paths.
- Read models are normalized like write models, causing expensive joins.
- The system cannot scale read traffic independently of write traffic.

## Practice

### Separate Read and Write Models

- **Write model**: normalized, transactional, optimized for integrity.
- **Read model**: denormalized, query-optimized, eventually consistent.
- Use events (CDC, domain events, or outbox pattern) to propagate writes to read
  models.

### Delayed Read Pattern

The job-aide pattern uses `IDelayedRead`:

1. Attempt to read from cache.
2. If cache hit, return immediately.
3. If cache miss, fetch from source of truth, update cache, return.
4. Writes invalidate or update the cache explicitly.

This keeps reads fast while maintaining a single source of truth for the
underlying data.

### Cache Invalidation

- Use TTL for non-critical data.
- Use event-driven invalidation for critical data.
- Avoid manually invalidating cache in multiple code paths — centralize via the
  write service.

### When Not to Use CQRS

- Simple CRUD applications with low read/write asymmetry.
- When strong consistency is required for reads and the cost of eventual
  consistency outweighs the benefit.

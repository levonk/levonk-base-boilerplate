---
modeline: "vim: set ft=markdown:"
title: "ADR: Use PostgreSQL as the Primary Database"
adr-id: 20251106011
slug: 20251106011-postgresql-for-database
url: /internal-docs/adr/adr-20251106011-postgresql-for-database.md
synopsis: Standardize on PostgreSQL as the primary database for both relational data (RDBMS) and vector data storage, leveraging its robustness and the pgvector extension.
author: https://github.com/levonk
date-created: 2025-11-06
date-updated: 2025-11-06
version: 1.0.0
status: "accepted"
aliases: []
tags: ["doc/architecture/adr", "database", "postgresql", "postgres", "rdbms", "vector-db"]
supersedes: []
superseded-by: []
related-to: []
---


## Context

The application requires a persistent data store that can handle traditional relational data (e.g., users, products, subscriptions) as well as modern AI-related data, specifically vector embeddings for similarity searches. We need a solution that is reliable, scalable, and minimizes the number of different database technologies we need to manage.

## Constraints

- The database must be a robust, production-grade relational database management system (RDBMS).
- It must have a viable solution for storing and querying vector embeddings.
- It must be open-source and have a wide range of hosting options, from local Docker containers to managed cloud services.

## Decision

We will use **PostgreSQL** as the single, primary database for the application. This includes:

1. **Relational Data**: Using standard PostgreSQL for all structured application data.
2. **Vector Data**: Using the **`pgvector`** extension to store and query vector embeddings efficiently.

We will leverage managed service providers like **Supabase** or **Neon** for hosting in cloud environments.

## Rationale

- **Unified Data Store**: Using a single database for both relational and vector data dramatically simplifies our architecture. It eliminates the need to deploy, manage, and synchronize two separate database systems, reducing operational complexity and cost.
- **Maturity and Reliability**: PostgreSQL is a world-class, battle-tested open-source RDBMS known for its reliability, feature richness, and strong adherence to SQL standards.
- **Powerful Vector Search**: The `pgvector` extension provides efficient vector similarity search capabilities (including HNSW indexing for performance) directly within PostgreSQL. This allows us to combine vector searches with traditional relational filters in a single query, which is extremely powerful (e.g., "find similar documents created by a specific user after a certain date").
- **Rich Ecosystem**: PostgreSQL has a massive ecosystem of tools, libraries, and managed hosting providers. This ensures we will always have strong community support and a choice of vendors (like Supabase or Neon), preventing vendor lock-in.

## Consequences

- **Positive**:
  - Simplified architecture with fewer moving parts.
  - Reduced operational overhead and infrastructure cost.
  - Ability to perform powerful, combined relational and vector queries.
  - A single, consistent data access pattern for developers.

- **Negative**:
  - For extremely large-scale vector search (>100s of millions of vectors), a specialized vector database might eventually offer better performance. However, `pgvector` is more than sufficient for our foreseeable needs and we can re-evaluate if we reach that scale.

## Alternatives Considered

- **Separate Databases (Postgres + a specialized Vector DB)**: Using a combination like PostgreSQL for relational data and a dedicated vector database (e.g., Pinecone, Weaviate, Milvus) for vectors. This approach might offer the best-in-class performance for each specific task but comes at the significant cost of increased architectural complexity, data synchronization challenges, and higher operational overhead.
- **SQLite**: An excellent choice for lightweight, single-user, or edge applications. However, it is not suitable for our primary, concurrent, multi-user backend due to its limited concurrency support.
- **MySQL**: Another excellent open-source RDBMS. PostgreSQL was chosen for its more advanced feature set and, specifically, the maturity of the `pgvector` extension.

## Rollout / Migration

1. A PostgreSQL instance will be included in our local `docker-compose` setup for development.
2. The `pgvector` extension will be enabled in the development database.
3. Database schemas will be managed using a migration tool (e.g., `drizzle-kit`).
4. For cloud environments, we will provision a managed PostgreSQL instance from a provider like Supabase or Neon.

## References

- [PostgreSQL](https://www.postgresql.org/)
- [pgvector](https://github.com/pgvector/pgvector)
- [Supabase](https://supabase.com/)
- [Neon](https://neon.tech/)

<!-- vim: set ft=markdown: -->

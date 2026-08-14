---
type: Practice
title: Drizzle ORM Patterns — Schema Definition, Migrations, and PostgreSQL
description: Define TypeScript schemas with Drizzle, generate migrations to a migrations directory, use environment-based connection strings, and keep schema files separate from query logic.
tags: [data-engineering, drizzle, orm, typescript, postgresql, migrations, schema]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"

sources:
  - id: job-aide-drizzle-config
    resource: "https://github.com/lrepo52/job-aide/blob/main/apps/active/politics/left-parody/web/typescript/drizzle.config.ts"
    title: "job-aide Drizzle config"
  - id: drizzle-orm-documentation
    resource: "https://orm.drizzle.team/"
    title: "Drizzle ORM documentation"
---

# Drizzle ORM Patterns

## Failure Mode

TypeScript applications use raw SQL or ORM schemas that are not versioned,
leading to schema drift, untracked migrations, and queries that bypass type
safety.

## Symptoms

- A column rename in the database breaks application queries with no compile-time error.
- Migration files are written by hand and fail in CI because they are out of order.
- The schema is defined in multiple places (SQL, TypeScript types, runtime validators).
- Connection strings with credentials are hardcoded in the drizzle config.

## Practice

### Schema Definition

- Define tables in TypeScript using `drizzle-orm/pg-core`:

```typescript
import { pgTable, serial, varchar, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
```

### Migrations

- Use `drizzle-kit generate` to generate migrations from schema changes.
- Store migrations in a `drizzle/` directory and run them with
  `drizzle-kit migrate` in CI/deploy.
- Never hand-edit generated migration files after they have been applied.

### Configuration

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./src/lib/db/schema.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: {
    url: process.env.POSTGRES_URL!,
  },
});
```

- Load `POSTGRES_URL` from environment variables, not the config file.
- Use `POSTGRES_URL` from a secret manager in production.

### Query Patterns

- Keep query logic in repository/service files, not inline in UI components.
- Use Drizzle's query builder for type-safe queries.
- Use transactions for multi-step operations.

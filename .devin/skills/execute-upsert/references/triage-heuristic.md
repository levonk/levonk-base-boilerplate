# Triage Heuristic — Assessing Request Size

The triage heuristic determines whether a user request is large enough to
warrant the full PRD → tasks → execute pipeline, or whether it should be
handled with direct execution.

## Decision Matrix

The request is "large" (warrants the full pipeline) if it meets **2 or more**
of the following criteria:

| Criterion | Question | Large if... |
|-----------|----------|-------------|
| File scope | How many files will this touch? | More than 3 files |
| Module scope | Does this span multiple modules/services? | Yes — different modules |
| Phases | Does this require sequential phases? | Yes — e.g., schema → API → UI → tests |
| Functionality type | Is this new functionality or a fix? | New functionality |
| Scope clarity | Is the scope clear from the request? | No — needs clarifying questions |
| User intent | Does the user reference a PRD/feature/project? | Yes |

## Examples

### Large (run the full pipeline)

- "Add user authentication with OAuth, session management, and role-based
  access control" — touches auth, middleware, database, UI; multiple phases;
  new functionality; scope needs clarification.
- "Build a reporting dashboard with data aggregation, chart rendering, and
  export functionality" — touches data layer, API, UI; multiple phases; new
  functionality.
- "Migrate the database from SQLite to PostgreSQL" — touches config,
  migrations, data layer, tests; multiple phases; scope needs clarification.

### Small (direct execution)

- "Fix the typo in the login button label" — 1 file, fix to existing code,
  clear scope.
- "Add a `maxLength` validator to the name field" — 1-2 files, small feature,
  clear scope.
- "Update the dependency version of lodash" — 1 file, fix, clear scope.

### Borderline (confirm with user)

- "Add a password reset flow" — touches 3-4 files, new functionality, but
  scope is relatively clear. Confirm with the user.
- "Refactor the API client to use async/await instead of promises" — touches
  many files but is a mechanical change. Confirm with the user.

## Confirmation Protocol

When the request is small (fails the heuristic), confirm with the user:

> "This looks like a focused change. I can implement it directly, or run the
> full PRD → tasks → execute pipeline. Which would you prefer?"

When the request is borderline (meets exactly 2 criteria but barely), confirm:

> "This request is moderate in scope. I can run the full PRD → tasks →
> execute pipeline for thorough tracking, or implement it directly. Which
> would you prefer?"

When the request is large (meets 3+ criteria), proceed with the pipeline but
briefly summarize your assessment:

> "This request warrants the full pipeline because it [reasons]. I'll start
> by creating/locating the PRD."

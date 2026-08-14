# Greenfield Example: `create-next-app` Scaffold

This is a worked example of the **greenfield** path through `readme-upsert`. It
shows what the agent should produce when invoked on a freshly scaffolded
project that has no git history, no existing README, and only the files the
scaffolder created.

## Input

A directory just produced by `pnpm dlx create-next-app@latest my-app --typescript --tailwind --eslint`:

```text
my-app/
├── src/
│   └── app/
│       ├── layout.tsx
│       ├── page.tsx
│       └── globals.css
├── public/
│   ├── next.svg
│   └── vercel.svg
├── .eslintrc.json
├── .gitignore
├── next.config.mjs
├── next-env.d.ts
├── package.json
├── pnpm-lock.yaml
├── README.md            # default Next.js placeholder — treat as "no real README"
├── tailwind.config.ts
├── tsconfig.json
└── postcss.config.mjs
```

Notes about the input:

- No `.git/` directory yet (the user has not run `git init`).
- The default `README.md` shipped by `create-next-app` is a placeholder
  ("This is a Next.js project bootstrapped with ...") — for `readme-upsert`
  purposes, treat this as **no real README** and trigger the greenfield
  short-circuit.
- `AGENTS.md` was already created by the caller (`project-adopter` step 10)
  before `readme-upsert` was invoked.

## Phase 1: Greenfield Short-Circuit

The agent detects greenfield (no `.git/`, default placeholder README) and
skips the deep "Review Documentation" / "Analyze Structure" dives. It
extracts only the essentials from the scaffold files:

| Essential | Detected from | Value |
|-----------|---------------|-------|
| Language | `tsconfig.json`, `*.tsx` files | TypeScript 5 |
| Runtime | `package.json` engines | Node.js (Next.js default) |
| Package manager | `pnpm-lock.yaml` | pnpm |
| Build tool / framework | `package.json` dependencies | Next.js 15 |
| Test runner | `package.json` scripts | none configured (no `vitest`/`jest`) — omit Testing section |
| Entry point | `src/app/page.tsx` | Next.js App Router at `src/app/` |
| Lint/format | `.eslintrc.json` | ESLint (FlatConfig optional) |
| Styling | `tailwind.config.ts` | Tailwind CSS |

## Phase 2: Generated README (Excerpt)

Adapted from `references/README-project-root-template.md.tmpl`. Optional
sections that the scaffold does NOT imply (Development Workflow, Testing,
Package Management beyond a one-liner, Troubleshooting, Contributing,
License) are omitted or kept minimal.

````markdown
# my-app

A Next.js 15 web application built with TypeScript, Tailwind CSS, and pnpm.
Scaffolded with `create-next-app`.

## Quick Start

```bash
# Install dependencies
pnpm install

# Start the development server
pnpm dev

# Open http://localhost:3000 in your browser
```

## Build/Test Commands

```bash
# Production build
pnpm build

# Start the production server
pnpm start

# Lint
pnpm lint
```

## Project Structure

```
.
├── src/
│   └── app/             # Next.js App Router entry (layout.tsx, page.tsx, globals.css)
├── public/              # Static assets served as-is
├── next.config.mjs      # Next.js configuration
├── tailwind.config.ts   # Tailwind CSS configuration
├── tsconfig.json        # TypeScript configuration
├── .eslintrc.json       # ESLint configuration
└── package.json         # Scripts and dependencies (pnpm)
```

## AI Agent Documentation

For AI assistants working on this project, see [AGENTS.md](AGENTS.md) for
comprehensive agent-specific workflows and guidelines.

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript 5
- **Styling**: Tailwind CSS
- **Package manager**: pnpm
- **Linting**: ESLint
````

Notes about the generated README:

- "Project Structure" lists **only** the directories that actually exist
  (`src/app/`, `public/`). The template's `apps/`, `packages/`,
  `boilerplates/`, `internal-docs/` directories are omitted because they do
  not exist on disk.
- "Testing" section is omitted because no test runner is configured.
- "Package Management" is folded into the Tech Stack one-liner rather than
  getting a dedicated section, because the scaffold does not imply a
  non-trivial package management workflow.
- "AI Agent Documentation" links to `AGENTS.md` because the caller already
  created it.

## Phase 5: `verify_consistency.py --greenfield` Output

```text
$ uv run --script scripts/verify_consistency.py /tmp/my-app --greenfield --verbose
Verifying README.md consistency in: /tmp/my-app
GREENFIELD MODE — relaxing internal-docs/oos/, internal-docs/adr/, and AGENTS.md cross-checks
  [ok] README.md exists
  [ok] README.md has section: 'Quick Start'
  [ok] README.md has section: 'Project Structure'
  [ok] README.md has section: 'AI Agent Documentation'
  [ok] README.md has H1
  [ok] README.md is 47 lines
  [skip-greenfield] internal-docs/oos/ does not exist — check relaxed
  [skip-greenfield] internal-docs/adr/ does not exist — check relaxed
  [ok] README.md links to AGENTS.md
  [ok] project name consistent: 'my-app'
  [ok] README.md has no AGENTS.md-style sections
  [ok] AGENTS.md has no README-style sections
  [ok] all README.md commands exist in package.json scripts
  [ok] all directories named in README.md Project Structure exist on disk

PASSED — all consistency checks passed
```

If `AGENTS.md` had not been created by the caller, the AGENTS.md cross-checks
would be skipped with a `[skip-greenfield]` line instead of failing.

## What NOT to Do

- Do NOT list `apps/`, `packages/`, `boilerplates/`, or `internal-docs/` in
  the Project Structure if they do not exist on disk.
- Do NOT include a "Testing" section if no test runner is configured.
- Do NOT fail Phase 1 because there is no `internal-docs/` to review.
- Do NOT rewrite the README from scratch on a later brownfield run — switch
  to the brownfield branch and preserve accurate sections.

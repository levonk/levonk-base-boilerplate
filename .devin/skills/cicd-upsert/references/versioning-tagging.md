# Versioning and Tagging

Semantic versioning, conventional commits, and automated release pipelines that
generate versions, changelogs, and git tags from commit history.

## Semantic Versioning

Format: `MAJOR.MINOR.PATCH` (e.g., `1.4.2`)
| Bump | When | Example |
|------|------|---------|
| MAJOR | Breaking API change | `1.4.2` → `2.0.0` |
| MINOR | New feature, backward compatible | `1.4.2` → `1.5.0` |
| PATCH | Bug fix, backward compatible | `1.4.2` → `1.4.3` |
| Pre-release | Unstable / beta | `1.5.0-rc.1`, `2.0.0-beta.3` |

While major is `0`, **any** change may be breaking. Treat MINOR bumps as
breaking in `0.x` — consumers should pin exact versions. The first `1.0.0`
signals a stable public API.

## Conventional Commits

```
<type>[scope]: <description>

[optional body]

[optional footer(s)]
```

### Type Reference

| Type | Bump | Example |
|------|------|---------|
| `feat` | MINOR | `feat(auth): add OAuth2 login` |
| `fix` | PATCH | `fix(api): handle null response` |
| `feat!` / `BREAKING CHANGE:` | MAJOR | `feat(api)!: rename endpoint` |
| `perf` | PATCH | `perf: cache db queries` |
| `chore` | none | `chore: update deps` |
| `docs` | none | `docs: update README` |
| `refactor` | none | `refactor: simplify parser` |
| `test` | none | `test: add unit tests for auth` |
| `build` | none | `build: update Makefile` |
| `ci` | none | `ci: add security scan job` |
| `style` | none | `style: fix formatting` |

### Breaking change markers

```
feat(api)!: rename /users to /accounts          # inline marker
feat(api): rename endpoints                      # footer marker
BREAKING CHANGE: /users is now /accounts
```

## Automated Version Bumping: semantic-release

semantic-release reads commit history, computes the next version, generates a
changelog, creates a git tag, and publishes a GitHub release automatically.

### Workflow Example

```yaml
name: Release

on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0   # Full history for commit analysis
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: pnpm dlx semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### .releaserc.json

```json
{
  "branches": ["main", { "name": "beta", "prerelease": true }],
  "plugins": [
    "@semantic-release/commit-analyzer",
    "@semantic-release/release-notes-generator",
    "@semantic-release/changelog",
    ["@semantic-release/git", { "assets": ["CHANGELOG.md", "package.json"] }],
    "@semantic-release/github"
  ]
}
```

## Commitlint Enforcement

```yaml
# .github/workflows/commitlint.yml
on: { pull_request: }
jobs:
  commitlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - uses: wagoid/commitlint-github-action@v6
```

```js
// commitlint.config.js — extends @commitlint/config-conventional
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: { 'subject-max-length': [2, 'always', 72] },
};
```

## Manual Version Bump (Non-Commit-Driven Projects)

```bash
echo "1.4.3" > VERSION && git add VERSION
git commit -m "chore(release): v1.4.3" && git tag -a v1.4.3 -m "Release v1.4.3"
git push origin main --tags
# CI trigger: on: push: tags: ['v*.*.*']
```

## Git Tag Hygiene

| Practice | Why |
|----------|-----|
| Annotated tags (`git tag -a`) | Stores author, date, message — auditable |
| Tag the release commit | Not a commit *after* the release |
| Use `v` prefix (`v1.2.3`) | Distinguishes from branch names |
| Don't move tags | Immutable history — force-pushing breaks consumers |
| Sign tags (`-s`) | Proves the release came from you — `git tag -s v1.4.3 -m "..."` |

## Tool Recommendations

| Tool | Use case | Notes |
|------|----------|-------|
| semantic-release | Full auto-release from commits | JS ecosystem, plugin-based |
| release-please | Google-style release automation | Multi-package monorepos |
| release-drafter | Draft releases from PRs | Manual publish, lower automation |
| commitlint | Enforce conventional commits | Prevents bad commits early |

---
type: Practice
title: Forge Template Discovery
description: Discover the correct issue/PR templates and contribution-standards directories for the specific forge (GitHub, GitLab, Forgejo, Gitea, Bitbucket) a project is hosted on. Each forge checks different paths in a different priority order.
tags: [forge, github, gitlab, forgejo, gitea, bitbucket, issue-template, pr-template, contribution-guidelines, discovery]
date:
  created: "2026-07-26"
  knowledge-basis: "2026-07-26"
  last-used: "2026-07-26"
sources:
  - id: forgejo-docs-issue-pr-templates
    resource: https://forgejo.org/docs/v8.0/user/issue-pull-request-templates/
    title: "Forgejo — Issue and Pull Request Templates"
  - id: github-docs-issues
    resource: https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests
    title: "GitHub — Using templates to encourage useful issues and pull requests"
  - id: gitlab-docs-templates
    resource: https://docs.gitlab.com/ee/user/project/description_templates.html
    title: "GitLab — Description templates"
---

# Forge Template Discovery

## Rule

Before drafting an upstream issue or PR, determine which forge hosts the
project (GitHub, GitLab, Forgejo, Gitea, Bitbucket) and look for templates
and contribution guidelines in the directories that forge actually checks. Do
not assume every project uses `.github/`.

## Why

Issue and PR templates are forge-specific paths. Submitting a body formatted
for GitHub's `.github/ISSUE_TEMPLATE` to a GitLab-hosted project ignores that
project's configured templates and may fail style or label checks. Similarly,
missing `blank_issues_enabled: false` in a `.github/ISSUE_TEMPLATE/config.yml`
can lead to a rejected free-form issue. The discovery step prevents this by
reading the exact files the target forge will present to users.

## Detecting the forge

Determine the forge from the repository URL:

| URL pattern | Forge | API host |
|-------------|-------|----------|
| `github.com` | GitHub | `api.github.com` |
| `gitlab.com` or self-hosted GitLab | GitLab | `<host>/api/v4` |
| `codeberg.org` or self-hosted Forgejo | Forgejo | `<host>/api/v1` |
| self-hosted Gitea | Gitea | `<host>/api/v1` |
| `bitbucket.org` | Bitbucket | `api.bitbucket.org/2.0` |

For a local repository with no `origin` remote, use `local` as the forge.
There are no templates to discover locally; fall back to the skill's own
default structure.

## Issue template directories (priority order)

### GitHub

1. `.github/ISSUE_TEMPLATE/` (multiple `.md`/`.yaml`/`.yml` files)
2. `ISSUE_TEMPLATE/` (root directory)
3. `docs/ISSUE_TEMPLATE/`
4. `.github/ISSUE_TEMPLATE.md` (single-file form)
5. `issue_template.md` (root-level single file)
6. `docs/ISSUE_TEMPLATE.md`

GitHub also supports a `config.yml` inside the template directory that
disables blank issues and adds contact links.

### Forgejo

Forgejo checks `.forgejo/` → `.gitea/` → `.github/` → `docs/` for migration
ease, and each directory may contain `ISSUE_TEMPLATE/` or `issue_template/`:

1. `.forgejo/ISSUE_TEMPLATE/`
2. `.forgejo/issue_template/`
3. `.gitea/ISSUE_TEMPLATE/`
4. `.gitea/issue_template/`
5. `.github/ISSUE_TEMPLATE/`
6. `.github/issue_template/`
7. `ISSUE_TEMPLATE/` (root)
8. `issue_template/` (root)
9. `docs/ISSUE_TEMPLATE/`
10. `docs/issue_template/`

### Gitea

Same as Forgejo minus `.forgejo/`:

1. `.gitea/ISSUE_TEMPLATE/`
2. `.gitea/issue_template/`
3. `.github/ISSUE_TEMPLATE/`
4. `.github/issue_template/`
5. `ISSUE_TEMPLATE/` (root)
6. `issue_template/` (root)
7. `docs/ISSUE_TEMPLATE/`
8. `docs/issue_template/`

### GitLab

1. `.gitlab/ISSUE_TEMPLATE/`
2. `.gitlab/issue_template/`

GitLab calls PRs "merge requests" and stores their templates in
`.gitlab/merge_request_templates/`.

### Bitbucket

Bitbucket has no native issue template convention. Use the skill's default
issue structure and rely on CONTRIBUTING.md if present.

## PR template directories

### GitHub

1. `.github/PULL_REQUEST_TEMPLATE.md`
2. `.github/pull_request_template.md`
3. `PULL_REQUEST_TEMPLATE.md` (root)
4. `pull_request_template.md` (root)
5. `docs/PULL_REQUEST_TEMPLATE.md`
6. `docs/pull_request_template.md`

### Forgejo / Gitea

Single file per forge directory. `.gitlab/` is intentionally NOT supported for
PR templates.

1. `.forgejo/pull_request_template.md` (Forgejo only)
2. `.forgejo/pull_request_template.yml`
3. `.forgejo/pull_request_template.yaml`
4. `.gitea/pull_request_template.md`
5. `.gitea/pull_request_template.yml`
6. `.gitea/pull_request_template.yaml`
7. `.github/PULL_REQUEST_TEMPLATE.md`
8. `.github/pull_request_template.md`

### GitLab

1. `.gitlab/merge_request_templates/` (multiple `.md` files)

### Bitbucket

No native PR template convention.

## Contribution guidelines and related files

Also check these in forge-specific priority order:

| File | Purpose | Search locations (priority order) |
|------|---------|-----------------------------------|
| `CONTRIBUTING.md` | Human contribution guidelines | `CONTRIBUTING.md` → `.github/CONTRIBUTING.md` → `docs/CONTRIBUTING.md` → `.gitlab/CONTRIBUTING.md` → `.forgejo/CONTRIBUTING.md` → `.gitea/CONTRIBUTING.md` |
| `CODE_OF_CONDUCT.md` | Code of conduct | Same priority pattern as CONTRIBUTING |
| `SECURITY.md` | Security policy | Same priority pattern |
| `AGENTS.md` | AI agent instructions | Root → `.github/` → `.agents/` |
| `CLAUDE.md` | Claude-specific agent instructions | Root |
| `CODEOWNERS` | Review ownership rules | Root → `.github/` → `docs/` → `.gitea/` |
| `CHANGELOG.md` | Changelog format reference | Root → `docs/` |
| `.editorconfig` | Editor formatting conventions | Root |
| Lint configs | Style enforcement | `.markdownlint.json`, `.markdownlint-cli2.jsonc`, `.yamllint.yaml`, `.yamllint.yml`, `statix.toml`, `.eslintrc.*`, `biome.json`, `deno.json` |

## YAML issue templates

GitHub and Forgejo support YAML-form issue templates with structured fields:
`name`, `description`, `labels`, `body` (with `markdown`, `textarea`, `input`,
`dropdown`, `checkboxes`). When a YAML template is found, parse its body
fields and fill them rather than using free-form markdown. Preserve any
`labels` the template declares.

## Blank issues disabled

If an `ISSUE_TEMPLATE/config.yml` contains `blank_issues_enabled: false`, the
project does not accept free-form issues. You must use one of the configured
templates or contact links. Do not file a blank issue — present the constraint
to the user.

## Related

* [Search Before Opening](search-before-opening.md) — how to use discovered
templates and contribution guidelines to avoid duplicates
* [Follow Project Conventions](follow-project-conventions.md) — match the
discovered style when drafting
* [gh --body-file](gh-body-file.md) — once the body is drafted, post it via a file

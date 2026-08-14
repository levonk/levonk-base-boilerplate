---
story_id: "01-001"
story_title: "Fix REPO_ROOT in all copier.yml files"
branch: "feature/current/20260814-boilerplate-copier-fixes/story-01-001-fix-repo-root"
dependencies: []
parallel_safe: true
status: "[x] Done"
---

# Story 01-001: Fix REPO_ROOT in all copier.yml files

## Goal

Add the `REPO_ROOT` variable definition (with default `.`) to every copier.yml file whose template tree includes a .envrc.jinja that references `{{REPO_ROOT}}`, but whose copier.yml does not currently define it.

## Context

The shared `.envrc.jinja` partial (at `_shared/.envrc.jinja`) and per-template `.envrc.jinja` files reference `{{REPO_ROOT}}` for paths like `{{REPO_ROOT}}/node_modules/.bin` and `{{REPO_ROOT}}/.local/bin`. Only 4 templates (nextjs, pnpm-monorepo, fastapi, browser-extension) define `REPO_ROOT` in their copier.yml. The remaining ~36 templates produce broken paths like `/.envrc` because `{{REPO_ROOT}}` evaluates to an empty string.

## Reference Pattern

From `apps/web/typescript/nextjs/copier.yml` (lines 29-32):

```yaml
# REPO_ROOT is used by .envrc.jinja and the shared _shared/.envrc.jinja
# partial as the project root path. At copy time the project root is the
# destination directory itself, so "." is the correct portable value.
REPO_ROOT:
  type: str
  help: "Project root path used inside .envrc (relative to the .envrc file)"
  default: "."
```

## Tasks

- [ ] Identify all copier.yml files whose template tree includes a .envrc.jinja referencing `{{REPO_ROOT}}` but whose copier.yml does not define `REPO_ROOT`
- [ ] For each identified copier.yml, add the `REPO_ROOT` variable definition with default `.` following the reference pattern above
- [ ] Place the definition after `project_name` (or equivalent) and before `description` (or the next variable)
- [ ] Do NOT modify templates that already define REPO_ROOT (nextjs, pnpm-monorepo, fastapi, browser-extension)
- [ ] Verify no copier.yml has syntax errors after modification

## Acceptance Criteria

- [ ] Every copier.yml whose templates use `{{REPO_ROOT}}` defines `REPO_ROOT` with default `.`
- [ ] The definition matches the reference pattern (type: str, help, default: ".")
- [ ] No existing REPO_ROOT definitions are modified
- [ ] All modified copier.yml files are valid YAML

## Relevant Files

- `apps/web/typescript/nextjs/copier.yml` — reference pattern (DO NOT MODIFY)
- `repo/pnpm-monorepo/copier.yml` — reference pattern (DO NOT MODIFY)
- `apps/backend/python/fastapi/copier.yml` — already defines REPO_ROOT (DO NOT MODIFY)
- `apps/plugins/browser-extension/copier.yml` — already defines REPO_ROOT (DO NOT MODIFY)
- All `apps/cli/*/core/copier.yml` — NEEDS FIX
- All `packages/category/general/domain/package-name/*/copier.yml` or `*/files/copier.yml` — NEEDS FIX
- All `packages/category/web/domain/package-name/*/copier.yml` or `*/files/copier.yml` — NEEDS FIX
- `apps/infrastructure/ai-ollama-samples/copier.yml` — NEEDS FIX
- `apps/infrastructure/airflow-project/copier.yml` — NEEDS FIX
- `apps/infrastructure/docker/docker-compose/files/copier.yml` — NEEDS FIX
- `apps/infrastructure/docker/docker-linux/copier.yml` — NEEDS FIX
- `apps/infrastructure/docker/docker-nix/files/copier.yml` — NEEDS FIX
- `apps/infrastructure/docker/test-template/copier.yml` — NEEDS FIX
- `apps/plugins/mcp/mcp-server/copier.yml` — NEEDS FIX
- `apps/plugins/vscode/typescript/copier.yml` — NEEDS FIX
- `repo/git-repo/copier.yml` — NEEDS FIX

## Tech Context (Binding Constraint)

This project uses the following tools. Use them, not alternatives.

- Package manager: none (template catalog, not a software project)
- Ad-hoc runner: devbox run -- <command> for system tools
- Build system: copier (template rendering)
- Template engine: Jinja2 (.jinja files)
- Scripts: Bash
- Environment: devbox + direnv + nix
- Validation: post-copy _tasks grep for unrendered Jinja artifacts

System tools run via: devbox run -- <command>
Never use: npm, npx, yarn, pip install (this is not a Node/Python project)

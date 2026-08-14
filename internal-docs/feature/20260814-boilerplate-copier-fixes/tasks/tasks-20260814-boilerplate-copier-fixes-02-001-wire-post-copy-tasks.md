---
story_id: "02-001"
story_title: "Wire x86 detection + token commit into repo/git-repo post-copy task"
branch: "feature/current/20260814-boilerplate-copier-fixes/story-02-001-wire-post-copy-tasks"
dependencies: ["01-002", "01-003"]
parallel_safe: false
status: "[x] Done"
---

# Story 02-001: Wire x86 detection + token commit into repo/git-repo post-copy task

## Goal

Update the `repo/git-repo/copier.yml` post-copy task (`_tasks:`) to call the shared x86_64-darwin detection script before `devbox install` and the shared token-commit script after `git init`. Also ensure both scripts are available to the generated project.

## Context

The `repo/git-repo` template's post-copy task currently:
1. Runs `git-config-defaults.sh` if available
2. Runs `direnv allow` and `devbox install` (which fails on x86_64-darwin without the nixpkgs pin)
3. Runs `git init` (but creates no initial commit)
4. Creates a gh-pages branch if requested

The task needs to:
1. Run the x86 detection script BEFORE `devbox install` to ensure the nixpkgs pin is in place
2. Run the token-commit script AFTER `git init` to create an initial commit

## Tasks

- [ ] Update `repo/git-repo/copier.yml` `_tasks:` section:
  - Before the `devbox install` call, invoke the x86 detection script to ensure the nixpkgs pin is in devbox.json
  - After `git init`, invoke the token-commit script to create an initial commit
  - The scripts need to be available in the generated project — either:
    - Copy them into the template's `files/` directory so they're rendered into the generated project, OR
    - Inline the script logic directly in the post-copy task bash script
  - Prefer inlining the logic in the post-copy task (using `{% raw %}` blocks to avoid Jinja conflicts) since the scripts are small and the generated project doesn't need to keep them
- [ ] Ensure the post-copy task remains compatible with the existing gh-pages branch creation logic
- [ ] Verify the post-copy task handles the case where devbox/direnv are not installed (existing `|| true` pattern)

## Acceptance Criteria

- [ ] `repo/git-repo/copier.yml` post-copy task calls x86 detection logic before `devbox install`
- [ ] `repo/git-repo/copier.yml` post-copy task calls token-commit logic after `git init`
- [ ] The x86 detection uses the same nixpkgs commit pin as the shared script (`293d6abedf0478e681a4dfcfcb35b30fc796a32f`)
- [ ] The token commit creates a commit with message `Initial commit (scaffolded from boilerplate)` if none exist
- [ ] The gh-pages branch creation logic still works
- [ ] The post-copy task uses `{% raw %}` blocks where needed to avoid Jinja template conflicts with bash syntax

## Relevant Files

- `repo/git-repo/copier.yml` — the file to modify (post-copy `_tasks:` section)
- `_shared/scripts/ensure-devbox-x86-pin.sh` — created in story 01-002 (reference for logic to inline)
- `_shared/scripts/token-commit.sh` — created in story 01-003 (reference for logic to inline)

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

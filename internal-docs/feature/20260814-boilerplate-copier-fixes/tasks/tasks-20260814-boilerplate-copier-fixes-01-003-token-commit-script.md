---
story_id: "01-003"
story_title: "Create shared token-commit script"
branch: "feature/current/20260814-boilerplate-copier-fixes/story-01-003-token-commit-script"
dependencies: []
parallel_safe: true
status: "[x] Done"
---

# Story 01-003: Create shared token-commit script

## Goal

Create a shared bash script at `_shared/scripts/token-commit.sh` that creates an initial git commit in the current directory if no commits exist yet. This script is intended to be called from copier post-copy tasks (`_tasks:`) to ensure generated projects have a clean git baseline.

## Context

After copier generates a project, the `repo/git-repo` template runs `git init` but does not create an initial commit. Without an initial commit, users cannot easily branch from a clean baseline, and tools that expect at least one commit (like some CI systems or branch protection rules) may not work correctly.

## Tasks

- [ ] Create `_shared/scripts/token-commit.sh`
- [ ] The script must:
    - Initialize git if `.git` does not exist (`git init`)
    - Check if there are any commits (`git rev-parse --verify HEAD 2>/dev/null`)
    - If no commits exist:
      - Stage all files (`git add -A`)
      - Create an initial commit with message `Initial commit (scaffolded from boilerplate)`
      - Use `git commit --allow-empty` as a fallback if staging fails (e.g., in a .gitignore-only directory)
    - If commits already exist, do nothing (non-destructive, exit 0)
    - Exit 0 on success or no-op, exit 1 on error
- [ ] Make the script executable (`chmod +x`)
- [ ] Add a comment header explaining the script's purpose
- [ ] The script must be self-contained (no dependencies beyond git and bash)

## Acceptance Criteria

- [ ] Script exists at `_shared/scripts/token-commit.sh`
- [ ] Script is executable
- [ ] In a directory with no git repo: creates git repo, stages files, creates initial commit
- [ ] In a git repo with no commits: stages files, creates initial commit
- [ ] In a git repo with existing commits: no-op (exit 0, does not create additional commit)
- [ ] Script is self-contained (only depends on git and bash)

## Relevant Files

- `repo/git-repo/copier.yml` — has post-copy task that does `git init` but no token commit (will be wired in story 02-001)

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

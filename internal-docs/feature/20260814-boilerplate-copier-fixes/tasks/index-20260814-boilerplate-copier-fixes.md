# Boilerplate Copier Fixes — Task Index

## Overview

This index summarizes all stories for the boilerplate copier fixes: REPO_ROOT definition, x86_64-darwin devbox pin detection, and token commit script.

## Phase Summary

- **Phase 01**: Parallel Foundation (3 stories) — REPO_ROOT fix, x86 detection script, token-commit script
- **Phase 02**: Integration (1 story) — Wire scripts into repo/git-repo post-copy task

## Story Details

### Phase 01: Parallel Foundation

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Status |
| -------- | ----------- | ------ | ------------ | ------------- | ------ |
| 01-001 | Fix REPO_ROOT in all copier.yml files | feature/current/20260814-boilerplate-copier-fixes/story-01-001-fix-repo-root | None | Parallel-safe: true | [x] Done |
| 01-002 | Create shared x86_64-darwin detection script | feature/current/20260814-boilerplate-copier-fixes/story-01-002-x86-detection-script | None | Parallel-safe: true | [x] Done |
| 01-003 | Create shared token-commit script | feature/current/20260814-boilerplate-copier-fixes/story-01-003-token-commit-script | None | Parallel-safe: true | [x] Done |

### Phase 02: Integration

| Story ID | Story Title | Branch | Dependencies | Parallel-safe | Status |
| -------- | ----------- | ------ | ------------ | ------------- | ------ |
| 02-001 | Wire x86 detection + token commit into repo/git-repo post-copy task | feature/current/20260814-boilerplate-copier-fixes/story-02-001-wire-post-copy-tasks | 01-002, 01-003 | Parallel-safe: false | [x] Done |

## Status Legend

| Marker | Meaning |
|--------|---------|
| `[ ] Todo` | Not started, ready to run if dependencies are `[x] Done` |
| `[~] In-Progress` | Subagent currently running or paused mid-work |
| `[x] Done` | Completed and verified |
| `[!] Blocked` | Cannot proceed — needs human input, missing dependency, or external action |

# Documentation Update Guidance — Phase 5

After all stories are completed (or when the user pauses execution), the
controller must update documentation to reflect the final state of the
project. This covers both PRD/task files and project-level documentation.

## 1. PRD and Task File Updates

### PRD Updates

Update the PRD file (`internal-docs/feature/YYYY/MM/{slug}/feat-*.md`) to
reflect what was actually built:

- **Status section**: Add or update a "Status" or "Implementation Status"
  section at the top or bottom of the PRD summarizing:
  - What was implemented (vs. what was planned)
  - Deviations from the original plan and why
  - Decisions made during implementation
  - Deferred items (if any) with reasons
- **Requirements**: Mark each requirement as `[x] Implemented`, `[~] Partially
  Implemented`, or `[ ] Deferred` with a reason.
- **Current State**: Update the "Current State" section to reflect the new
  state of the codebase after implementation.

### Task Index Updates

Update the task index file
(`internal-docs/feature/YYYY/MM/{slug}/tasks/index-[PRD-NAME].md`):

- All stories should be `[x] Done` or explicitly marked as deferred/blocked.
- For deferred/blocked stories, add a "Reason" column or note explaining why.
- Verify the "Branch" column reflects the actual branch used.

### Per-Story File Updates

For each story file
(`internal-docs/feature/YYYY/MM/{slug}/tasks/tasks-[PRD-NAME]-*-*.md`):

- Ensure the "Relevant Files" section lists ALL files created or modified.
- Ensure all acceptance criteria are checked `[x]`.
- If any acceptance criteria were not met, document why and what was done
  instead.

## 2. Project-Level Documentation Updates

Delegate to a subagent that updates project-level documentation based on what
was built. The subagent should check and update each of the following as
needed:

### README.md

Update if the feature:
- Adds new user-facing capabilities or commands
- Changes installation or setup instructions
- Adds new configuration options
- Changes the project's feature list

### API Documentation

Update if the feature:
- Adds or changes API endpoints
- Changes request/response schemas
- Adds or changes authentication requirements
- Changes error codes or responses

### Architecture Documentation

Update if the feature:
- Changes the system architecture (new services, removed services, changed
  data flow)
- Introduces new patterns or conventions
- Changes dependency relationships between components

### AGENTS.md

Update if the feature:
- Introduces new conventions or patterns that future agents need to know
- Changes build, test, or lint commands
- Adds new directories or file patterns that agents should be aware of
- Changes the project's tech stack or dependencies

### CHANGELOG.md

Update if the project maintains a changelog. Follow the project's existing
changelog format (e.g., Keep a Changelog). Add an entry for the feature with:
- Added: new capabilities
- Changed: changes to existing functionality
- Deprecated: features marked for removal
- Removed: removed features
- Fixed: bug fixes
- Security: security-related changes

## 3. Commit Strategy

Documentation updates should be committed separately from code changes:

```bash
git add . && git commit -m "docs: update documentation for [PRD-NAME]" \
  -m "- Updated README, API docs, architecture docs" \
  -m "Related to PRD [PRD-NAME]"
```

If the project uses a different commit convention (check `AGENTS.md`), follow
that convention instead.

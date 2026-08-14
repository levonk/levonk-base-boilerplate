---
workflow: "Tasks Processor"
slug: "tasks-processor"
description: "Execute task stories created by tasks-from-prd, tracking progress in the index file"
use: "When implementing task stories from a generated task index, marking progress and committing per story"
role: "Developer"
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-30"
  last-used: "2026-07-30"
tags:
  - "ai/workflow/software-dev/tasks/processor"
  - "task-execution"
  - "progress-tracking"
see-also:
  - workflow: "tasks-from-prd"
    relationship: "previous-step"
    description: "Produces the task stories this workflow executes"
  - skill: "execute-upsert"
    relationship: "complement"
    description: "Orchestrates PRD creation, task breakdown, and execution as a pipeline"
---

---
description: Date-embedded naming convention for institutional memory documents (ADRs, features, out-of-scope)
---

# Date-Embedded Naming Convention

## Purpose

Date-embedded filenames and directory structures make documents:
- **Chronologically sortable** - Files sort naturally by date when listed alphabetically
- **Contextually readable** - Date and time are visible at a glance
- **Universally unique** - Timestamp prevents naming collisions
- **Human-friendly** - Easy to understand timeline and ordering
- **Organized by time** - Year/month directory structure keeps related documents together

## Pattern

```
internal-docs/{type}/YYYY/MM/{type}-YYYYMMDDHHmm-{slug}.md
```

For features, the pattern includes a feature-specific subdirectory:
```
internal-docs/feature/YYYY/MM/{slug}/feat-YYYYMMDDHHmm-{slug}.md
```

### Components

- **{type}**: Document type directory
  - `adr` - Architecture Decision Records (accepted decisions)
  - `oos` - Out of Scope (rejected features/decisions)
  - `feature` - Features (implemented functionality)

- **{YYYY}**: Year directory (4-digit year)
  - Example: `2025` for year 2025

- **{MM}**: Month directory (2-digit month)
  - Example: `06` for June

- **{slug}**: Feature-specific subdirectory (for features only)
  - URL-friendly slug matching the feature name
  - Contains the feature document and related tasks
  - Example: `user-authentication`, `dark-mode-support`

- **{type}-**: Document type prefix in filename
  - Matches the directory type

- **{YYYYMMDDHHmm}**: Creation timestamp (ISO 8601 datetime format)
  - Example: `202506251430` for June 25, 2025 at 14:30 (2:30 PM)
  - Use the date and time the document is created, not when the decision was made

- **{slug}**: URL-friendly slug (in filename)
  - Lowercase with hyphens instead of spaces
  - Short but descriptive (aim for 3-6 words)
  - Example: `template-based-ai-workflow-sync`, `dark-mode-support`

### Examples

- `internal-docs/adr/2025/01/adr-202501311430-template-based-ai-workflow-sync.md`
- `internal-docs/oos/2025/06/oos-202506250915-dark-mode-support.md`
- `internal-docs/feature/2025/06/user-authentication/feat-202506251630-user-authentication.md`

## Usage by Document Type

### Architecture Decision Records (ADRs)
- **Location**: `internal-docs/adr/YYYY/MM/`
- **Prefix**: `adr`
- **Purpose**: Document accepted architectural decisions
- **Status**: Accepted, Proposed, Deprecated, Superseded

### Out of Scope Documents
- **Location**: `internal-docs/oos/YYYY/MM/`
- **Prefix**: `oos`
- **Purpose**: Document rejected features and out-of-scope decisions
- **Status**: Rejected, Deferred, Out of Scope

### Feature Documents
- **Location**: `internal-docs/feature/YYYY/MM/{slug}/`
- **Prefix**: `feat`
- **Purpose**: Document implemented features and functionality
- **Status**: Draft, Planning, Ready, In Progress, Testing, Complete, Deprecated
- **Structure**: Each feature has its own subdirectory containing the feature document and a `tasks/` subdirectory

## Directory Structure

```
internal-docs/
├── adr/
│   ├── 2025/
│   │   ├── 01/
│   │   │   ├── adr-202501311430-template-based-ai-workflow-sync.md
│   │   │   └── adr-202501311600-nix-direnv-dev-environment.md
│   │   └── 02/
│   │       └── adr-202502041030-ai-loop-orchestrator-prd.md
│   └── 2026/
│       └── 01/
│           └── adr-202601101200-new-architecture.md
├── oos/
│   └── 2025/
│       └── 06/
│           ├── oos-202506250915-dark-mode-support.md
│           └── oos-202506251430-plugin-system.md
└── feature/
    └── 2025/
        └── 06/
            ├── user-authentication/
            │   ├── feat-202506251630-user-authentication.md
            │   └── tasks/
            │       ├── tasks-user-authentication-01-001-user-tables.md
            │       └── tasks-user-authentication-02-001-user-signup-api.md
            └── api-rate-limiting/
                ├── feat-202506251745-api-rate-limiting.md
                └── tasks/
                    └── tasks-api-rate-limiting-01-001-rate-limiter.md
```

## Timestamp Management

### Generating the Timestamp
Use the current date and time when creating the document:
```bash
# Current timestamp in YYYYMMDDHHmm format
date +"%Y%m%d%H%M"
# Example output: 202506251430
```

### Timezone Considerations
- Use your local timezone consistently
- Document the timezone convention in your project's AGENTS.md if needed
- For distributed teams, consider using UTC

## Cross-References

Documents should reference related documents using their full paths:

```markdown
See also: [ADR-20250131](../adr/2025/01/adr-202501311430-template-based-ai-workflow-sync.md)
Related: [OOS-20250625](../oos/2025/06/oos-202506250915-dark-mode-support.md)
Feature: [User Authentication](../feature/2025/06/feat-202506251630-user-authentication.md)
```

## Benefits Over Alternative Naming

### Compared to Flat Directory Structure
- ✅ Natural organization by time periods
- ✅ Easier to find documents from specific timeframes
- ✅ Better performance with many files in each type
- ✅ Simple archival by year/month

### Compared to Sequence Numbers
- ✅ No need to track sequence state
- ✅ Timestamp provides both ordering and uniqueness
- ✅ Multiple documents per minute are rare (use seconds if needed: `YYYYMMDDHHmmSS`)

### Compared to Random/UUID
- ✅ Human-readable and meaningful
- ✅ No need to reference lookup tables
- ✅ Natural sorting works everywhere
- ✅ Temporal context visible at a glance

## Best Practices

1. **Use creation timestamp** - When a document is written, use that exact time
2. **Keep slugs short** - Aim for 3-6 words, hyphenated
3. **Create directories as needed** - Year/month directories are created on-demand
4. **Reference related documents** - Link to related ADRs, features, or out-of-scope items
5. **Consistent timezone** - Use the same timezone for all timestamps

## Template Integration

This naming convention should be referenced in:
- ADR templates
- Feature templates
- Out-of-scope templates
- AGENTS.md generation workflows

Use the include directive to reference this convention:
```jinja2
{{ include "templates/includes/naming-convention-date-embedded.md" . }}
```


# Task List Management

Guidelines for managing task lists in markdown files to track progress on completing a PRD

## Scope

This workflow processes tasks that were already created by `tasks-from-prd.md` (PRD-to-tasks) workflow.

- If a missing task is discovered, propose it explicitly and pause for user approval before adding.

## Task Implementation

- **First sub-task:** Automatically start the first sub-task without waiting for permission.
- **Work protocol:**
  0. **Task Selection (Automatic Fallback):**
     - When the user specifies a task file pattern (e.g., `tasks-[PRD]-01-003-*.md`):
       1. Check if the specified task file exists in the tasks directory
       2. If the file does NOT exist:
          - Read the index file (`index-[PRD-NAME-KEBAB-CASE].md`)
          - Find the first story with status `[ ] Todo` that has all dependencies completed
          - If no pending tasks with completed dependencies exist, report this to the user
          - Otherwise, use that task file and inform the user: "Specified task file not found. Using first pending task: [Story ID] - [Story Title]"
       3. If the file exists but the story status is `[x] Done`:
          - Read the index file
          - Find the next story with status `[ ] Todo` that has all dependencies completed
          - If no pending tasks with completed dependencies exist, report this to the user
          - Otherwise, use that task file and inform the user: "Specified task is already done. Using next pending task: [Story ID] - [Story Title]"
       4. If the file exists and is not done, proceed with that task
     - When selecting a fallback task, always verify that all dependencies are marked `[x] Done` in the index file before proceeding
  1. **Before starting the first sub‑task of a story:**
     - Mark the story as in-progress in the **index file** (`index-[PRD-NAME-KEBAB-CASE].md`) by changing `[ ] Todo` to `[~] In-Progress`
  2. **Check prerequisites:** Before marking any task or sub-task as in-progress, verify that all dependencies listed in the story's `dependencies` field are completed (marked `[x] Done` in the overview table).
     - If any dependency is not completed: Mark the story as `[!] Blocked` in the overview table, communicate which dependencies are incomplete and why the work cannot proceed, and wait for user direction.
     - Only proceed to mark tasks in-progress when all prerequisites are satisfied.
     - **Invoke the `git-repository-management` skill** to create a pre-run checkpoint tag before starting work on the story. Pass `--slug [PRD-NAME-KEBAB-CASE]-[STORY-ID]-[STORY-NAME-KEBAB-CASE]` so the automatic pre-tag references the feature, task ID, and story slug. The resulting tag format is `tags/auto/YYYY/MM/YYYYMMDDHHmmss-[PRD-NAME-KEBAB-CASE]-[STORY-ID]-[STORY-NAME-KEBAB-CASE]-pre`.
  3. When you start a **sub‑task**, immediately mark it, and its parent task, as in-progress by changing `[ ]` to `[~]`.
  4. When you finish a **sub‑task**, immediately mark it as completed by changing `[ ]` to `[x]`.
  5. After finishing a **sub-task**, run type checks and linting.
  6. Complete all sub-tasks before stopping. If a need for feedback exists, operate on other subtasks, marking the current sub-task as blocked and communicating the reason after all possible sub-tasks are addressed.
  7. If **all** subtasks underneath a parent task are now `[x]`, follow this sequence:
  - **First**: Run the full test suite `just test`
  - **Second**: Verify each acceptance criteria in the story file:
    - For each acceptance criterion listed in the "Acceptance Criteria" section:
      - **Identify the test method**: Determine which test(s) verify this criterion (from Test Plan section or by inspection)
      - **Execute the verification**: Run the specific tests or perform manual verification as needed
        - If tests exist in Test Plan: Run those specific test commands
        - If no tests specified: Design and execute appropriate tests (unit, integration, or end-to-end)
        - If manual verification needed: Perform the manual check and document the result
      - **Validate the result**: Confirm the criterion is actually met by the implementation
      - **Mark as checked**: Update the story file to change `[ ]` to `[x]` for that criterion
      - **If a criterion fails**: Fix the implementation, re-run tests, and retry verification before marking as checked
    - **Critical Requirement**: Do NOT mark the story as complete until ALL acceptance criteria are verified and checked `[x]`. This is a mandatory gate before proceeding to commit.
  - **Only if all tests pass AND all acceptance criteria are verified and checked `[x]`**: Stage changes (`git add .`)
    - **Important**: The staged changes MUST include both the code implementation changes AND the updated task file (with acceptance criteria marked as checked). These must be committed together in a single commit, not as separate commits.
  - **Clean up**: Remove any temporary files and temporary code before committing
  - **Commit**: Use a descriptive commit message that follows repository conventions:
    - Uses scoped conventional commit format (`feat(moduleA):`, `fix(moduleB):`, `refactor(moduleC):`, etc.) as specified in the shared task definitions
    - Summarizes what was accomplished in the parent task
    - Lists key changes and additions
    - References the task number and PRD context
    - **Formats the message as a single-line command using `-m` flags**, e.g.:

        ```bash
        git commit -m "feat(moduleA): add payment validation logic" -m "- Validates card type and expiry" -m "- Adds unit tests for edge cases" -m "Related to 02-001 in PRD user-handling"
        ```

  8. Once all the subtasks are marked completed, all acceptance criteria are verified and checked `[x]`, and changes (including task file updates) have been committed together, mark the **parent task** as completed.
  9. **After completing all subtasks for a story:** Mark the story as done in the **index file** (`index-[PRD-NAME-KEBAB-CASE].md`) by changing `[~] In-Progress` to `[x] Done`.
     - Set a `git tag tags/tasks/[PRD-NAME-KEBAB-CASE]/[STORY-ID]-done` moving the tag if necessary.
     - **If this is the last story** (no remaining stories with status `[ ] Todo` or `[~] In-Progress` in the index file): **Invoke the `git-repository-management` skill** to create a post-run checkpoint tag. Pass `--slug [PRD-NAME-KEBAB-CASE]-[STORY-ID]-[STORY-NAME-KEBAB-CASE]` so the automatic post-tag references the feature, task ID, and story slug. The resulting tag format is `tags/auto/YYYY/MM/YYYYMMDDHHmmss-[PRD-NAME-KEBAB-CASE]-[STORY-ID]-[STORY-NAME-KEBAB-CASE]-post`.
  10. **Final Summary Output**: After each pause for permission OR when the story is complete, print a summary with:
     - **File path**: The story file being processed
     - **Phase/Story ID**: The phase and story number (e.g., "Phase 02, Story 02-003")
     - **Subtask completion**: Number of completed subtasks vs. total subtasks (e.g., "5/9 subtasks completed")
     - Format this as the last part of your response before waiting for user input or concluding.

## Task List Maintenance

1. **Update the task list as you work:**
   - Mark tasks and subtasks as in-progress (`[~]`) per the protocol above.
   - Mark tasks and subtasks as completed (`[x]`) per the protocol above.
   - Add new tasks as they emerge (after approval).

2. **Maintain the "Relevant Files" section:**
   - List every file created or modified.
   - Give each file a one‑line description of its purpose.

## AI Instructions (Per-Story Files)

When working with task lists, the AI must:

1. Assume the primary reader of the task list is a **junior developer** who will implement the feature.

## Outputs

Initialize and maintain artifacts for stories already defined by `tasks-from-prd.md` workflow:

1. **PRD Dashboard (status table)** — A single overview file that tracks all stories across sequential phases and parallel sets.
2. **Per-Story Files** — One file per story with detailed scope, dependencies, and acceptance criteria.

### 1) PRD Dashboard (Markdown table)

- **Location:** `internal-docs/feature/YYYY/MM/{slug}/tasks/`
- **Filename:** `index-[PRD-NAME-KEBAB-CASE].md`
- **Purpose:** Central status hub for all stories, optimized for parallel execution tracking.

Recommended table structure:

```markdown
| Story ID | Title | Phase | Status | Assignee | Parallel-safe | Dependencies | Dependants | Modules | Branch |
|---|---|---:|---|---|---|---|---|---|---|
| 01-001 | Groundwork: Schema | 01 | [x] Done | @dev1 | true | — | 02-001 | db, migrations | feature/current/[PRD]/story-01-001-schema |
| 01-002 | CI/CD setup | 01 | [x] Done | @dev2 | true | — | 02-002 | ci | feature/current/[PRD]/story-01-002-cicd |
| 02-001 | API: Signup | 02 | [ ] Todo | @dev3 | true | 01-001 | 03-001 | api, auth | feature/current/[PRD]/story-02-001-signup-api |
```

Status values:

- `[ ] Todo`, `[~] In-Progress`, `[x] Done`, `[!] Blocked`

Notes:

- Use Story ID format `PP-III` (phase two digits, parallel index three digits).
- Branch format: `feature/current/[PRD-NAME-KEBAB-CASE]/story-[PP]-[III]-[STORY-NAME-KEBAB-CASE]`.
- Keep dashboard in sync with per-story files after each change.

## Shared Task Definitions

---
description: Shared task definitions for software-dev task workflows
---

---
description: Date-embedded naming convention for institutional memory documents (ADRs, features, out-of-scope)
---

# Date-Embedded Naming Convention

## Purpose

Date-embedded filenames and directory structures make documents:
- **Chronologically sortable** - Files sort naturally by date when listed alphabetically
- **Contextually readable** - Date and time are visible at a glance
- **Universally unique** - Timestamp prevents naming collisions
- **Human-friendly** - Easy to understand timeline and ordering
- **Organized by time** - Year/month directory structure keeps related documents together

## Pattern

```
internal-docs/{type}/YYYY/MM/{type}-YYYYMMDDHHmm-{slug}.md
```

For features, the pattern includes a feature-specific subdirectory:
```
internal-docs/feature/YYYY/MM/{slug}/feat-YYYYMMDDHHmm-{slug}.md
```

### Components

- **{type}**: Document type directory
  - `adr` - Architecture Decision Records (accepted decisions)
  - `oos` - Out of Scope (rejected features/decisions)
  - `feature` - Features (implemented functionality)

- **{YYYY}**: Year directory (4-digit year)
  - Example: `2025` for year 2025

- **{MM}**: Month directory (2-digit month)
  - Example: `06` for June

- **{slug}**: Feature-specific subdirectory (for features only)
  - URL-friendly slug matching the feature name
  - Contains the feature document and related tasks
  - Example: `user-authentication`, `dark-mode-support`

- **{type}-**: Document type prefix in filename
  - Matches the directory type

- **{YYYYMMDDHHmm}**: Creation timestamp (ISO 8601 datetime format)
  - Example: `202506251430` for June 25, 2025 at 14:30 (2:30 PM)
  - Use the date and time the document is created, not when the decision was made

- **{slug}**: URL-friendly slug (in filename)
  - Lowercase with hyphens instead of spaces
  - Short but descriptive (aim for 3-6 words)
  - Example: `template-based-ai-workflow-sync`, `dark-mode-support`

### Examples

- `internal-docs/adr/2025/01/adr-202501311430-template-based-ai-workflow-sync.md`
- `internal-docs/oos/2025/06/oos-202506250915-dark-mode-support.md`
- `internal-docs/feature/2025/06/user-authentication/feat-202506251630-user-authentication.md`

## Usage by Document Type

### Architecture Decision Records (ADRs)
- **Location**: `internal-docs/adr/YYYY/MM/`
- **Prefix**: `adr`
- **Purpose**: Document accepted architectural decisions
- **Status**: Accepted, Proposed, Deprecated, Superseded

### Out of Scope Documents
- **Location**: `internal-docs/oos/YYYY/MM/`
- **Prefix**: `oos`
- **Purpose**: Document rejected features and out-of-scope decisions
- **Status**: Rejected, Deferred, Out of Scope

### Feature Documents
- **Location**: `internal-docs/feature/YYYY/MM/{slug}/`
- **Prefix**: `feat`
- **Purpose**: Document implemented features and functionality
- **Status**: Draft, Planning, Ready, In Progress, Testing, Complete, Deprecated
- **Structure**: Each feature has its own subdirectory containing the feature document and a `tasks/` subdirectory

## Directory Structure

```
internal-docs/
├── adr/
│   ├── 2025/
│   │   ├── 01/
│   │   │   ├── adr-202501311430-template-based-ai-workflow-sync.md
│   │   │   └── adr-202501311600-nix-direnv-dev-environment.md
│   │   └── 02/
│   │       └── adr-202502041030-ai-loop-orchestrator-prd.md
│   └── 2026/
│       └── 01/
│           └── adr-202601101200-new-architecture.md
├── oos/
│   └── 2025/
│       └── 06/
│           ├── oos-202506250915-dark-mode-support.md
│           └── oos-202506251430-plugin-system.md
└── feature/
    └── 2025/
        └── 06/
            ├── user-authentication/
            │   ├── feat-202506251630-user-authentication.md
            │   └── tasks/
            │       ├── tasks-user-authentication-01-001-user-tables.md
            │       └── tasks-user-authentication-02-001-user-signup-api.md
            └── api-rate-limiting/
                ├── feat-202506251745-api-rate-limiting.md
                └── tasks/
                    └── tasks-api-rate-limiting-01-001-rate-limiter.md
```

## Timestamp Management

### Generating the Timestamp
Use the current date and time when creating the document:
```bash
# Current timestamp in YYYYMMDDHHmm format
date +"%Y%m%d%H%M"
# Example output: 202506251430
```

### Timezone Considerations
- Use your local timezone consistently
- Document the timezone convention in your project's AGENTS.md if needed
- For distributed teams, consider using UTC

## Cross-References

Documents should reference related documents using their full paths:

```markdown
See also: [ADR-20250131](../adr/2025/01/adr-202501311430-template-based-ai-workflow-sync.md)
Related: [OOS-20250625](../oos/2025/06/oos-202506250915-dark-mode-support.md)
Feature: [User Authentication](../feature/2025/06/feat-202506251630-user-authentication.md)
```

## Benefits Over Alternative Naming

### Compared to Flat Directory Structure
- ✅ Natural organization by time periods
- ✅ Easier to find documents from specific timeframes
- ✅ Better performance with many files in each type
- ✅ Simple archival by year/month

### Compared to Sequence Numbers
- ✅ No need to track sequence state
- ✅ Timestamp provides both ordering and uniqueness
- ✅ Multiple documents per minute are rare (use seconds if needed: `YYYYMMDDHHmmSS`)

### Compared to Random/UUID
- ✅ Human-readable and meaningful
- ✅ No need to reference lookup tables
- ✅ Natural sorting works everywhere
- ✅ Temporal context visible at a glance

## Best Practices

1. **Use creation timestamp** - When a document is written, use that exact time
2. **Keep slugs short** - Aim for 3-6 words, hyphenated
3. **Create directories as needed** - Year/month directories are created on-demand
4. **Reference related documents** - Link to related ADRs, features, or out-of-scope items
5. **Consistent timezone** - Use the same timezone for all timestamps

## Template Integration

This naming convention should be referenced in:
- ADR templates
- Feature templates
- Out-of-scope templates
- AGENTS.md generation workflows

Use the include directive to reference this convention:
```jinja2
{{ include "templates/includes/naming-convention-date-embedded.md" . }}
```


# Shared Task Definitions

These shared definitions are included by multiple workflow templates under `dot_config/ai/workflows/software-dev/tasks/`.
They standardize terminology and expectations for generating task lists from PRDs and similar inputs.

## Terms

- Parallel stories: Stories within the same phase that can be executed concurrently without conflicts.
- Sequential phases: Ordered phases; each phase must complete before the next begins.
- Story ID: `PP-III` where `PP` is a 2-digit phase number; `III` is a 3-digit parallel index.
- Branch naming: `feature/current/[PRD-NAME-KEBAB-CASE]/story-[PP]-[III]-[STORY-NAME-KEBAB-CASE]`.
- Relevant files: Concrete files expected to be created/updated, plus their tests.

## Required Story Metadata

Each story should declare at least:

- story_id, story_title, story_name
- prd_name, prd_file
- phase, parallel_id
- branch
- status, assignee, reviewer
- dependencies (list), parallel_safe (bool)
- modules (list), priority, risk_level, tags
- due, created_at, updated_at

## Story Body Structure

Stories should contain sections for:

- Summary: intent and scope boundaries
- Sub-Tasks: actionable steps, each referencing target files
- Relevant Files: code files and test files impacted
- Acceptance Criteria: verifiable outcomes
- Test Plan: unit, lint, types, and any e2e notes
- Observability: logging/metrics/traces updates
- Compliance: regulatory/data handling concerns
- Risks & Mitigations: notable risks and how to reduce them
- Dependencies & Sequencing: what it depends on and what it unblocks
- Definition of Done: what must be true before marking done
- Commit Conventions: e.g., conventional commits with module scoping

## Output Conventions

- Place generated story files under `internal-docs/feature/YYYY/MM/{slug}/tasks/`.
- Filename pattern: `tasks-[PRD-NAME-KEBAB-CASE]-[PP]-[III]-[STORY-NAME-KEBAB-CASE].md`.
- Create a phase-index file `index-[PRD-NAME-KEBAB-CASE].md` summarizing all stories in a table with: Story ID, Title, Branch, Dependencies, Parallel-safe, Modules.

## Review Gates

Before moving from high-level stories to detailed sub-tasks:

- Present the high-level plan and wait for an explicit "Go".
- After generating sub-tasks, verify dependencies minimize merge conflicts and enable parallel work.

## Commit Conventions

- Use conventional commits with module scoping, e.g., `feat(moduleA): …`

## Notes for AI Assistants

- If the PRD file path is not provided, ask for it explicitly.
- Keep sub-tasks small, testable, and scoped to minimize conflicts.
- Always list and update the `Relevant Files` to guide implementation and reviews.


### 2) Per-Story File Template

- **Location:** `internal-docs/feature/YYYY/MM/{slug}/tasks/`
- **Filename:** `tasks-[PRD-NAME-KEBAB-CASE]-[PP]-[III]-[STORY-NAME-KEBAB-CASE].md`

Use the following structure for each story file (YAML front matter + markdown sections):

```markdown
---
story_id: "PP-III"            # e.g., "01-001"
story_title: "<story title>"
story_name: "<STORY-NAME-KEBAB-CASE>"
prd_name: "<PRD-NAME-KEBAB-CASE>"  # e.g., user-handling
prd_file: "internal-docs/feature/YYYY/MM/{slug}/feat-YYYYMMDDHHmm-{slug}.md"
phase: 1                      # 2-digit sequential phase as integer
parallel_id: 1                # 3-digit parallel index as integer
branch: "feature/current/<PRD-NAME-KEBAB-CASE>/story-PP-III-<STORY-NAME-KEBAB-CASE>"
status: "todo"               # todo | in_progress | blocked | done | archive
assignee: ""
reviewer: ""
dependencies: ["01-001"]     # list of story_ids
parallel_safe: true
modules: ["module-a"]
priority: "MUST"             # MUST | SHOULD | COULD | WONT
risk_level: "medium"          # low | medium | high
tags: ["feat", "backend"]
due: "YYYY-MM-DD"
create-date: "YYYY-MM-DD"
update-date: "YYYY-MM-DD"
---
## Summary

One-paragraph description of the story, intent, and scope boundaries.

## Sub-Tasks

- [ ] Task 1 — scope and target files
- [ ] Task 2 — scope and target files

Status conventions: mark in-progress with `[~]`, done with `[x]`, blocked with `[!]`.

## Relevant Files

- `path/to/file.ext` — why relevant
- `another/path.ext` — why relevant

## Acceptance Criteria (Gherkin)

- Given `precondition`, When `action`, Then `result`
- Given ..., When ..., Then ...
```

## AI Instructions

When working with task lists, the AI must:

0. Do not invent the initial story list — use the stories created by the `tasks-from-prd.md` workflow.
1. Regularly update the task list file after finishing any significant work.
2. Follow the completion protocol:
   - Mark each finished **sub‑task** `[x]`.
   - Mark the **parent task** `[x]` once **all** its subtasks are `[x]`.
3. Propose newly discovered tasks and wait for user approval before adding.
4. Keep "Relevant Files" accurate and up to date.
5. Before starting work, check which sub‑task is next.
6. After implementing a sub‑task, update the file and then pause for user approval.


---
workflow: "Tasks from PRD"
slug: "tasks-from-prd"
description: "Generate a parallelizable task story list from an existing PRD"
use: "When breaking a PRD into implementable task stories with dependency tracking"
role: "Technical Lead"
date:
  created: "2026-07-11"
  knowledge-basis: "2026-07-30"
  last-used: "2026-07-30"
tags:
  - "ai/workflow/software-dev/tasks/from-prd"
  - "task-generation"
  - "parallel-stories"
see-also:
  - workflow: "greenfield-prd"
    relationship: "previous-step"
    description: "Produces the PRD this workflow consumes"
  - workflow: "tasks-processor"
    relationship: "next-step"
    description: "Executes the task stories this workflow produces"
  - skill: "execute-upsert"
    relationship: "complement"
    description: "Orchestrates PRD creation, task breakdown, and execution as a pipeline"
---

---
description: Guidance for delegating work to subagents with reduced initial memory — front-load context, review results, and choose serialization vs parallelization deliberately
---

### Subagent Delegation

When the runtime supports subagents that start with a reduced (or fresh) context window, prefer delegation over doing the work in the orchestrator's context. The orchestrator's context is a scarce, shared resource; a subagent's fresh context is cheap and disposable.

#### Step Marker: `[fork]`

A workflow or skill author can tag a step with `[fork]` to signal that this step is a strong delegation candidate. The marker is a pointer, not a directive — it says "consider forking this to a subagent" without restating the full guidance below.

**When you see `[fork]` on a step:** apply the delegation protocol in this include (front-load context, review the result, choose serialization vs parallelization for any sibling `[fork]` steps).

**When authoring — mark a step with `[fork]` only if:**

- The step is self-contained (a subagent can complete it without asking back).
- The step is context-heavy (doing it in the orchestrator would burn context the orchestrator needs later).
- The step has a clear deliverable the orchestrator can review.

Do NOT mark every step. Steps needing orchestrator judgment, iterative back-and-forth, or cross-step state belong in the orchestrator — marking those `[fork]` is noise.

**Example:**

```markdown
1. Read the user's request and identify the target module.
2. `[fork]` Search the codebase for all callers of `parseConfig()` and return the file:line list.
3. Based on the caller list, decide which callers need updating.
4. `[fork]` For each caller identified in step 3, apply the signature change and run its targeted test.
```

Steps 2 and 4 are marked: both are self-contained, context-heavy, and have reviewable deliverables. Step 3 is not — it's the orchestrator's judgment call using step 2's output. Step 4 forks are parallelizable (independent callers), but each depends on step 3's decision, so they serialize after step 3.

#### When to Delegate

Delegate when the work is **self-contained** — the subagent can complete it without asking clarifying questions back. Subagents are stateless: they cannot see the orchestrator's context and cannot prompt for clarification. If a task needs iterative back-and-forth, do it in the orchestrator.

Good delegation candidates: a bounded search, a file transform with a known shape, a single function implementation, a review of a specific diff, a one-shot investigation with a defined deliverable.

#### Front-Load the Starting Context

A subagent succeeds or fails on the prompt it's given. Before dispatching, assemble a complete starting context:

- **Goal**: what the subagent should produce, in one sentence.
- **Inputs**: exact file paths, symbol names, line ranges, or URLs it should read. Don't make it search for what you already know.
- **What's already known**: findings the orchestrator has already established that the subagent would otherwise re-derive.
- **Constraints**: conventions to follow, what NOT to touch, output format expected.
- **What to return**: the specific artifact or answer shape the orchestrator needs back.

If you can't write this prompt confidently, the task isn't ready to delegate — finish scoping it in the orchestrator first.

#### Review the Subagent's Work

Delegation is not abdication. After the subagent returns:

1. **Verify the deliverable** against the goal stated in the prompt. Check it actually does what was asked, not just what was literally typed.
2. **Check the blast radius**: did it edit only what was intended? Grep callers of any function it touched.
3. **Run the smallest check that would fail if the work is wrong** — typecheck, a targeted test, or an assert-based self-check.
4. **Re-dispatch only the failing slice** if the result is partially correct. Don't re-run the whole task for one fix.

#### Serialization vs Parallelization

Choose deliberately, not by default:

- **Parallel** when tasks are independent (no shared output, no read-after-write dependency between them). Launch all in one batch and collect results as they complete. Example: reviewing three unrelated PRs, searching three unrelated code areas.
- **Serial** when one task's output is another's input, or when tasks write to the same files/state. Running them in parallel produces conflicts or wasted work. Example: implement, then test the implementation, then refactor based on test results.

When unsure, ask: "does task B need to read what task A produced?" If yes, serialize. If no, parallelize.

#### Anti-Patterns

- **Vague dispatch**: "investigate the auth flow" with no file paths. The subagent re-explores what the orchestrator already knows.
- **Delegating the decision, not the work**: asking a subagent to "decide the approach" when the orchestrator should own strategy. Delegate execution, keep judgment.
- **Parallelizing dependent tasks**: spawning implement + test simultaneously, then the test runs against code that doesn't exist yet.
- **Serializing independent tasks "to be safe"**: three independent searches run one-after-another when they could have run concurrently. Costs 3x the wall time for no safety gain.
- **Skipping review**: trusting the subagent's self-report without running a check. The subagent's "done" and the orchestrator's "correct" are different bars.


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


# Rule: Generating a Task List from a PRD

## Goal

To guide an AI assistant in creating a detailed, step-by-step task list in Markdown format based on an existing Product Requirements Document (PRD). The task list should guide a developer through implementation.

Three properties make each story executable by a weaker model:
1. **Self-contained context** — everything needed is in the file: paths, code excerpts, conventions, commands
2. **Verification gates** — every sub-task has validation criteria with commands and expected results
3. **Hard boundaries** — explicit in-scope/out-of-scope lists and STOP conditions

## Output

- **Format:** Markdown (`.md`)
- **Location (both outputs):** `internal-docs/feature/YYYY/MM/{slug}/tasks/`
- **Story files (one per story):** Filename `tasks-[PRD-NAME-KEBAB-CASE]-[2-DIGIT-STORY-PARALLEL-PHASE]-[3-DIGIT-STORY-PARALLEL-ID]-[STORY-NAME-KEBAB-CASE].md` (e.g., `tasks-prd-user-handling-01-001-user-tables.md`, `tasks-prd-user-handling-02-001-user-signup-api.md`, `tasks-prd-user-handling-02-002-user-signup-mock-service.md`). See "Per-Story File Template (with YAML front matter)" for required metadata and body structure.
- **Index file (summary of all stories):** Filename `index-[PRD-NAME-KEBAB-CASE].md`. The content MUST follow the table structure shown in `### Example Structure` — a single Markdown table with columns: Story ID, Title, Phase, Status, Assignee, Parallel-safe, Dependencies, Dependants, Modules, Branch. The **Status** column is mandatory from creation and every story MUST be initialized as `[ ] Todo`. Downstream consumers (`tasks-processor.md` workflow, `execute-upsert` skill) read this column to select the next runnable story and fail with "table has no Status column yet" if it is missing.

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


## Process

1. **Receive PRD Reference:** The user points the AI to a specific PRD file. If you didn't get this you must ask for it.
2. If the PRD file is not descriptively named, give it a descriptive name and use `git mv` (if necessary to rename it and move it to the proper location.)
3. **Analyze PRD:** The AI reads and analyzes the functional requirements, user stories, and other sections of the specified PRD.
4. [fork] **Derive Context (Mandatory - Separate Phase):** Use available tools (grep, find, codegraph, read) to identify relevant files, existing patterns, build/test/lint commands for each story. This context MUST be inlined in each story file — never say "as discussed" or "see PRD".
5. **Phase 1: Generate Parallel Story Sets:** Based on the PRD analysis, propose sequential phases. Within each phase, define parallel stories that can be developed simultaneously. Organize stories for **PARALLEL** execution using Git worktrees. Present only the high-level story list first (no sub-tasks yet). Inform the user: "I have generated the high-level tasks based on the PRD. Ready to generate the sub-tasks? Respond with 'Go' to proceed."
6. **Wait for Confirmation:** Pause and wait for the user to respond with "Go", "Ok", "Yes", or similar.
7. **Phase 2: Generate Sub-Tasks:** Once confirmed, for each story create smaller, actionable sub-tasks. Ensure sub-tasks logically follow from dependencies and minimize merge conflicts by scoping changes. Each sub-task MUST include verification commands with expected results.
8. **Identify Relevant Files:** Based on the tasks and PRD, identify potential files that will need to be created or modified. List these under the `Relevant Files` section, including corresponding test files if applicable.
9. **Generate Final Output:** Combine the parent tasks, sub-tasks, relevant files, notes, and derived context into the final Markdown structure.
10. **Save Task List:** Save each story document to `internal-docs/feature/YYYY/MM/{slug}/tasks/` using the filename `tasks-[PRD-NAME-KEBAB-CASE]-[2-DIGIT-STORY-PHASE]-[3-DIGIT-STORY-PARALLEL-ID]-[STORY-NAME-KEBAB-CASE].md`.

## Numbering Scheme and Branch Naming

- **Use this numbering scheme:**
  - **Parallel stories**: Can be developed simultaneously within the same sequential phase.
  - **Sequential phases**: Phases must be completed in order; each phase contains a set of parallel stories.
- **Critical Validation Rule**: All dependencies for stories in phase NN MUST reference stories from phases < NN. Stories within the same phase MUST NOT depend on each other. If a story depends on another story in the same phase, they must be split into separate phases.
- **For each story, include:**
  - **Story ID**: `PP-III` where `PP` is 2-digit phase, `III` is 3-digit parallel index (e.g., `01-001`).
  - **Worktree branch name**: `feature/current/[PRD-NAME-KEBAB-CASE]/story-[PP]-[III]-[STORY-NAME-KEBAB-CASE]`.
  - **Dependencies**: Prior stories (e.g., `01-001, 01-002`).
  - **Parallel safe**: `true/false`.
  - **Modules/areas impacted**: Call out directories or services to minimize conflicts.

### Example Structure of Index File

The index file MUST include a **Status** column so downstream consumers
(`tasks-processor.md` workflow, `execute-upsert` skill) can track progress
without re-deriving it. Every story is created with status `[ ] Todo`.

Status markers (must match `tasks-processor.md` exactly):

- `[ ] Todo` — not started, ready to run if dependencies are `[x] Done`
- `[~] In-Progress` — subagent currently running or paused mid-work
- `[x] Done` — completed and verified
- `[!] Blocked` — cannot proceed (record `blocked_reason`)

```markdown
| Story ID | Title | Phase | Status | Assignee | Parallel-safe | Dependencies | Dependants | Modules | Branch |
|---|---|---:|---|---|---|---|---|---|---|
| 01-001 | [Story Title] | 01 | [ ] Todo |  | true | — | 02-001 | module-a | feature/current/[[PRD-NAME-KEBAB-CASE]]/[[story-01-001-STORY-NAME-KEBAB-CASE]] |
| 01-002 | [Story Title] | 01 | [ ] Todo |  | true | — | 02-002 | module-b | feature/current/[[PRD-NAME-KEBAB-CASE]]/[[story-01-002-STORY-NAME-KEBAB-CASE]] |
| 01-003 | [Story Title] | 01 | [ ] Todo |  | true | — | 02-002 | module-c | feature/current/[[PRD-NAME-KEBAB-CASE]]/[[story-01-003-STORY-NAME-KEBAB-CASE]] |
| 02-001 | [Story Title] | 02 | [ ] Todo |  | true | 01-001, 01-002 | 03-001 | module-a | feature/current/[[PRD-NAME-KEBAB-CASE]]/[[story-02-001-STORY-NAME-KEBAB-CASE]] |
| 02-002 | [Story Title] | 02 | [ ] Todo |  | true | 01-001, 01-003 | 03-001 | module-b | feature/current/[[PRD-NAME-KEBAB-CASE]]/[[story-02-002-STORY-NAME-KEBAB-CASE]] |
| 03-001 | [Story Title] | 03 | [ ] Todo |  | false | 01-002, 02-001 | — | module-x | feature/current/[[PRD-NAME-KEBAB-CASE]]/[[story-03-001-STORY-NAME-KEBAB-CASE]] |
```

**Critical**: The Status column is mandatory from creation. Downstream
consumers fail with "table has no Status column yet" if it is missing. Every
row MUST start as `[ ] Todo` — never leave Status blank or omit it.

## Output Format

The generated task list _must_ follow this structure:

```markdown
## Relevant Files

- `path/to/potential/file1.mts` - Brief description of why this file is relevant (e.g., Contains the main component for this feature).
- `path/to/file1.test.mts` - Unit tests for `file1.mts`.
- `path/to/another/file.mts` - Brief description (e.g., API route handler for data submission).
- `path/to/another/file.test.mts` - Unit tests for `another/file.mts`.
- `lib/utils/helpers.mts` - Brief description (e.g., Utility functions needed for calculations).
- `lib/utils/helpers.test.mts` - Unit tests for `helpers.mts`.

### Notes

- Unit tests should typically be placed alongside the code files they are testing (e.g., `MyComponent.mts` and `MyComponent.test.mts` in the same directory).
- Use `bun run jest [optional/path/to/test/file]` to run tests. Running without a path executes all tests found by the Jest configuration.

## Parallel Development Sets

### Phase 01
- Story 01-001 | [Story Title] | Status: [ ] Todo | Branch: feature/current/[PRD-NAME-KEBAB-CASE]/story-01-001-[STORY-NAME-KEBAB-CASE] | Dependencies: None | Parallel-safe: true | Modules: [module-a]
- Story 01-002 | [Story Title] | Status: [ ] Todo | Branch: feature/current/[PRD-NAME-KEBAB-CASE]/story-01-002-[STORY-NAME-KEBAB-CASE] | Dependencies: None | Parallel-safe: true | Modules: [module-b]

### Phase 02
- Story 02-001 | [Story Title] | Status: [ ] Todo | Branch: feature/current/[PRD-NAME-KEBAB-CASE]/story-02-001-[STORY-NAME-KEBAB-CASE] | Dependencies: 01-001 | Parallel-safe: true | Modules: [module-a]
- Story 02-002 | [Story Title] | Status: [ ] Todo | Branch: feature/current/[PRD-NAME-KEBAB-CASE]/story-02-002-[STORY-NAME-KEBAB-CASE] | Dependencies: 01-002 | Parallel-safe: true | Modules: [module-b]
```

## Per-Story File Template (with YAML front matter)

Each story file must begin with YAML front matter followed by a structured body. Save files to `internal-docs/feature/YYYY/MM/tasks/` as `tasks-[PRD-NAME-KEBAB-CASE]-[PP]-[III]-[STORY-TITLE-KEBAB-CASE].md`.

```yaml
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
created_at: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD"
---
```

```markdown
## Summary

One-paragraph description of the story, intent, and scope boundaries.

## Current State

- **Relevant files and their roles:**
  - `path/to/file.ts` — description (lines X-Y if relevant)
- **Existing code excerpts:** (short excerpts with file:line markers of code that will change)
- **Repository conventions:** (patterns to follow, with exemplar file references)
- **Build/test/lint commands:**
  | Purpose   | Command                  | Expected Result |
  |-----------|--------------------------|-----------------|
  | Build     | `pnpm run build`          | exit 0          |
  | Tests     | `pnpm test`               | all pass        |
  | Lint      | `pnpm run lint`           | exit 0          |

## Scope

**In scope:**
- List what this story covers (specific files, features, changes)

**Out of scope:**
- Explicitly list what is NOT covered (prevents scope creep)

## Sub-Tasks

- [ ] Task 1 — scope and target files
  **Verify**: `<command>` → <expected output>
- [ ] Task 2 — scope and target files
  **Verify**: `<command>` → <expected output>

Status conventions: mark in-progress with `[~]`, done with `[x]`, blocked with `[!]`.

## Relevant Files

- `path/to/file.mts` — why relevant
- `path/to/file.test.mts` — tests for the above

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Test Plan

- Unit: `bun run jest [optional/path]`
- Lint: `bun run lint` (or equivalent)
- Types: `bun run typecheck` (or equivalent)

## Observability

- Logging, metrics, traces to add; dashboards/alerts to update

## Compliance

- Note regulatory/privacy constraints; data handling; retention

## Risks & Mitigations

- Risk: … — Mitigation: …

## Dependencies & Sequencing

- Depends on:
  - [[story-01-001-STORY-NAME-KEBAB-CASE]]
  - [[story-01-002-STORY-NAME-KEBAB-CASE]]
- Unblocks:
  - [[story-02-002-STORY-NAME-KEBAB-CASE]]

## Definition of Done

- [ ] All verification commands from sub-tasks pass
- [ ] Code, tests, docs updated; CI green; dashboard and story file updated
- [ ] No files outside in-scope list are modified (`git status`)

## STOP Conditions

Stop and report if:
- The code at the documented locations doesn't match the excerpts
- A sub-task verification fails twice after reasonable fix attempts
- The implementation requires touching an out-of-scope file
- A dependency cannot be satisfied

## Maintenance Notes

- Future considerations for this story
- What reviewers should scrutinize
- Follow-up work deferred (and why)

## Commit Conventions

- Use conventional commits with module scoping, e.g., `feat(moduleA): …`

## Changelog

- YYYY-MM-DD: initialized story file
```

## Interaction Model

The process explicitly requires a pause after generating parent tasks to get user confirmation ("Go") before proceeding to generate the detailed sub-tasks. This ensures the high-level plan aligns with user expectations before diving into details.

## Target Audience

Assume the primary reader of the task list is a **junior developers** who will implement the feature in parallel with other junior developers.

